# Native Device Tree for Cat S22 Flip (`device/cat/s22flip`)

- **Target Architecture**: ARM32 userland with 64-bit binder (`armv7-a-neon` on MSM8937 / QM215).
- **Target OS**: Android 12 (LineageOS 19.1 / AOSP).
- **Scaffold Base**: Mithorium / MSM8937 Android 12 common HAL abstractions and SELinux policies.
- **Hardware Profile Source**: 100% authentic stock files extracted from `/home/aju/Android/01_Firmware_Backups/final/vendor.img`.

---

## Hardware Component Alignment

| Subsystem | Stock Source Used | Description |
| :--- | :--- | :--- |
| **Audio** | `etc/audio_*.xml`, `mixer_paths*.xml` | Stock Cat S22 audio configs, Awinic AW8896 smart amp mixer paths, internal codec profiles. Xiaomi mixers removed. |
| **Media & Codecs** | `etc/media_codecs*.xml`, `media_profiles*.xml` | Native Qualcomm MSM8937 hardware decoders/encoders and camera profiles matching Cat S22. |
| **GPS / GNSS** | `etc/gps.conf`, `flp.conf`, `izat.conf`, `lowi.conf`, `xtwifi.conf` | Native Qualcomm location daemon configs. |
| **Wi-Fi & Bluetooth** | `etc/wifi/WCNSS_qcom_cfg.ini`, `wpa_supplicant_overlay.conf` | Stock Qualcomm Prima / WCNSS driver configurations. |
| **Thermal** | `etc/thermal-engine.conf` | Stock Cat S22 battery charging & CPU frequency thermal profiles. |
| **Keylayout** | `system/usr/keylayout/gpio-keys.kl`, `qwerty.kl`, `qpnp_pon.kl` | Physical keypad matrix, D-pad navigation, Hall flip switch, and PTT side-button definitions. |
| **VINTF Manifest** | `etc/vintf/manifest.xml` | Official target-level 4 HIDL HAL manifest from Cat S22 vendor. |
| **Init & Properties** | `init/init_s22flip.cpp`, `vendor.prop` | Model `S22 FLIP`, Brand `Cat`, Device `s22flip`, low-RAM 2GB Dalvik heap parameters. |
| **Display Overlay** | `overlay/frameworks/base/core/res/` | Portrait flip 480x640 resolution, 240 DPI, software navigation bar disabled (`config_showNavigationBar=false`), flip-close sleep enabled (`config_lidControlsSleep=true`). |

---

## Build Targets
- `AndroidProducts.mk`: Exposes `lineage_s22flip-userdebug`, `lineage_s22flip-user`, and `lineage_s22flip-eng`.
- `lineage_s22flip.mk`: Official LineageOS phone product specification.
- `BoardConfig.mk`: Complete hardware abstraction definition with kernel header v2 and retrofit dynamic partition support.
- `extract-files.sh` & `proprietary-files.txt`: 2,922 tracked blobs ready for clean vendor extraction.
