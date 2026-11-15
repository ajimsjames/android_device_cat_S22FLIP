#
# Copyright (C) 2026 The LineageOS Project
#
# Unified BoardConfig for Cat S22 Flip (Bullitt QM215 / MSM8937)
# Merged from Mithorium Common + Cat S22 Flip Hardware Specs
#

DEVICE_PATH := device/cat/s22flip

# -----------------------------------------------------------------------------
# Architecture: ARM32 userland with 64-bit binder (a64)
# -----------------------------------------------------------------------------
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a53
TARGET_USES_64_BIT_BINDER := true

# -----------------------------------------------------------------------------
# Platform & Bootloader
# -----------------------------------------------------------------------------
TARGET_BOARD_PLATFORM := msm8937
TARGET_BOOTLOADER_BOARD_NAME := msm8937
TARGET_NO_BOOTLOADER := true
BOARD_USES_QCOM_HARDWARE := true
TARGET_OTA_ASSERT_DEVICE := cat_s22,s22flip,CatS22,CatS22Flip,S22Flip,S22FLIP

# -----------------------------------------------------------------------------
# Kernel & Boot Image (Header Version 2 matches Cat S22 Flip stock boot/recovery)
# -----------------------------------------------------------------------------
BOARD_BOOT_HEADER_VERSION := 2
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_DTB_OFFSET := 0x01f00000
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200,n8 androidboot.console=ttyMSM0 androidboot.hardware=qcom androidboot.memcg=true user_debug=30 msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlycon=msm_hsl_uart,0x78B0000 vmalloc=300M androidboot.usbconfigfs=true cgroup.memory=nokmem,nosocket loop.max_part=7 androidboot.selinux=permissive enforcing=0
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --dtb_offset $(BOARD_DTB_OFFSET)

TARGET_KERNEL_VERSION := 4.9
TARGET_KERNEL_ARCH := arm
TARGET_KERNEL_CONFIG := cats22_defconfig
BOARD_KERNEL_IMAGE_NAME := zImage
TARGET_KERNEL_SOURCE := kernel/cat/msm-4.9
TARGET_KERNEL_CLANG_COMPILE := false

# Prebuilts fallback
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilts

# -----------------------------------------------------------------------------
# Audio (Qualcomm HAL + TinyALSA + Awinic Smart Amp)
# -----------------------------------------------------------------------------
BOARD_USES_ALSA_AUDIO := false
USE_XML_AUDIO_POLICY_CONF := 1
AUDIO_USE_DEEP_AS_PRIMARY_OUTPUT := false
AUDIO_FEATURE_ENABLED_HIFI_AUDIO := true
AUDIO_FEATURE_ENABLED_VBAT_MONITOR := true
AUDIO_FEATURE_ENABLED_ANC_HEADSET := true
AUDIO_FEATURE_ENABLED_CUSTOMSTEREO := true
AUDIO_FEATURE_ENABLED_FLUENCE := true
AUDIO_FEATURE_ENABLED_HFP := true
AUDIO_FEATURE_ENABLED_INCALL_MUSIC := true
AUDIO_FEATURE_ENABLED_MULTI_VOICE_SESSIONS := true
AUDIO_FEATURE_ENABLED_KPI_OPTIMIZE := true
AUDIO_FEATURE_ENABLED_SPKR_PROTECTION := true
TARGET_USES_QCOM_MM_AUDIO := false
AUDIO_FEATURE_ENABLED_DLKM := false

# -----------------------------------------------------------------------------
# Display & Graphics
# -----------------------------------------------------------------------------
TARGET_SCREEN_DENSITY := 240
TARGET_USES_GRALLOC1 := true
TARGET_USES_HWC2 := true
TARGET_USES_ION := true

# -----------------------------------------------------------------------------
# Partitions & Dynamic Partitions (Retrofit Dynamic Partitions)
# -----------------------------------------------------------------------------
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456

BOARD_SUPER_PARTITION_SIZE := 4095737856
BOARD_SUPER_PARTITION_GROUPS := cat_dynpart
BOARD_CAT_DYNPART_SIZE := 4091543552
BOARD_CAT_DYNPART_PARTITION_LIST := system vendor product

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_SIZE := 524288000
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
# Disabled to allow read-write remounting:
# BOARD_EXT4_SHARE_DUP_BLOCKS := true


TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab

# -----------------------------------------------------------------------------
# Bluetooth & Wi-Fi
# -----------------------------------------------------------------------------
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_PATH)/bluetooth
BOARD_HAS_QCOM_WLAN := true
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_qcwcn
BOARD_WLAN_DEVICE := qcwcn
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_qcwcn
WIFI_AVOID_IFACE_RESET_MAC_CHANGE := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

# -----------------------------------------------------------------------------
# GPS
# -----------------------------------------------------------------------------
# BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := default
LOC_HIDL_VERSION := 4.0

# -----------------------------------------------------------------------------
# Rootdir Extra Folders, Symlinks & Calibration
# -----------------------------------------------------------------------------
BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += bt_firmware sec_storage efs metadata persist

BOARD_ROOT_EXTRA_SYMLINKS := \
    /vendor/dsp:/dsp \
    /vendor/firmware_mnt:/firmware \
    /mnt/vendor/persist:/persist

# -----------------------------------------------------------------------------
# SELinux Policy
# -----------------------------------------------------------------------------
include device/qcom/sepolicy-legacy-um/SEPolicy.mk
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SELINUX_IGNORE_NEVERALLOWS := true

# -----------------------------------------------------------------------------
# Build system flags
# -----------------------------------------------------------------------------
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_VINTF_PRODUCT_COPY_FILES := true
include vendor/cat/s22flip/BoardConfigVendor.mk
TARGET_RECOVERY_DEVICE_DIRS += $(DEVICE_PATH)

# Use prebuilt kernel and header includes for standalone system build
# TARGET_PREBUILT_KERNEL := device/cat/s22flip/prebuilts/zImage

# VINTF: install device manifest as /vendor/etc/vintf/manifest.xml (stock-identical).
# Without it the vendor image has no HAL manifest and framework/hwservicemanager fail.
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml \
    $(DEVICE_PATH)/vintf/android.hardware.atrace@1.0-service.xml \
    $(DEVICE_PATH)/vintf/android.hardware.cas@1.2-service-lazy.xml \
    $(DEVICE_PATH)/vintf/android.hardware.gnss@2.1-service-qti.xml \
    $(DEVICE_PATH)/vintf/android.hardware.wifi@1.0-service.xml \
    $(DEVICE_PATH)/vintf/android.hardware.wifi.hostapd.xml \
    $(DEVICE_PATH)/vintf/manifest_android.hardware.drm@1.3-service.clearkey.xml \
    $(DEVICE_PATH)/vintf/manifest_android.hardware.drm@1.3-service.widevine.xml \
    $(DEVICE_PATH)/vintf/vendor.qti.gnss@4.0-service.xml \
    $(DEVICE_PATH)/vintf/vendor.qti.hardware.vibrator.service.xml

# VNDK: enable VNDK packaging so the system ships com.android.vndk.v30 (see
# PRODUCT_EXTRA_VNDK_VERSIONS in device.mk) for the stock Android 11 vendor.
BOARD_VNDK_VERSION := current

# Disable CAF audio building (prebuilt audio stack in proprietary vendor)
AUDIO_FEATURE_ENABLED_G711 := false
TARGET_USES_QCOM_MM_AUDIO := false
BOARD_USES_QCOM_AUDIO := false

# Explicitly set kernel modules to load into vendor/lib/modules/modules.load
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(TARGET_OUT_VENDOR)/lib/modules/audio_apr.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/pronto_wlan.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_q6_notifier.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_adsp_loader.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_q6.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_usf.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_pinctrl_wcd.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_swr.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_wcd_core.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_swr_ctrl.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_wsa881x.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_wsa881x_analog.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_platform.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_cpe_lsm.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_hdmi.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_stub.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_wcd9xxx.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_mbhc.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_wcd9335.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_wcd_cpe.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_digital_cdc.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_analog_cdc.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_native.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_machine_sdm450.ko \
    $(TARGET_OUT_VENDOR)/lib/modules/audio_machine_ext_sdm450.ko
