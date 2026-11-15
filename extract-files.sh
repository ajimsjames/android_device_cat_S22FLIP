#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
#
# Extraction script for Cat S22 Flip (Bullitt QM215 / MSM8937)
#

set -e

DEVICE=s22flip
VENDOR=cat

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

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KEXEC=false
SECTION=
SRC=

while [ "$#" -gt 0 ]; do
    case "$1" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kexec )
                KEXEC=true
                ;;
        -s | --section )
                shift
                SECTION="$1"
                ;;
        * )
                SRC="$1"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# Initialize the helper for device
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KEXEC}"

"${MY_DIR}/setup-makefiles.sh"
