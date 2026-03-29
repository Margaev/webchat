#!/bin/sh
set -o errexit

REGISTRY_NAME="${REGISTRY_NAME:-kind-registry}"
REGISTRY_PORT="${REGISTRY_PORT:-5001}"
CLUSTER_NAME="${CLUSTER_NAME:-kind}"

# 1. Delete the Kind cluster
if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Deleting Kind cluster: ${CLUSTER_NAME}..."
  kind delete cluster --name "${CLUSTER_NAME}"
else
  echo "Kind cluster '${CLUSTER_NAME}' not found, skipping."
fi

# 2. Stop and remove the registry container
if [ "$(docker ps -aq -f name=^/${REGISTRY_NAME}$)" ]; then
  echo "Removing registry container: ${REGISTRY_NAME}..."
  docker rm -f "${REGISTRY_NAME}"
else
  echo "Registry container '${REGISTRY_NAME}' not found, skipping."
fi

# 3. Clean up the Docker network if it exists
# Kind usually names the network after the cluster
if docker network inspect "${CLUSTER_NAME}" >/dev/null 2>&1; then
  echo "Removing docker network: ${CLUSTER_NAME}..."
  docker network rm "${CLUSTER_NAME}"
fi
