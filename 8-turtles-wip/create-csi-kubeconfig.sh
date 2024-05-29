#!/bin/bash
export KUBECONFIG=../harvester-rke2.yaml
source ./terraform.tfvars
rm generate_addon.sh
wget https://raw.githubusercontent.com/harvester/cloud-provider-harvester/master/deploy/generate_addon.sh
if [ -f /opt/homebrew/bin/gsed ]; then
	gsed -i 's/^cat ${KUBECFG_FILE_NAME}.*/cat ${KUBECFG_FILE_NAME}; cat ${KUBECFG_FILE_NAME} > csi-kubeconfig/g' generate_addon.sh
else
	sed -i 's/^cat ${KUBECFG_FILE_NAME}.*/cat ${KUBECFG_FILE_NAME}; cat ${KUBECFG_FILE_NAME} > csi-kubeconfig/g' generate_addon.sh
fi
chmod +x generate_addon.sh
./generate_addon.sh $clustername $namespace
