#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${CAULDRON_PATH}/scripts/functions.sh"

cauldron_kubectl_prefix_with_namespace() {
  if [[ -z "${CAULDRON_KUBECTL_NAMESPACE}" ]]; then
      debug "Using current k8s namespace as K8S_NAMESPACE env var is not set"
      PREFIX=""
  else
      PREFIX=" -n ${CAULDRON_KUBECTL_NAMESPACE}"
  fi

  echo "kubectl${PREFIX}"
}

cauldron_kubectl_command_exec() {
  KUBECTL_COMMAND_PREFIX=$(cauldron_kubectl_prefix_with_namespace)
  cauldron_command_exec "${KUBECTL_COMMAND_PREFIX} $1"
}

cauldron_kubectl_command_exec_with_dryrun_ignore() {
  KUBECTL_COMMAND_PREFIX=$(cauldron_kubectl_prefix_with_namespace)
  cauldron_command_exec "${KUBECTL_COMMAND_PREFIX} $1" 1
}
