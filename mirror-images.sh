#!/bin/bash
set -eux -o pipefail

REGISTRY=$(oc get route nexus-docker -n devsecops -o jsonpath --template='{.spec.host}')

NEXUS_USER=ploigos
NEXUS_PASS=$(oc get secret ploigos-service-account-credentials -n devsecops -o yaml | yq .data.password | base64 -d)

VAULT_K8S_IMAGE_SRC="docker.io/hashicorp/vault-k8s:0.16.1"
VAULT_K8S_IMAGE_DEST="${REGISTRY}/ploigos/vault-k8s:0.16.1"
skopeo copy --dest-username=${NEXUS_USER} --dest-password=${NEXUS_PASS} docker://${VAULT_K8S_IMAGE_SRC} docker://${VAULT_K8S_IMAGE_DEST}

VAULT_IMAGE_IMAGE_SRC="docker.io/hashicorp/vault:1.10.3"
VAULT_IMAGE_IMAGE_DEST="${REGISTRY}/ploigos/vault:1.10.3"
skopeo copy --dest-username=${NEXUS_USER} --dest-password=${NEXUS_PASS} docker://${VAULT_K8S_IMAGE_SRC} docker://${VAULT_K8S_IMAGE_DEST}

EXTERNAL_SECRETS_IMAGE_SRC="ghcr.io/external-secrets/external-secrets:v0.5.6"
EXTERNAL_SECRETS_IMAGE_DEST="${REGISTRY}/ploigos/external-secrets:v0.5.6"
skopeo copy --dest-username=${NEXUS_USER} --dest-password=${NEXUS_PASS} docker://${EXTERNAL_SECRETS_IMAGE_SRC} docker://${EXTERNAL_SECRETS_IMAGE_DEST}

OPENJDK_IMAGE_SRC="registry.access.redhat.com/ubi8/openjdk-11:latest"
OPENJDK_IMAGE_DEST="${REGISTRY}/ploigos/openjdk-11:latest"
skopeo copy --dest-username=${NEXUS_USER} --dest-password=${NEXUS_PASS} docker://${OPENJDK_IMAGE_SRC} docker://${OPENJDK_IMAGE_DEST}

RUNNER_IMAGE_SRC="quay.io/ploigos/ploigos-github-runner:latest"
RUNNER_IMAGE_DEST="${REGISTRY}/ploigos/ploigos-github-runner:latest"
skopeo copy --dest-username=${NEXUS_USER} --dest-password=${NEXUS_PASS} docker://${RUNNER_IMAGE_SRC} docker://${RUNNER_IMAGE_DEST}

