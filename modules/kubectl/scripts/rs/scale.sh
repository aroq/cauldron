#!/usr/bin/env bash

if [[ ! -z "${K8S_NAMESPACE}" ]]; then
    K8S_NAMESPACE="-n ${K8S_NAMESPACE}"
fi

K8S_RS_NAME=$(kubectl get rs "${K8S_NAMESPACE}" -o jsonpath="{.items[?(@.spec.replicas==1)].metadata.name}")
echo kubectl scale rs "${K8S_RS_NAME}" "${K8S_NAMESPACE}" --replicas 0
sleep 5
echo kubectl scale rs "${K8S_RS_NAME}" "${K8S_NAMESPACE}" --replicas 1
