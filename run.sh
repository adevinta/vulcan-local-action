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
for ELEM in ${TARGET_IMAGES}; do
    VL_ARGS+=("-t" "${ELEM}" "-a" "DockerImage")
done

# Scan paths as GitRepository
for ELEM in ${TARGET_PATHS}; do
    VL_ARGS+=("-t" "${ELEM}" "-a" "GitRepository")
done

# Add policies
for ELEM in ${POLICIES}; do
    VL_ARGS+=("-p" "${ELEM}")
done

# Add additional configs
for ELEM in ${CONFIGS}; do
    VL_ARGS+=("-c" "${ELEM}")
done

# Add additional configs
for ELEM in ${CHECKTYPES}; do
    VL_ARGS+=("-checktypes" "${ELEM}")
done

# Add required variables
for ELEM in ${VARS}; do
    VL_HIDDEN_ARGS+=("-v" "${ELEM}")
done

if [ -n "${REPORT_SEVERITY}" ]; then
    VL_ARGS+=("-s" "$REPORT_SEVERITY" )
fi

if [ "${USE_LOCAL_CONFIG}" == "true" ]; then
    if [ -f "${LOCAL_CONFIG}" ]; then   # local not an url.
        VL_ARGS+=("-c" "$LOCAL_CONFIG" )
    fi
fi

for ELEM in ${EXTRA_ARGS}; do
    VL_ARGS+=("${ELEM}")
done

# Create a temp directory for the report
TMPD=$(mktemp -d)
OUTPUT_REPORT="$TMPD/report.json"
VL_ARGS+=("-r" "$OUTPUT_REPORT")

exit_status=0
echo "vulcan-local ${VL_ARGS[*]}"
vulcan-local "${VL_ARGS[@]}" "${VL_HIDDEN_ARGS[@]}" || exit_status=$?
echo "exit_status=$exit_status"

echo "report=$OUTPUT_REPORT" >> "$GITHUB_OUTPUT"
echo "status=$exit_status" >> "$GITHUB_OUTPUT"

# In case of error vulcan-local exits with 1, and in this case here we hide it.
break=0
case $BREAK_SEVERITY in 
    CRITICAL)
        if [ $exit_status -ge 104 ]; then break=1; fi
        ;;
    HIGH)
        if [ $exit_status -ge 103 ]; then break=1; fi
        ;;
    MEDIUM)
        if [ $exit_status -ge 102 ]; then break=1; fi
        ;;
    LOW)
        if [ $exit_status -ge 101 ]; then break=1; fi
        ;;
    NEVER)
        ;;
    *)
        echo "invalid break-severity: $BREAK_SEVERITY"
esac

if [ $break == 1 ]; then
    echo "Failing because of findings higher/equal than $BREAK_SEVERITY"
    exit 1
fi
