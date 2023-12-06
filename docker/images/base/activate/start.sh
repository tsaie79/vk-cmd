#!/bin/bash

# export KUBECONFIG="$VK_PATH/config"
export VKUBELET_POD_IP="10.250.64.71"
export APISERVER_CERT_LOCATION="client.crt"
export APISERVER_KEY_LOCATION="client.key"
export KUBELET_PORT="10250"

echo "{\"$NODENAME\": {\"cpu\": \"0\", \"memory\": \"0Gi\", \"pods\": \"0\"}}" > .host-cfg.json

"virtual-kubelet" --nodename $NODENAME --provider mock --provider-config .host-cfg.json --klog.v 3 > $NODENAME.log 2>&1