# Docker Image for Virtual-Kubelet-Cmd
This repository hosts the Docker image for [virtual-kubelet-cmd](https://github.com/tsaie79/virtual-kubelet-cmd). Virtual-kubelet-cmd is a BASH command provider for Virtual Kubelet. You can find the Docker image on [Docker Hub](https://hub.docker.com/repository/docker/jlabtsai/vk-cmd).

# Overview
This repository hosts the `virtual-kubelet-cmd` binary and its required files. When a container is created from this image, it generates a `vk-cmd` directory. The binary and its related files are subsequently transferred into this directory. To execute `vk-cmd`, users can use the scripts found in the `run` directory.

# Docker Image Construction
The Dockerfile used to build the image for this project is located at `docker/images/base/Dockerfile`. To build the Docker image, run the `make quick` command in your terminal.

# Executing vk-cmd
To execute `vk-cmd`, adhere to the following procedure:
1. Configure the required environment variables.
2. Establish SSH tunnels, if they are not already in place.
3. Execute the `start.sh` script located in the `vk-cmd` directory.

**Note** Scripts for ruunning vk-cmd are located in the `run` directory.

## 1. Configuring the Environment Variables

This section defines several environment variables essential for configuring the Virtual Kubelet command. Each variable serves a specific purpose:

| Variable Name   | Description |
| --------------- | ----------- |
| `NODENAME` | The name of the node in the Kubernetes cluster. |
| `KUBECONFIG` | Points to the location of the Kubernetes configuration file, which is used to connect to the Kubernetes API server. By default, it's located at `$HOME/.kube/config`. |
| `VKUBELET_POD_IP` | The IP address of the VK that metrics server talks to. If the metrics server is running in a Docker container and VK is running on the same host, this is typically the IP address of the `docker0` interface. |
| `KUBELET_PORT` | The port on which the Kubelet service is running. The default port for Kubelet is 10250. This is for the metrics server and should be unique for each node. |
| `JIRIAF_WALLTIME` | Sets a limit on the total time that a node can run. It should be a multiple of 60 and is measured in seconds. If it's set to 0, there is no time limit. |
| `JIRIAF_NODETYPE` | Specifies the type of node that the job will run on. This is just for labeling purposes and doesn't affect the actual job. |
| `JIRIAF_SITE` | Used to specify the site where the job will run. This is just for labeling purposes and doesn't affect the actual job. |

## 2. Building SSH Tunnels
If you are running `vk-cmd` on a remote machine, you will need to build an SSH tunnel to the control plane. Two tunnels are required: one for the API server and one for the metrics server. The following commands can be used to build these tunnels:

| Communication Direction | Environment Variables | SSH Command |
| ----------------------- | --------------------- | ----------- |
| VK to API server | `APISERVER_PORT=6443`<br>`CONTROL_PLANE_IP="control-plane-ip"` | `ssh -NfL $APISERVER_PORT:localhost:$APISERVER_PORT $CONTROL_PLANE_IP` |
| Metrics server to VK | `CONTROL_PLANE_IP="control-plane-ip"` | `ssh -NfR *:$KUBELET_PORT:localhost:$KUBELET_PORT $CONTROL_PLANE_IP` |

**Note:** The `*` symbol in the SSH command for Metrics server to VK is used to bind the port to all network interfaces. To ensure the port is accessible from all interfaces, you must set `GatewayPorts` to `yes` in the `/etc/ssh/sshd_config` file. After making this change, restart the SSH service on the control plane using the command `sudo service ssh restart`.

## 3. Executing the `start.sh` Script
Once the environment variables are configured and the SSH tunnels are established, you can initiate the `start.sh` script located in the `vk-cmd` directory. This script launches the `vk-cmd` binary and establishes a connection with the Kubernetes API server.
```bash
./start.sh $KUBECONFIG $NODENAME $VKUBELET_POD_IP $KUBELET_PORT $JIRIAF_WALLTIME $JIRIAF_NODETYPE $JIRIAF_SITE
```

## Example of Running vk-cmd
```bash
#!/bin/bash

## ssh tunnel

## name node
export NODENAME="vk"
export KUBECONFIG="$HOME/.kube/config" # the config file that is used to connect to the api-server. Usually it is located at $HOME/.kube/config
export VKUBELET_POD_IP="123.123.123.123" # the ip address of the node that is used to connect to the api-server. Usually it is the ip address of the docker0 interface if the api-server is running in a docker container 
export KUBELET_PORT="10260"

export JIRIAF_WALLTIME="0" # should be multiple of 60 and in seconds. if 0, then no walltime limit
export JIRIAF_NODETYPE="cpu"
export JIRIAF_SITE="mylin"

## run vk-cmd
### update the image to the latest version
export VK_CMD_IMAGE="jlabtsai/vk-cmd:main"
docker pull $VK_CMD_IMAGE

container_id=$(docker run -itd --rm --name vk-cmd $VK_CMD_IMAGE)
docker cp ${container_id}:/vk-cmd `pwd` && docker stop ${container_id}

cd `pwd`/vk-cmd

echo "=============================="

echo "api-server config: $KUBECONFIG; nodename: $NODENAME is runnning..."
echo "vk ip: $VKUBELET_POD_IP from view of metrics server; vk kubelet port: $KUBELET_PORT"
echo "walltime: $JIRIAF_WALLTIME; nodetype: $JIRIAF_NODETYPE; site: $JIRIAF_SITE"

./start.sh $KUBECONFIG $NODENAME $VKUBELET_POD_IP $KUBELET_PORT $JIRIAF_WALLTIME $JIRIAF_NODETYPE $JIRIAF_SITE
```


# Environment Characteristics for vk-cmd Launch Scenarios

| Environment        | Container Runtime Interface (CRI) | Is Host Network Available in Container? | Are Host Shell Environment Variables Available? |
|--------------------|-----------------------------------|-----------------------------------------|-------------------------------------------------|
| Jiriaf2301         | Docker                            | No                                      | No                                              |
| ifarm              | Apptainer                         | Yes                                     | Yes                                             |
| Perlmutter (NERSC) | Shifter                           | Yes                                     | Yes                                             |


# Use kubernetes API to get information about the cluster
Please see `tools/kubernetes-api/readme.md` for details.


## Related Resources
The `vk-cmd` implementation is inspired by the mock provider in the [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet) project. The source code for `vk-cmd` can be found in the [virtual-kubelet-cmd](https://github.com/tsaie79/virtual-kubelet-cmd) repository. The Dockerfile used to build the `vk-cmd` image is based on the guidelines from the [KinD](https://github.com/kubernetes-sigs/kind) project. The built image is hosted on [Docker Hub](https://hub.docker.com/repository/docker/jlabtsai/vk-cmd).