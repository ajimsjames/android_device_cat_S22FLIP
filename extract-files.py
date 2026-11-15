#!/usr/bin/env python3
#
# Copyright (C) 2026 The LineageOS Project
#
# Complete vendor & proprietary extractor for Cat S22 Flip (Bullitt QM215 / MSM8937)
# Copies 100% of the working hybrid /vendor partition from the connected device
# into vendor/cat/s22flip/proprietary/vendor and regenerates s22flip-vendor.mk
# and proprietary-files.txt so the in-tree vendor build is a 1:1 match.
#

import os
import subprocess
import sys
import tarfile
import tempfile

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ANDROID_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "../../.."))
VENDOR_DIR = os.path.join(ANDROID_ROOT, "vendor/cat/s22flip")
PROP_DIR = os.path.join(VENDOR_DIR, "proprietary")
PROP_VENDOR_DIR = os.path.join(PROP_DIR, "vendor")
VENDOR_MK = os.path.join(VENDOR_DIR, "s22flip-vendor.mk")
PROP_FILES_TXT = os.path.join(SCRIPT_DIR, "proprietary-files.txt")

# Files managed by the Android build system / BoardConfig / rootdir targets
# (we still extract them into proprietary/vendor for reference, but skip
#  conflicting PRODUCT_COPY_FILES targets where the build system generates them)
SKIP_COPY_FILES = {
    "build.prop",
    "default.prop",
    "etc/fs_config_dirs",
    "etc/fs_config_files",
    "etc/group",
    "etc/passwd",
    "odm/etc/build.prop",
    "odm_dlkm/etc/build.prop",
    "vendor_dlkm/etc/build.prop",
}

SKIP_COPY_PREFIXES = (
    "etc/selinux/",
    "etc/init/hw/init.target.rc",
    "etc/init/hw/init.qcom.rc",
    "etc/fstab.qcom",
    "etc/vintf/manifest.xml",
    "etc/vintf/compatibility_matrix.xml",
    "etc/vintf/manifest/",
    # Prebuilt vendor APKs handled by Android.bp android_app_import
    "app/CneApp/CneApp.apk",
    "app/TimeService/TimeService.apk",
    "app/CACertService/CACertService.apk",
    "app/com.qualcomm.qti.improvetouch.service/com.qualcomm.qti.improvetouch.service.apk",
)


def run_cmd(cmd, **kwargs):
    print(f"+ {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    return subprocess.run(cmd, check=True, **kwargs)


def pull_entire_vendor_from_device():
    print("==> Checking connected ADB device...")
    run_cmd(["adb", "wait-for-device"])
    run_cmd(["adb", "root"])
    run_cmd(["adb", "wait-for-device"])

    # Clean old *_dlkm.ko or stale files in proprietary/vendor/lib/modules
    os.makedirs(PROP_VENDOR_DIR, exist_ok=True)

    with tempfile.NamedTemporaryFile(suffix=".tar", delete=False) as tmp_tar:
        tar_path = tmp_tar.name

    try:
        print("==> Archiving entire /vendor filesystem (excluding sub-mounts) on device...")
        # Use tar -cf - -C /vendor . while excluding mounted sub-filesystems (firmware_mnt, dsp, bt_firmware)
        adb_tar_cmd = (
            "adb shell 'cd /vendor && tar -cf - "
            "--exclude=./firmware_mnt --exclude=./dsp --exclude=./bt_firmware "
            "--exclude=./lost+found .'"
        )
        with open(tar_path, "wb") as out_f:
            subprocess.run(adb_tar_cmd, shell=True, check=True, stdout=out_f)

        print(f"==> Extracting archive ({os.path.getsize(tar_path) // (1024*1024)} MB) into {PROP_VENDOR_DIR}...")
        # Remove old proprietary/vendor to ensure 100% exact mirror (no stale *_dlkm.ko or broken libs)
        subprocess.run(["rm", "-rf", PROP_VENDOR_DIR], check=True)
        os.makedirs(PROP_VENDOR_DIR, exist_ok=True)

        # Extract regular files, directories, and symlinks so proprietary/vendor is a 100% 1:1 mirror of live /vendor
        with tarfile.open(tar_path, "r") as tf:
            for member in tf.getmembers():
                # Normalize path
                rel = os.path.normpath(member.name).lstrip("./")
                if not rel or rel == ".":
                    continue
                dest = os.path.join(PROP_VENDOR_DIR, rel)
                if member.issym():
                    os.makedirs(os.path.dirname(dest), exist_ok=True)
                    if os.path.lexists(dest):
                        os.unlink(dest)
                    os.symlink(member.linkname, dest)
                elif member.isdir():
                    os.makedirs(dest, exist_ok=True)
                elif member.isfile():
                    os.makedirs(os.path.dirname(dest), exist_ok=True)
                    if os.path.lexists(dest):
                        os.unlink(dest)
                    with tf.extractfile(member) as src_f, open(dest, "wb") as dst_f:
                        dst_f.write(src_f.read())
                    os.chmod(dest, member.mode & 0o777)
    finally:
        if os.path.exists(tar_path):
            os.unlink(tar_path)


def collect_non_vendor_entries():
    """Keep existing product/, system_ext/, and system/ entries from proprietary-files.txt."""
    non_vendor = []
    if os.path.exists(PROP_FILES_TXT):
        with open(PROP_FILES_TXT, "r") as f:
            for line in f:
                s = line.strip()
                if not s or s.startswith("#"):
                    continue
                clean = s.lstrip("-")
                if not clean.startswith("vendor/"):
                    non_vendor.append(s)
    return sorted(set(non_vendor))


def collect_vendor_files():
    vendor_files = []
    for root, _, files in os.walk(PROP_VENDOR_DIR):
        for fn in files:
            full = os.path.join(root, fn)
            if os.path.islink(full):
                continue
            rel = os.path.relpath(full, PROP_VENDOR_DIR)
            vendor_files.append(rel)
    return sorted(vendor_files)


def should_copy_vendor_file(rel):
    if rel in SKIP_COPY_FILES:
        return False
    for pfx in SKIP_COPY_PREFIXES:
        if rel.startswith(pfx):
            return False
    return True


def regenerate_makefiles(non_vendor_entries, vendor_files):
    print(f"==> Updating {PROP_FILES_TXT}...")
    with open(PROP_FILES_TXT, "w") as f:
        f.write("# Proprietary blobs for Cat S22 Flip (MSM8937 / QM215)\n")
        f.write("# Automatically generated by extract-files.py\n\n")
        for item in non_vendor_entries:
            f.write(f"{item}\n")
        for vf in vendor_files:
            if should_copy_vendor_file(vf):
                f.write(f"vendor/{vf}\n")

    print(f"==> Generating {VENDOR_MK}...")
    copy_rules = []

    # 1. Non-vendor (product, system_ext, system) copy rules where the file exists in proprietary/
    # Skip APKs that are defined in vendor/cat/s22flip/Android.bp as android_app_import
    bp_apks = {
        "system_ext/app/QtiTelephonyService/QtiTelephonyService.apk",
        "system_ext/app/datastatusnotification/datastatusnotification.apk",
        "system_ext/app/imssettings/imssettings.apk",
        "system_ext/priv-app/ims/ims.apk",
        "system_ext/priv-app/qcrilmsgtunnel/qcrilmsgtunnel.apk",
        "system_ext/priv-app/dpmserviceapp/dpmserviceapp.apk",
        "system_ext/priv-app/seccamservice/seccamservice.apk",
        "system_ext/priv-app/com.qualcomm.location/com.qualcomm.location.apk",
        "system_ext/priv-app/xtra_t_app/xtra_t_app.apk",
        "system_ext/app/FM2/FM2.apk",
        "system_ext/app/AntHalService/AntHalService.apk",
        "system_ext/build.prop",
    }

    for entry in non_vendor_entries:
        clean = entry.lstrip("-").split(":")[0].split(";")[0]
        if clean in bp_apks:
            continue
        src_path = os.path.join(PROP_DIR, clean)
        if not os.path.isfile(src_path):
            continue
        if clean.startswith("product/"):
            sub = clean[len("product/"):]
            copy_rules.append(
                f"    vendor/cat/s22flip/proprietary/{clean}:$(TARGET_COPY_OUT_PRODUCT)/{sub}"
            )
        elif clean.startswith("system_ext/"):
            sub = clean[len("system_ext/"):]
            copy_rules.append(
                f"    vendor/cat/s22flip/proprietary/{clean}:$(TARGET_COPY_OUT_SYSTEM_EXT)/{sub}"
            )
        elif clean.startswith("system/"):
            sub = clean[len("system/"):]
            copy_rules.append(
                f"    vendor/cat/s22flip/proprietary/{clean}:$(TARGET_COPY_OUT_SYSTEM)/{sub}"
            )

    # 2. All vendor files from live working hybrid vendor
    for vf in vendor_files:
        if not should_copy_vendor_file(vf):
            continue
        copy_rules.append(
            f"    vendor/cat/s22flip/proprietary/vendor/{vf}:$(TARGET_COPY_OUT_VENDOR)/{vf}"
        )

    with open(VENDOR_MK, "w") as f:
        f.write("# Generated automatically by extract-files.py for Cat S22 Flip (Bullitt QM215 / MSM8937)\n")
        f.write("# Complete 1:1 vendor + system_ext + product proprietary copy rules\n\n")
        f.write("PRODUCT_SOONG_NAMESPACES += \\\n    vendor/cat/s22flip\n\n")
        f.write("PRODUCT_COPY_FILES += \\\n")
        f.write(" \\\n".join(copy_rules))
        f.write("\n\n")
        f.write(
            "PRODUCT_PACKAGES += \\\n"
            "    QtiTelephonyService \\\n"
            "    datastatusnotification \\\n"
            "    imssettings \\\n"
            "    ims \\\n"
            "    qcrilmsgtunnel \\\n"
            "    dpmserviceapp \\\n"
            "    seccamservice \\\n"
            "    com.qualcomm.location \\\n"
            "    xtra_t_app \\\n"
            "    FM2 \\\n"
            "    AntHalService \\\n"
            "    CneApp \\\n"
            "    TimeService \\\n"
            "    CACertService \\\n"
            "    com.qualcomm.qti.improvetouch.service\n"
        )

    print(f"==> Done! Extracted {len(vendor_files)} vendor files and wrote {len(copy_rules)} copy rules.")


def main():
    pull_entire_vendor_from_device()
    non_vendor = collect_non_vendor_entries()
    vendor_files = collect_vendor_files()
    regenerate_makefiles(non_vendor, vendor_files)


if __name__ == "__main__":
    main()
