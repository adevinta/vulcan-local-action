#!/bin/bash

set -e

VL_ARGS=()

# Setting log level
if [ -n "${LOG_LEVEL}" ]; then
    VL_ARGS+=("-l" "${LOG_LEVEL}")
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
vulcan-local "${VL_ARGS[@]}" || exit_status=$?

echo "::set-output name=report::$OUTPUT_REPORT"
echo "::set-output name=status::$exit_status"
