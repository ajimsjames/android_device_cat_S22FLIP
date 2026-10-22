#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Device PATH
DEVICE_PATH := device/cat/S22FLIP

# VINTF Kernel enforcement
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

# Inherit proprietary vendor files
$(call inherit-product, vendor/cat/S22FLIP/S22FLIP-vendor.mk)

# Inherit Dalvik configs for 2GB Go configuration
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# Init scripts
PRODUCT_PACKAGES += \
    init.cat.rc \
    init.qcom.rc \
    init.qcom.usb.rc \
    init.target.rc

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.qcom \
    $(DEVICE_PATH)/rootdir/etc/init.cat.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.cat.rc \
    $(DEVICE_PATH)/rootdir/etc/init.qcom.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.qcom.rc \
    $(DEVICE_PATH)/rootdir/etc/init.qcom.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.qcom.usb.rc \
    $(DEVICE_PATH)/rootdir/etc/init.target.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.target.rc

# Ax Kernel Manager configuration
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/kernel/ax_kernel_manager.xml:$(TARGET_COPY_OUT_VENDOR)/etc/ax_kernel_manager.xml

# Device Properties
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Screen resolution / density (Main: 480x640, Cover: 128x128)
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := mdpi

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# VINTF Compatibility
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    hardware/qcom-caf/common/vendor_framework_compatibility_matrix.xml

# VINTF Fragments
DEVICE_MANIFEST_FILE += \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.camera.provider-service.lineage.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.cas@1.2-service.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.drm-service.clearkey.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.gnss@2.1-service-qti.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.health-service.qti.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.radio.config@1.1-service.wrapper.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.usb.gadget-service.qti.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.usb@1.3-service.basic.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.wifi-service.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.wifi.hostapd.xml \
    $(DEVICE_PATH)/vintf/manifest/android.hardware.wifi.supplicant.xml \
    $(DEVICE_PATH)/vintf/manifest/bluetooth_audio.xml \
    $(DEVICE_PATH)/vintf/manifest/dumpstate-s22flip.xml \
    $(DEVICE_PATH)/vintf/manifest/manifest_android.hardware.drm@1.3-service.widevine.xml \
    $(DEVICE_PATH)/vintf/manifest/memtrack_qti.xml \
    $(DEVICE_PATH)/vintf/manifest/power.xml \
    $(DEVICE_PATH)/vintf/manifest/radio-compat.xml \
    $(DEVICE_PATH)/vintf/manifest/vendor.lineage.health-service.default.xml \
    $(DEVICE_PATH)/vintf/manifest/vendor.lineage.livedisplay-service.sysfs-ab.xml \
    $(DEVICE_PATH)/vintf/manifest/vendor.lineage.livedisplay-service.sysfs-ce.xml \
    $(DEVICE_PATH)/vintf/manifest/vendor.qti.gnss@4.0-service.xml \
    $(DEVICE_PATH)/vintf/manifest/vendor.qti.hardware.vibrator.service.xml

# Injected Host ADB Keys & Debug on Boot
PRODUCT_PACKAGES += \
    adb_keys

PRODUCT_ADB_KEYS := $(DEVICE_PATH)/rootdir/etc/adb_keys
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/adb_keys:root/adb_keys

# Force ADB on boot
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.adb.secure=0 \
    persist.sys.usb.config=adb \
    persist.service.adb.enable=1
