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

# Create vault project if needed
#set +e
#oc new-project vault
#set -e
#oc project vault

# Add the Helm repo for Vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Install Vault
helm install vault hashicorp/vault \
    --create-namespace \
    --wait \
    --set "global.openshift=true" \
    --set "server.dev.enabled=true"

# Configure Kubernetes authentication
oc exec -it vault-0 -- vault auth enable kubernetes
# Evaluate KUBERNETES_PORT_443_TCP_ADDR within the Pod
JWT=$(oc exec -it vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
oc exec -it vault-0 -- vault write auth/kubernetes/config \
                           token_reviewer_jwt=${JWT} \
                           kubernetes_host="https://openshift.default.svc.cluster.local:443" \
                           kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Clean up the temporary directory
cd ${START_DIR}
