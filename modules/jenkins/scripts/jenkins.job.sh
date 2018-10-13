#!/usr/bin/env bash

POD=$(kubectl get pod -n "${SERVICES_ZEBRA_NAMESPACE}" -l component="${SERVICES_ZEBRA_NAMESPACE}-jenkins-master" -o jsonpath='{.items[0].metadata.name}')

echo "POD: $POD"

JENKINS_AUTH_TOKEN="${JENKINS_AUTH_USER}:$(kubectl -n ${SERVICES_ZEBRA_NAMESPACE} exec ${POD} cat /var/jenkins_home/zebra/user_token)"
export JENKINS_AUTH_TOKEN

JENKINS_HOST=${JENKINS_HOST:-$(kubectl -n "${SERVICES_ZEBRA_NAMESPACE}" get service "zebra-cd-${SERVICES_ZEBRA_ENVIRONMENT}-jenkins" -o jsonpath="{.spec.clusterIP}")}

echo "JENKINS_HOST: $JENKINS_HOST"

eval "${CAULDRON_PATH}/modules/jenkins/scripts/jenkins.job.py"

