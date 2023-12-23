#!/bin/bash


export APISERVER="mylin2"
export APISERVER_PORT="44877"
export NODENAME="vk-nersc"
export KUBECONFIG="/global/homes/j/jlabtsai/run-vk/kubeconfig/$APISERVER"
export VKUBELET_POD_IP="127.0.0.1"
export KUBELET_PORT="10257"


#ssh -NfL 44875:localhost:44875 mylin
ssh -NfL $APISERVER_PORT:localhost:$APISERVER_PORT $APISERVER
ssh -NfR $KUBELET_PORT:localhost:$KUBELET_PORT $APISERVER

shifter --image=docker:jlabtsai/vk-cmd:add-control -- /bin/bash -c "cp -r /vk-cmd `pwd`"

cd `pwd`/vk-cmd

./start.sh $KUBECONFIG $NODENAME $VKUBELET_POD_IP $KUBELET_PORT