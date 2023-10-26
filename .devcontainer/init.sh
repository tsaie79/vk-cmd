#!/bin/bash

kind delete cluster
kind create cluster
cp ~/.kube/config /workspaces/vk-cmd/docker/images/base/activate/apiserver
cd /workspaces/vk-cmd/docker/images/base
make quick


cd /workspaces/vk-cmd/prom/stress-docker-image
docker build -t stress:v1.0 .