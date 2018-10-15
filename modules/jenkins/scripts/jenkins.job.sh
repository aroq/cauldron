#!/usr/bin/env bash

JENKINS_HOST=${JENKINS_HOST:-$(kubectl -n "${SERVICES_ZEBRA_NAMESPACE}" get service "${SERVICES_ZEBRA_NAMESPACE}-jenkins" -o jsonpath="{.spec.clusterIP}")}
echo "JENKINS_HOST: $JENKINS_HOST"
export JENKINS_HOST

JENKINS_PORT="8080"
export JENKINS_PORT

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://${JENKINS_HOST}:${JENKINS_PORT}/login)" != "200" ]]; do sleep 5; done

sleep 15

POD=$(kubectl get pod -n "${SERVICES_ZEBRA_NAMESPACE}" -l component="${SERVICES_ZEBRA_NAMESPACE}-jenkins-master" -o jsonpath='{.items[0].metadata.name}')
echo "POD: $POD"

JENKINS_AUTH_TOKEN="${JENKINS_AUTH_USER}:$(kubectl -n ${SERVICES_ZEBRA_NAMESPACE} exec ${POD} cat /var/jenkins_home/zebra/user_token)"
export JENKINS_AUTH_TOKEN

eval "${CAULDRON_PATH}/modules/jenkins/scripts/jenkins.job.py"

