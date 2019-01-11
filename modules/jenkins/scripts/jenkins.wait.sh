#!/usr/bin/env bash

JENKINS_HOST=${JENKINS_HOST:-$(kubectl -n "${SERVICES_ZEBRA_NAMESPACE}" get service "${SERVICES_ZEBRA_NAMESPACE}-jenkins" -o jsonpath="{.spec.clusterIP}")}
echo "JENKINS_HOST: $JENKINS_HOST"
export JENKINS_HOST

JENKINS_PORT=${JENKINS_PORT:-8080}
export JENKINS_PORT

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://${JENKINS_HOST}:${JENKINS_PORT}/login)" != "200" ]]; do sleep 5; done
