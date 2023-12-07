#!/bin/bash



## name node
export NODENAME="vk-mylin"
export KUBECONFIG="~/.kube/config"

## ssh tunnel
ssh -NfL 33469:localhost:33469 mylin

## run vk-cmd
container_id=$(docker run -itd --rm jlabtsai/vk-cmd:no-vk-container)
docker cp ${container_id}:/vk-cmd `pwd`

cd `pwd`/vk-cmd

./start.sh $KUBECONFIG $NODENAME