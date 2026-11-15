#
# Copyright (C) 2026 The LineageOS Project
#
# Unified device.mk for Cat S22 Flip (Bullitt QM215 / MSM8937)
# Merged from Mithorium Common + Cat S22 Flip Hardware Specs
#

DEVICE_PATH := device/cat/s22flip

# -----------------------------------------------------------------------------
# Base Product Configurations
# -----------------------------------------------------------------------------
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# -----------------------------------------------------------------------------
# Screen & Boot Animation (Cat S22 Flip: 480 x 640 portrait flip)
# -----------------------------------------------------------------------------
TARGET_SCREEN_HEIGHT := 640
TARGET_SCREEN_WIDTH := 480
TARGET_SCREEN_DENSITY := 240

# -----------------------------------------------------------------------------
# Dynamic Partitions (Retrofit Dynamic Partitions)
# -----------------------------------------------------------------------------
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# PRODUCT_RETROFIT_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := false

# -----------------------------------------------------------------------------
# Overlays (Frameworks, SystemUI, Settings, Keypad)
# -----------------------------------------------------------------------------
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlay \
    $(DEVICE_PATH)/overlay-lineage

PRODUCT_PACKAGES += \

# -----------------------------------------------------------------------------
# Audio (Qualcomm HAL + Awinic AW8896 + Policy)
# -----------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/audio/,$(TARGET_COPY_OUT_VENDOR)/etc/)

# -----------------------------------------------------------------------------
# Keylayouts (Cat S22 Flip Physical Keypad, GPIO Keys, PTT Button)
# -----------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/keylayout/gpio-keys.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/gpio-keys.kl \
    $(DEVICE_PATH)/keylayout/qwerty.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/qwerty.kl

# -----------------------------------------------------------------------------
# Thermal & GPS & Wi-Fi
# -----------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/thermal/,$(TARGET_COPY_OUT_VENDOR)/etc/) \
    $(call find-copy-subdir-files,*.conf,$(DEVICE_PATH)/gps/etc/,$(TARGET_COPY_OUT_VENDOR)/etc/) \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/wifi/,$(TARGET_COPY_OUT_VENDOR)/etc/wifi/)

# -----------------------------------------------------------------------------
# Media Codecs
# -----------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/media/,$(TARGET_COPY_OUT_VENDOR)/etc/)

# -----------------------------------------------------------------------------
# Cat S22 Flip Hardware Services (Outer Display Daemon)
# -----------------------------------------------------------------------------
PRODUCT_PACKAGES += \

# -----------------------------------------------------------------------------
# Low-RAM Optimization Properties (2GB Physical RAM)
# -----------------------------------------------------------------------------
PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=240 \
    ro.config.low_ram=true \
    ro.config.avoid_gfx_accel=false \
    ro.surface_flinger.supports_background_blur=0 \
    ro.sf.blurs_are_expensive=1 \
    persist.sys.sf.disable_blurs=1 \
    debug.sf.disable_backpressure=1 \
    ro.config.max_starting_bg=4 \
    dalvik.vm.heapgrowthlimit=128m \
    dalvik.vm.heapsize=256m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=4m \
    ro.statsd.enable=false \
    ro.telephony.default_network=9 \
    persist.vendor.radio.custom_ecc=1 \
    ro.ambient_display.feature_enabled=false \
    persist.dbg.volte_avail_ovr=1 \
    persist.dbg.vt_avail_ovr=1 \
    persist.dbg.wfc_avail_ovr=1

# Exclude NFC and fingerprint (Cat S22 Flip has no NFC / Fingerprint hardware)
TARGET_USES_NFC := false
TARGET_USES_NQ_NFC := false
$(call inherit-product, vendor/cat/s22flip/s22flip-vendor.mk)
PRODUCT_PACKAGES += init.recovery.qcom.rc

# -----------------------------------------------------------------------------
# Vendor Properties
# (ro.boot.dynamic_partitions is already emitted by build/make/core/main.mk
#  from PRODUCT_USE_DYNAMIC_PARTITIONS, so it must not be duplicated here.)
# -----------------------------------------------------------------------------
VENDOR_SECURITY_PATCH := 2022-03-05
PRODUCT_VENDOR_PROPERTIES += \
    ro.product.first_api_level=29

# -----------------------------------------------------------------------------
# VNDK: vendor is the stock Android 11 image (ro.vndk.version=30) running under
# an Android 12 system, so the system must ship the VNDK v30 APEX.
# -----------------------------------------------------------------------------
PRODUCT_EXTRA_VNDK_VERSIONS := 30

# Essential HALs and system services
PRODUCT_PACKAGES += \
    vndservicemanager \
    libmediautils_vendor

# System Ext Privapp Permissions
PRODUCT_COPY_FILES += \
    device/cat/s22flip/permissions/privapp-permissions-lineage.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-lineage.xml



# Cat S22 Flip hardware daemons (outer screen, keypad debounce, hall sensor)
PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)

PRODUCT_PACKAGES += \
    keypad_debounce_clean \
    cat_hall_keylight \
    cat_hall_wake \
    cat_boot_display \
    cat_watchdog \
    outerscreen_service

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/cat_hardware.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/cat_hardware.rc \
    $(DEVICE_PATH)/rootdir/bin/cat_perf.sh:$(TARGET_COPY_OUT_SYSTEM_EXT)/bin/cat_perf.sh \
    $(DEVICE_PATH)/rootdir/etc/fstab.qcom:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom
