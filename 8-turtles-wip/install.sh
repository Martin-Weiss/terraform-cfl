#!/bin/bash
export KUBECONFIG=../rancher-kubeconfig
helm repo add turtles https://rancher.github.io/turtles
helm repo update turtles
helm install rancher-turtles turtles/rancher-turtles --version v0.7.0 \
    -n rancher-turtles-system \
    --dependency-update \
    --create-namespace --wait \
    --timeout 180s \
    --set cluster-api-operator.cert-manager.enabled=false
wget -N https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.7.2/clusterctl-linux-amd64 -O clusterctl
chmod +x clusterctl
export EXP_CLUSTER_RESOURCE_SET=true
./clusterctl init --infrastructure harvester --control-plane rke2 --bootstrap rke2 --config cluster-api/clusterctl.yaml

# create csi kubeconfig
./create-csi-kubeconfig.sh

# load balancer on harvester needs to be created (provisioner does this for us but at the moment the webhook does not allow the load balancer to be created before the VMs exist.. <- missing feature in harvester?


# is this the namespace in rancher or in harvester?
export CLUSTER_NAME=test-rke2 # Name of the cluster that will be created.
export NAMESPACE=test-rke2 # Namespace where the cluster will be created.
export KUBERNETES_VERSION=v1.28.9 # Kubernetes Version
export SSH_KEYPAIR=default/suse-ssh-key # should exist in Harvester prior to applying manifest
export VM_IMAGE_NAME=default/sles15sp5-minimal-cloud # Should have the format <NAMESPACE>/<NAME> for an image that exists on Harvester
export CONTROL_PLANE_MACHINE_COUNT=1
export WORKER_MACHINE_COUNT=1

# do we need csi or direct harvester or harvester via rancher, here?
#export HARVESTER_KUBECONFIG_B64=$(cat csi-kubeconfig|base64) #Full Harvester's kubeconfig encoded in Base64. You can use: cat kubeconfig.yaml | base64
export HARVESTER_KUBECONFIG_B64=$(cat ../harvester-kubeconfig|base64 -w0) #Full Harvester's kubeconfig encoded in Base64. You can use: cat kubeconfig.yaml | base64

export HARVESTER_ENDPOINT=$(grep server: ../harvester-rke2.yaml |cut -f6 -d " ")

./clusterctl generate cluster --from https://raw.githubusercontent.com/rancher-sandbox/cluster-api-provider-harvester/v0.1.1/templates/cluster-template-rke2.yaml -n test-rke2 test-rke2 > harvester-test-rke2-clusterctl.yaml

kubectl apply -f harvester-test-rke2-clusterctl.yaml

./clusterctl describe cluster -n test-rke2 test-rke2

# open points:

# rancher needs to be able to reach the harvester load balancer VIP - need to test this!
# here it is stuck in waiting on the load balancer to be active due to ipam pool vs. dhcp
# workaround: add IP to service directly in harvester
# we have seen issues with cloud-init secret already exists for the VM creation
# unclear docs for namespaces - where is harvester and where is rancher namespace relevant?
# unclear if harvester_endpoint needs <ip> or <https://...:6443
