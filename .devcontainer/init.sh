#!/bin/bash

kind delete cluster
kind create cluster
cp ~/.kube/config /workspaces/vk-cmd/docker/images/base/activate/apiserver
cd /workspaces/vk-cmd/docker/images/base
make quick

export NODENAME='vk-prom'
sh /workspaces/vk-cmd/tools/pipeline/build_pipline_host.sh &