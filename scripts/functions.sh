#!/usr/bin/env bash

echoerr() { echo "$@" 1>&2; }

cauldron_command_exec() {
  COMMAND="$1"
  echoerr "COMMAND: ${COMMAND}"
  IGNORE_DRY_RUN_MODE="$2"

  if [[ -z "${CAULDRON_DRY_RUN}" ]]; then
    eval "${COMMAND}"
  else
    if [[ -z "${IGNORE_DRY_RUN_MODE}" ]]; then
      echo "Didn't execute COMMAND because of CAULDRON_DRY_RUN env var is set"
    else
      eval "${COMMAND}"
    fi
  fi
}

cauldron_command_exec_with_dryrun_ignore() {
  cauldron_command_exec "$1" 1
}

