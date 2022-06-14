#!/bin/bash

set -eux -o pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
START_DIR=$(pwd)

MIN_REQUIRED_HELM_VERSION=3.6

# Do work in a temporary directory
TEMP_DIR=$(mktemp -d)
cd ${TEMP_DIR}

# Check for Helm
echo "Checking for Helm CLI version ${MIN_REQUIRED_HELM_VERSION} or greater"
set +e
HELM_VERSION_TEXT=$(helm version)
HELM_VERSION_RETURN_CODE=$?
set -e
if [ ${HELM_VERSION_RETURN_CODE} != 0 ]; then
  echo "SCRIPT FAILED! - You must have helm cli version ${MIN_REQUIRED_HELM_VERSION} or greater installed to run this script"
  exit 1
fi
# Maybe someday check actual Helm version number

# Clean up the temporary directory
cd ${START_DIR}
