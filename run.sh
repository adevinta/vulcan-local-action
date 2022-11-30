#!/bin/bash

# Copyright 2022 Adevinta

set -e

VL_ARGS=()
VL_HIDDEN_ARGS=()

# Setting log level
if [ -n "${LOG_LEVEL}" ]; then
    VL_ARGS+=("-l" "${LOG_LEVEL}")
fi

if [ -n "${INCLUDE}" ]; then
    VL_ARGS+=("-i" "${INCLUDE}")
fi

if [ -n "${EXCLUDE}" ]; then
    VL_ARGS+=("-e" "${EXCLUDE}")
fi

# Adding images
if [ -n "${TARGET_IMAGES}" ]; then
    for ELEM in ${TARGET_IMAGES}; do
        VL_ARGS+=("-t" "${ELEM}" "-a" "DockerImage")
    done
fi

# Scan paths as GitRepository
if [ -n "${TARGET_PATHS}" ]; then
    for ELEM in ${TARGET_PATHS}; do
        VL_ARGS+=("-t" "${ELEM}" "-a" "GitRepository")
    done
fi

# Add policies
if [ -n "${POLICIES}" ]; then
    for ELEM in ${POLICIES}; do
        VL_ARGS+=("-p" "${ELEM}")
    done
fi

# Add additional configs
if [ -n "${CONFIGS}" ]; then
    for ELEM in ${CONFIGS}; do
        VL_ARGS+=("-c" "${ELEM}")
    done
fi

# Add required variables
if [ -n "${VARS}" ]; then
    for ELEM in ${VARS}; do
        VL_HIDDEN_ARGS+=("-v" "${ELEM}")
    done
fi

if [ -n "${SCAN_REPO}" ]; then
    VL_ARGS+=("-t" "." "-a" "GitRepository")
fi

if [ -n "${REPORT_SEVERITY}" ]; then
    VL_ARGS+=("-s" "$REPORT_SEVERITY" )
fi

if [ "${USE_LOCAL_CONFIG}" == "true" ]; then
    if [ -f "${LOCAL_CONFIG}" ]; then   # local not an url.
        VL_ARGS+=("-c" "$LOCAL_CONFIG" )
    fi
fi

# Create a temp directory for the report
TMPD=$(mktemp -d)
OUTPUT_REPORT="$TMPD/report.json"
VL_ARGS+=("-r" "$OUTPUT_REPORT")

exit_status=0
echo "vulcan-local ${VL_ARGS[*]}"
vulcan-local "${VL_ARGS[@]}" "${VL_HIDDEN_ARGS[@]}"|| exit_status=$?

echo "report=$OUTPUT_REPORT" >> $GITHUB_OUTPUT
echo "status=$exit_status" >> $GITHUB_OUTPUT
