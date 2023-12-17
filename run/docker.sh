#!/bin/bash

## ssh tunnel

## name node
export NODENAME="vk-direct-lin"
export KUBECONFIG="/home/jeng-yuantsai/.kube/config"


## run vk-cmd
container_id=$(docker run -itd --rm jlabtsai/vk-cmd:no-vk-container)
docker cp ${container_id}:/vk-cmd `pwd` && docker stop ${container_id}

cd `pwd`/vk-cmd

./start.sh "$KUBECONFIG" "$NODENAME"&

echo "api-server config: $KUBECONFIG; nodename: $NODENAME is runnning..."