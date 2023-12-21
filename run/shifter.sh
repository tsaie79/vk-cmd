#!/bin/bash

# if using swif2, cmd points to this file.

export NODENAME="vk-direct"
export KUBECONFIG="/global/homes/j/jlabtsai/run-vk/kubeconfig/mylin"
export VKUBELET_POD_IP="127.0.0.1"
export KUBELET_PORT="10250"


ssh -NfL 44875:localhost:44875 mylin
ssh -NfR $KUBELET_PORT:localhost:$KUBELET_PORT mylin

shifter --image=docker:jlabtsai/vk-cmd:add-control -- /bin/bash -c "cp -r /vk-cmd `pwd`"

cd `pwd`/vk-cmd

./start.sh $KUBECONFIG $NODENAME $VKUBELET_POD_IP $KUBELET_PORT