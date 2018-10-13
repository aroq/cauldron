#!/usr/bin/env bash

POD=$(kubectl get pod -n "${SERVICES_ZEBRA_NAMESPACE}" -l component="${SERVICES_ZEBRA_NAMESPACE}-jenkins-master" -o jsonpath='{.items[0].metadata.name}')

kubectl cp "${SERVICES_ZEBRA_NAMESPACE}/${POD}:/var/jenkins_home/zebra/user_token" jenkins_user_token

JENKINS_AUTH_TOKEN=${JENKINS_AUTH_USER}:$(cat jenkins_user_token)
export JENKINS_AUTH_TOKEN

JENKINS_HOST=${JENKINS_HOST:-$(kubectl get service "zebra-cd-${SERVICES_ZEBRA_ENVIRONMENT}-jenkins" -o jsonpath="{.spec.clusterIP}")}

scripts/jenkins.job.py

