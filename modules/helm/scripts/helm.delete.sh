#!/usr/bin/env bash

helm status "${HELM_DELETE_RELEASE_NAME}" && helm delete --purge "${HELM_DELETE_RELEASE_NAME}" || :
