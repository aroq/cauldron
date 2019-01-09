#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${CAULDRON_PATH}/modules/kubectl/scripts/functions.sh"

# TODO: set proper condition with name, etc.
COMMAND="get rs --selector=${CAULDRON_KUBECTL_SELECTOR} -o jsonpath='{.items[?(@.spec.replicas==1)].metadata.name}'"

K8S_RS_NAME=$(cauldron_kubectl_command_exec_with_dryrun_ignore "${COMMAND}")
info "K8S_RS_NAME: ${K8S_RS_NAME}"; echo

cauldron_kubectl_command_exec "scale rs ${K8S_RS_NAME} --replicas 0"; echo; sleep 5
cauldron_kubectl_command_exec "scale rs ${K8S_RS_NAME} --replicas 1"

