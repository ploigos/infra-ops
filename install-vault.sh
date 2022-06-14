#!/bin/bash

set -eux -o pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
START_DIR=$(pwd)

# Do work in a temporary directory
TEMP_DIR=$(mktemp -d)
cd ${TEMP_DIR}

# Clean up the temporary directory
pwd
cd ${START_DIR}
pwd
