#
# Copyright (C) 2026 The LineageOS Project
#
# LineageOS product definition for Cat S22 Flip (Bullitt QM215 / MSM8937)
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Explicitly ensure 32-bit zygote on this 32-bit ARM device
PRODUCT_VENDOR_PROPERTIES += ro.zygote=zygote32
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.zygote=zygote32

# Inherit from Cat S22 Flip device makefile
$(call inherit-product, device/cat/s22flip/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Include GApps
WITH_GMS := true

# Include TT9 keyboard, Power HAL, and Lights HAL
PRODUCT_PACKAGES += TT9 android.hardware.power@1.0-service android.hardware.light@2.0-service

# Reduce main-thread overhead and limit background apps
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.strictmode.disable=true \
    ro.vendor.qti.sys.fw.bg_apps_limit=12 \
    ro.lmk.use_minfree_levels=true

PRODUCT_NAME := lineage_s22flip
PRODUCT_DEVICE := s22flip
PRODUCT_MANUFACTURER := Cat
PRODUCT_BRAND := Cat
PRODUCT_MODEL := S22 Flip

PRODUCT_GMS_CLIENTID_BASE := android-bullitt

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=s22flip \
    TARGET_DEVICE=s22flip
