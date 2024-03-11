#!/bin/bash
export KUBECONFIG=../harvester-rke2.yaml
source ./terraform.tfvars
./generate_addon.sh $clustername $namespace
