#!/usr/bin/env bash

LOG_LEVELS=([0]="fatal" [1]="error" [2]="warn" [3]="info" [4]="debug" [5]="trace")

function log() {
  local LEVEL="${1}"
  shift
  if [ "${CAULDRON_LOG_LEVEL}" -ge "${LEVEL}" ]; then
    echo "[${LOG_LEVELS[$LEVEL]}]" "$@" 1>&2
  fi
}

function fatal() {
  log 0 "${1}"
}

function error() {
  log 1 "${1}"
}

function warn() {
  log 2 "${1}"
}

function info() {
  log 3 "${1}"
}

function debug() {
  log 4 "${1}"
}

function trace() {
  log 5 "${1}"
}

cauldron_command_exec() {
  local COMMAND="$1"
  local IGNORE_DRY_RUN_MODE="$2"

  info  "COMMAND: ${COMMAND}"
  debug "CAULDRON_DRY_RUN: ${CAULDRON_DRY_RUN}"
  debug "IGNORE_DRY_RUN_MODE: ${IGNORE_DRY_RUN_MODE}"

  if [[ -z "${CAULDRON_DRY_RUN}" ]]; then
    eval "${COMMAND}"
  else
    if [[ -z "${IGNORE_DRY_RUN_MODE}" ]]; then
      info "Didn't execute COMMAND because of CAULDRON_DRY_RUN env var is set"
    else
      eval "${COMMAND}"
    fi
  fi
}

cauldron_command_exec_with_dryrun_ignore() {
  cauldron_command_exec "$1" 1
}

