#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/cat/S22FLIP

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a53


# Platform
TARGET_BOARD_PLATFORM := msm8937
BOARD_VENDOR := cat

# Bootloader / Kernel
TARGET_NO_BOOTLOADER := true
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200,n8 androidboot.console=ttyMSM0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 earlycon=msm_hsl_uart,0x78af000 loop.max_part=7 panic=1
BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_KERNEL_ARCH := arm64
TARGET_PREBUILT_KERNEL := device/cat/S22FLIP-kernel/Image.gz
BOARD_PREBUILT_DTBOIMAGE := device/cat/S22FLIP-kernel/dtbo.img
TARGET_PREBUILT_DTB := device/cat/S22FLIP-kernel/dtb.img
TARGET_KERNEL_HEADER_ARCH := arm64
BOARD_BOOTIMG_HEADER_VERSION := 0

# Partitions
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_CACHEIMAGE_PARTITION_SIZE := 69206016
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4

# A/B Configuration (Cat S22 Flip is non-A/B with dedicated recovery partition)
AB_OTA_UPDATER := false

# Dynamic Partitions
BOARD_SUPER_PARTITION_SIZE := 3095396352
BOARD_SUPER_PARTITION_GROUPS := google_system_dynamic_partitions
BOARD_GOOGLE_SYSTEM_DYNAMIC_PARTITIONS_SIZE := 3091202048 # (BOARD_SUPER_PARTITION_SIZE - 4MB for metadata)
BOARD_GOOGLE_SYSTEM_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom
BOARD_INCLUDE_RECOVERY_DTBO := true

# Treble & VNDK
BOARD_VNDK_VERSION := current

# VINTF Manifests
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/vintf/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/vintf/compatibility_matrix.xml

# Inherit proprietary vendor blob definitions
include vendor/cat/S22FLIP/BoardConfigVendor.mk
TARGET_SUPPORTS_64_BIT_APPS := true

# Build broken rules for vendor prebuilt binaries/libraries copied via PRODUCT_COPY_FILES
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true

# File system config generator for vendor AIDs and capabilities
TARGET_FS_CONFIG_GEN := $(DEVICE_PATH)/config.fs
