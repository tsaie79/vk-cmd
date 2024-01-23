#!/bin/bash

## ssh tunnel

## name node
export NODENAME="vk"
export KUBECONFIG="$HOME/.kube/config"
export VKUBELET_POD_IP="172.17.0.1"
export KUBELET_PORT="10260"

## run vk-cmd
### update the image to the latest version
docker pull jlabtsai/vk-cmd:add-control

container_id=$(docker run -itd --rm jlabtsai/vk-cmd:add-control)
docker cp ${container_id}:/vk-cmd `pwd` && docker stop ${container_id}

cd `pwd`/vk-cmd


echo "api-server config: $KUBECONFIG; nodename: $NODENAME is runnning..."
echo "vk ip: $VKUBELET_POD_IP from view of metrics server; vk kubelet port: $KUBELET_PORT"

./start.sh $KUBECONFIG $NODENAME $VKUBELET_POD_IP $KUBELET_PORT
