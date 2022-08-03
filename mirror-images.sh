#!/bin/bash
set -eu -o pipefail

REGISTRY=$(oc get route nexus-docker -n devsecops -o jsonpath --template='{.spec.host}')

NEXUS_USER=ploigos
NEXUS_PASS=$(oc get secret ploigos-service-account-credentials -n devsecops -o jsonpath --template='{.data.password}' | base64 -d)

IMAGES_TO_COPY=("docker.io/hashicorp/vault-k8s:0.16.1" \
                "docker.io/hashicorp/vault:1.10.3" \
                "ghcr.io/external-secrets/external-secrets:v0.5.6" \
                "registry.access.redhat.com/ubi8/openjdk-11:latest" \
                "quay.io/ploigos/ploigos-github-runner:latest")

for IMAGES in ${!IMAGES_TO_COPY[@]}; do
    SRC_IMAGE=${IMAGES_TO_COPY[$IMAGES]}
    DEST_IMAGE=$(echo ${SRC_IMAGE} | awk -v reg=${REGISTRY} -F '/' '{ print reg"/ploigos/"$3 }')
    echo "Copying ${SRC_IMAGE} to ${DEST_IMAGE} using Skopeo..."
    skopeo copy --dest-username=${NEXUS_USER} --dest-password=${NEXUS_PASS} docker://${SRC_IMAGE} docker://${DEST_IMAGE}
done
