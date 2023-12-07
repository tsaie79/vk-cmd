#!/bin/bash

# if using swif2, cmd points to this file.

export NODENAME="vk-direct"
export KUBECONFIG="/global/homes/j/jlabtsai/run-vk/kubeconfig/mylin"


ssh -NfL 33469:localhost:33469 mylin

shifter --image=docker:jlabtsai/vk-cmd:no-vk-container -- /bin/bash -c "cp -r /vk-cmd `pwd`"

cd `pwd`/vk-cmd

./start.sh $KUBECONFIG $NODENAME