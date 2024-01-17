#!/bin/bash

export CONTROL_PLANE_IP="mylin"
export APISERVER_PORT="46859"
export NODENAME="vk-nersc"
export KUBECONFIG="/global/homes/j/jlabtsai/run-vk/kubeconfig/$CONTROL_PLANE_IP"
export VKUBELET_POD_IP="172.17.0.1"
export KUBELET_PORT="10261"

# check if ssh tunnel is running, if not, start it as a follow
if [ -z "$(ps -ef | grep $APISERVER_PORT | grep -v grep)" ]; then
    echo "ssh tunnel is not running, start it as a follow"
    ssh -NfL $APISERVER_PORT:localhost:$APISERVER_PORT $CONTROL_PLANE_IP
else
    echo "ssh tunnel is running"
fi


if [ -z "$(ps -ef | grep $KUBELET_PORT | grep -v grep)" ]; then
    echo "ssh tunnel is not running, start it as a follow"
    ssh -NfR *:$KUBELET_PORT:localhost:$KUBELET_PORT $CONTROL_PLANE_IP 
else
    echo "ssh tunnel is running"
fi


# ssh -NfL $APISERVER_PORT:localhost:$APISERVER_PORT $CONTROL_PLANE_IP
# ssh -NfR *:$KUBELET_PORT:localhost:$KUBELET_PORT $CONTROL_PLANE_IP 
# To make sure the port is open to all interfaces, one has to set GatewayPorts to yes in /etc/ssh/sshd_config and run sudo service ssh restart at mylin.

shifter --image=docker:jlabtsai/vk-cmd:add-control -- /bin/bash -c "cp -r /vk-cmd `pwd`"

cd `pwd`/vk-cmd

echo "api-server config: $KUBECONFIG; nodename: $NODENAME is runnning..."
echo "vk ip: $VKUBELET_POD_IP from view of metrics server; vk kubelet port: $KUBELET_PORT"

./start.sh $KUBECONFIG $NODENAME $VKUBELET_POD_IP $KUBELET_PORT