#
# Copyright (C) 2017-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifneq ($(filter Mi8917 Mi8937 Mi439 s22flip,$(TARGET_DEVICE)),)

include $(call all-makefiles-under,$(LOCAL_PATH))

include $(CLEAR_VARS)

#A/B builds require us to create the mount points at compile time.
#Just creating it for all cases since it does not hurt.
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
DSP_MOUNT_POINT := $(TARGET_OUT_VENDOR)/dsp
ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_MOUNT_POINT) \
				 $(DSP_MOUNT_POINT)
$(FIRMWARE_MOUNT_POINT):
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt

$(DSP_MOUNT_POINT):
	@echo "Creating $(DSP_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/dsp

IMS_LIBS := libimscamera_jni.so libimsmedia_jni.so

IMS_SYMLINKS := $(addprefix $(TARGET_OUT_SYSTEM_EXT_APPS_PRIVILEGED)/ims/lib/arm64/,$(notdir $(IMS_LIBS)))
$(IMS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "IMS lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /system_ext/lib64/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(IMS_SYMLINKS)

RFS_MSM_ADSP_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/adsp/
$(RFS_MSM_ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM ADSP folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/lpass $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/adsp $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_MSM_MPSS_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/mpss/
$(RFS_MSM_MPSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM MPSS folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/modem $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_MSM_SLPI_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/slpi/
$(RFS_MSM_SLPI_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM SLPI folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/slpi $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/slpi $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

ALL_DEFAULT_INSTALLED_MODULES += $(RFS_MSM_ADSP_SYMLINKS) $(RFS_MSM_MPSS_SYMLINKS) $(RFS_MSM_SLPI_SYMLINKS)

WCNSS_INI_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/WCNSS_qcom_cfg.ini
$(WCNSS_INI_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS config ini link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /vendor/etc/wifi/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_INI_SYMLINK)

EGL_32_SYMLINK := $(TARGET_OUT_VENDOR)/lib/libEGL_adreno.so
$(EGL_32_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 32-bit EGL symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

GLESv2_32_SYMLINK := $(TARGET_OUT_VENDOR)/lib/libGLESv2_adreno.so
$(GLESv2_32_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 32-bit GLESv2 symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

Q3DTOOLS_32_SYMLINK := $(TARGET_OUT_VENDOR)/lib/libq3dtools_adreno.so
$(Q3DTOOLS_32_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 32-bit Q3D Tools symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

EGL_64_SYMLINK := $(TARGET_OUT_VENDOR)/lib64/libEGL_adreno.so
$(EGL_64_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 64-bit EGL symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

GLESv2_64_SYMLINK := $(TARGET_OUT_VENDOR)/lib64/libGLESv2_adreno.so
$(GLESv2_64_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 64-bit GLESv2 symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

Q3DTOOLS_64_SYMLINK := $(TARGET_OUT_VENDOR)/lib64/libq3dtools_adreno.so
$(Q3DTOOLS_64_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 64-bit Q3DTools symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(EGL_32_SYMLINK) $(GLESv2_32_SYMLINK) $(Q3DTOOLS_32_SYMLINK) $(EGL_64_SYMLINK) $(GLESv2_64_SYMLINK) $(Q3DTOOLS_64_SYMLINK)

WCNSS_BIN_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/WCNSS_qcom_wlan_nv.bin
$(WCNSS_BIN_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS bin link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /mnt/vendor/persist/$(notdir $@) $@

WCNSS_DAT_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/WCNSS_wlan_dictionary.dat
$(WCNSS_DAT_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS dat link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /mnt/vendor/persist/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_INI_SYMLINK) $(WCNSS_BIN_SYMLINK) $(WCNSS_DAT_SYMLINK)

ifneq ($(TARGET_DEVICE),Mi439)
WCNSS_MAC_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/wlan_mac.bin
$(WCNSS_MAC_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS MAC bin link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /mnt/vendor/persist/$(notdir $@) $@
ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_MAC_SYMLINK)

CNE_LIBS := libvndfwk_detect_jni.qti.so
CNE_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/app/CneApp/lib/arm/,$(notdir $(CNE_LIBS)))
$(CNE_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CneApp lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /vendor/lib/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(CNE_SYMLINKS)



# Ensure modules.load is copied directly into vendor partition
VENDOR_MODULES_LOAD := $(TARGET_OUT_VENDOR)/lib/modules/modules.load
$(VENDOR_MODULES_LOAD): device/cat/s22flip/rootdir/etc/modules.load
	@echo "Copying modules.load: $@"
	@mkdir -p $(dir $@)
	$(hide) cp -f $< $@

ALL_DEFAULT_INSTALLED_MODULES += $(VENDOR_MODULES_LOAD)

# Additional RFS symlinks required for modem & dsp rfs subsystem
RFS_MDM_MPSS_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/mdm/mpss/
$(RFS_MDM_MPSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MDM MPSS folder structure: $@"
	@mkdir -p $@ $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/modem $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/mpss $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_APQ_GNSS_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/apq/gnss/
$(RFS_APQ_GNSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS APQ GNSS folder structure: $@"
	@mkdir -p $@ $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/modem $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/apq/gnss $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_MDM_ADSP_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/mdm/adsp/
$(RFS_MDM_ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MDM ADSP folder structure: $@"
	@mkdir -p $@ $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/lpass $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/adsp $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

ALL_DEFAULT_INSTALLED_MODULES += $(RFS_MDM_MPSS_SYMLINKS) $(RFS_APQ_GNSS_SYMLINKS) $(RFS_MDM_ADSP_SYMLINKS)


# Symlink firmware/wlanmdsp.otaupdate
WLANMDSP_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlanmdsp.otaupdate
$(WLANMDSP_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating wlanmdsp.otaupdate symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf /data/vendor/firmware/wlanmdsp.mbn $@

ALL_DEFAULT_INSTALLED_MODULES += $(WLANMDSP_SYMLINK)

# RFS root and remaining symlinks
RFS_ROOT_RULES := $(TARGET_OUT_VENDOR)/rfs/msm/mpss/root
$(RFS_ROOT_RULES): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating remaining RFS symlinks: $@"
	@mkdir -p $(TARGET_OUT_VENDOR)/rfs/msm/mpss $(TARGET_OUT_VENDOR)/rfs/msm/adsp $(TARGET_OUT_VENDOR)/rfs/msm/slpi $(TARGET_OUT_VENDOR)/rfs/apq/gnss $(TARGET_OUT_VENDOR)/rfs/mdm/mpss $(TARGET_OUT_VENDOR)/rfs/mdm/adsp
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/mpss $(TARGET_OUT_VENDOR)/rfs/msm/mpss/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/adsp $(TARGET_OUT_VENDOR)/rfs/msm/adsp/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/slpi $(TARGET_OUT_VENDOR)/rfs/msm/slpi/root

	$(hide) ln -sf /mnt/vendor/persist/rfs/apq/gnss $(TARGET_OUT_VENDOR)/rfs/apq/gnss/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/mpss $(TARGET_OUT_VENDOR)/rfs/mdm/mpss/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/adsp $(TARGET_OUT_VENDOR)/rfs/mdm/adsp/root
	@mkdir -p $(TARGET_OUT_VENDOR)/rfs/msm/cdsp $(TARGET_OUT_VENDOR)/rfs/msm/wpss $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp $(TARGET_OUT_VENDOR)/rfs/mdm/slpi $(TARGET_OUT_VENDOR)/rfs/mdm/tn $(TARGET_OUT_VENDOR)/rfs/mdm/wpss
	@mkdir -p $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/readonly $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/readonly/vendor $(TARGET_OUT_VENDOR)/rfs/msm/wpss/readonly $(TARGET_OUT_VENDOR)/rfs/msm/wpss/readonly/vendor
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/cdsp $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/cdsp $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/hlos
	$(hide) ln -sf /data/vendor/tombstones/rfs/cdsp $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/ramdumps
	$(hide) ln -sf /vendor/firmware_mnt $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/readonly/firmware
	$(hide) ln -sf /vendor/firmware $(TARGET_OUT_VENDOR)/rfs/msm/cdsp/readonly/vendor/firmware
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/wpss $(TARGET_OUT_VENDOR)/rfs/msm/wpss/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/wpss $(TARGET_OUT_VENDOR)/rfs/msm/wpss/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $(TARGET_OUT_VENDOR)/rfs/msm/wpss/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $(TARGET_OUT_VENDOR)/rfs/msm/wpss/hlos
	$(hide) ln -sf /data/vendor/tombstones/rfs/wpss $(TARGET_OUT_VENDOR)/rfs/msm/wpss/ramdumps
	$(hide) ln -sf /vendor/firmware_mnt $(TARGET_OUT_VENDOR)/rfs/msm/wpss/readonly/firmware
	$(hide) ln -sf /vendor/firmware $(TARGET_OUT_VENDOR)/rfs/msm/wpss/readonly/vendor/firmware
	@mkdir -p $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp/readonly $(TARGET_OUT_VENDOR)/rfs/mdm/slpi/readonly $(TARGET_OUT_VENDOR)/rfs/mdm/tn/readonly $(TARGET_OUT_VENDOR)/rfs/mdm/wpss/readonly
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/cdsp $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/cdsp $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp/hlos
	$(hide) ln -sf /data/vendor/tombstones/rfs/cdsp $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp/ramdumps
	$(hide) ln -sf /vendor/firmware_mnt $(TARGET_OUT_VENDOR)/rfs/mdm/cdsp/readonly/firmware
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/slpi $(TARGET_OUT_VENDOR)/rfs/mdm/slpi/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/slpi $(TARGET_OUT_VENDOR)/rfs/mdm/slpi/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/slpi/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/slpi/hlos
	$(hide) ln -sf /data/vendor/tombstones/rfs/slpi $(TARGET_OUT_VENDOR)/rfs/mdm/slpi/ramdumps
	$(hide) ln -sf /vendor/firmware_mnt $(TARGET_OUT_VENDOR)/rfs/mdm/slpi/readonly/firmware
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/tn $(TARGET_OUT_VENDOR)/rfs/mdm/tn/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/tn $(TARGET_OUT_VENDOR)/rfs/mdm/tn/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/tn/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/tn/hlos
	$(hide) ln -sf /data/vendor/tombstones/rfs/tn $(TARGET_OUT_VENDOR)/rfs/mdm/tn/ramdumps
	$(hide) ln -sf /vendor/firmware_mnt $(TARGET_OUT_VENDOR)/rfs/mdm/tn/readonly/firmware
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/wpss $(TARGET_OUT_VENDOR)/rfs/mdm/wpss/root
	$(hide) ln -sf /mnt/vendor/persist/rfs/mdm/wpss $(TARGET_OUT_VENDOR)/rfs/mdm/wpss/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/wpss/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $(TARGET_OUT_VENDOR)/rfs/mdm/wpss/hlos
	$(hide) ln -sf /data/vendor/tombstones/rfs/wpss $(TARGET_OUT_VENDOR)/rfs/mdm/wpss/ramdumps
	$(hide) ln -sf /vendor/firmware_mnt $(TARGET_OUT_VENDOR)/rfs/mdm/wpss/readonly/firmware


# Ensure exact 1:1 mirror of vendor/cat/s22flip/proprietary/vendor in $(TARGET_OUT_VENDOR)
ALL_DEFAULT_INSTALLED_MODULES += $(RFS_ROOT_RULES)

endif
endif
