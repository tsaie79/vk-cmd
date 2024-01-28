#!/bin/bash

## ssh tunnel

## name node
export NODENAME="vk2"
export KUBECONFIG="$HOME/.kube/config" # the config file that is used to connect to the api-server. Usually it is located at $HOME/.kube/config
export VKUBELET_POD_IP="172.17.0.1" # the ip address of the node that is used to connect to the api-server. Usually it is the ip address of the docker0 interface if the api-server is running in a docker container 
export KUBELET_PORT="10260"

export JIRIAF_WALLTIME="120" # should be multiple of 60 and in seconds
export JIRIAF_NODETYPE="gpu"
export JIRIAF_SITE="Local"

## run vk-cmd
### update the image to the latest version
docker pull jlabtsai/vk-cmd:add-control

container_id=$(docker run -itd --rm jlabtsai/vk-cmd:add-control)
docker cp ${container_id}:/vk-cmd `pwd` && docker stop ${container_id}

cd `pwd`/vk-cmd


echo "api-server config: $KUBECONFIG; nodename: $NODENAME is runnning..."
echo "vk ip: $VKUBELET_POD_IP from view of metrics server; vk kubelet port: $KUBELET_PORT"

./start.sh $KUBECONFIG $NODENAME $VKUBELET_POD_IP $KUBELET_PORT $JIRIAF_WALLTIME $JIRIAF_NODETYPE $JIRIAF_SITE
