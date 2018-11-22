#!/usr/bin/env bash

if [[ "${ENV}" == "prod" ]]
then
  terraform destroy;
else
  terraform destroy -auto-approve;
fi
