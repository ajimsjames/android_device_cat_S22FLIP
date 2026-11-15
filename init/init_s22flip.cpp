/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * Init handler for Cat S22 Flip (Bullitt QM215 / MSM8937)
 */

#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include <android-base/properties.h>
#include "property_service.h"

namespace android {
namespace init {

void property_override(char const prop[], char const value[]) {
    prop_info *pi = (prop_info *)__system_property_find(prop);
    if (pi)
        __system_property_update(pi, value, strlen(value));
    else
        __system_property_add(prop, strlen(prop), value, strlen(value));
}

void vendor_load_properties() {
    property_override("ro.product.model", "S22 FLIP");
    property_override("ro.product.brand", "Cat");
    property_override("ro.product.manufacturer", "Cat");
    property_override("ro.product.device", "s22flip");
    property_override("ro.build.product", "s22flip");
    property_override("ro.product.name", "s22flip");

    property_override("ro.vendor.build.fingerprint", "Cat/S22FLIP/S22FLIP:11/RKQ1.210416.002/LTE_S02113.11_N_S22Flip_0.029.04:user/release-keys");
}

} // namespace init
} // namespace android
