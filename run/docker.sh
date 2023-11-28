#!/bin/bash

## ssh tunnel
ssh -NfL 42053:localhost:42053 tsai@jiriaf2301.jlab.org

## run unix pipe
sh ../tools/pipeline/build_pipline_host.sh &

## name node
export NODENAME="vk-lin"
export HOST_KUBECONFIG="$HOME/.kube"
export KUBECONFIG="/.kube/config"

## run vk-cmd
docker run -d -v $HOME/hostpipe:/root/hostpipe -v $HOST_KUBECONFIG:/.kube -e KUBECONFIG=/.kube/config -e NODENAME=$NODENAME --network="host" jlabtsai/vk-cmd:latest