#!/bin/bash

export VKUBELET_POD_IP="10.250.64.71"
export APISERVER_CERT_LOCATION="client.crt"
export APISERVER_KEY_LOCATION="client.key"
export KUBELET_PORT="10250"

# export KUBECONFIG="config"
# export NODENAME="vk-cmd"

# echo "{\"$2\": {\"cpu\": \"0\", \"memory\": \"0Gi\", \"pods\": \"0\"}}" > .host-cfg.json

# ./virtual-kubelet --kubeconfig $1 --nodename $2 --provider mock --provider-config .host-cfg.json --klog.v 3 > $2.log 2>&1
./virtual-kubelet --kubeconfig $1 --nodename $2 --provider mock --klog.v 3 > $2.log 2>&1