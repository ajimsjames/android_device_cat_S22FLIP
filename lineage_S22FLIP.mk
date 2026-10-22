$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from core products
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile
$(call inherit-product, device/cat/S22FLIP/device.mk)

# AxionOS flags
TARGET_DISABLE_EPPE := true
TARGET_INCLUDE_AXFX := true

# AxionOS Device Properties
AXION_MAINTAINER := aju
AXION_PROCESSOR := Snapdragon_215
AXION_CAMERA_REAR_INFO := 5
AXION_CAMERA_FRONT_INFO := 2

# Inherit common Lineage / Axion configurations
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Boot animation & screen dimensions
TARGET_SCREEN_HEIGHT := 640
TARGET_SCREEN_WIDTH := 480

# Device identifier
PRODUCT_NAME := lineage_S22FLIP
PRODUCT_DEVICE := S22FLIP
PRODUCT_BRAND := Cat
PRODUCT_MODEL := S22 FLIP
PRODUCT_MANUFACTURER := Cat

PRODUCT_GMS_CLIENTID_BASE := android-bullitt

PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceProduct="S22FLIP" \
    DeviceName="S22FLIP" \
    BuildDesc="S22FLIP-user 16 release-keys" \
    BuildFingerprint="Cat/S22FLIP/S22FLIP:16/release-keys"
