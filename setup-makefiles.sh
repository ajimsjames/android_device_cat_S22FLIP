#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
#
# Setup makefiles script for Cat S22 Flip (Bullitt QM215 / MSM8937)
#

set -e

DEVICE=s22flip
VENDOR=cat

INITIAL_COPYRIGHT_YEAR=2026

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Initialize the helper for device
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

# Write makefiles for proprietary blobs
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers
