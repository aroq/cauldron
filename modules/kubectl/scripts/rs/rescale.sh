#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${CAULDRON_PATH/scripts/functions.sh}"

if [[ -z "${K8S_NAMESPACE}" ]]; then
    echo "Using current k8s namespace as K8S_NAMESPACE env var is not set"
    K8S_NAMESPACE=""
else
    K8S_NAMESPACE=" -n ${K8S_NAMESPACE}"
fi

KUBECTL_COMMAND_PREFIX="kubectl${K8S_NAMESPACE}"

echo "K8S_NAMESPACE: ${K8S_NAMESPACE}"

COMMAND="${KUBECTL_COMMAND_PREFIX} get rs -o jsonpath=\"{.items[?(@.spec.replicas==1)].metadata.name}\""

K8S_RS_NAME=$(cauldron_command_exec_with_dryrun_ignore "${COMMAND}")
echo "K8S_RS_NAME: ${K8S_RS_NAME}"
echo

cauldron_command_exec "${KUBECTL_COMMAND_PREFIX} scale rs ${K8S_RS_NAME} --replicas 0"
echo

sleep 5

cauldron_command_exec "${KUBECTL_COMMAND_PREFIX} scale rs ${K8S_RS_NAME} --replicas 1"

