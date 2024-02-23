# Docker Image for Virtual-Kubelet-Cmd
This repository contains the Docker image for [virtual-kubelet-cmd](https://github.com/tsaie79/virtual-kubelet-cmd), a BASH command provider for Virtual Kubelet. The image construction process is based on the [KinD](https://github.com/kubernetes-sigs/kind) project guidelines.

# Overview
This repository hosts the `virtual-kubelet-cmd` binary and its required files. When a container is created from this image, it generates a `vk-cmd` directory. The binary and its related files are subsequently transferred into this directory. To execute `vk-cmd`, users can use the scripts found in the `run` directory.

# Building the Docker Image
The Dockerfile for this project is found in the `docker/images/base/Dockerfile` directory. To construct the Docker image, execute the command `make quick` in your terminal.

# Run vk-cmd
To launch `vk-cmd`, follow these steps:
1. Set up the environment variables.
2. Build SSH tunnels, if necessary.
3. Run `start.sh` in `vk-cmd` directory.

**Note** Scripts for ruunning vk-cmd are located in the `run` directory.

## 1. Configuring the Environment Variables

This section defines several environment variables essential for configuring the Virtual Kubelet command. Each variable serves a specific purpose:

| Variable Name   | Description |
| --------------- | ----------- |
| `NODENAME` | The name of the node in the Kubernetes cluster. |
| `KUBECONFIG` | Points to the location of the Kubernetes configuration file, which is used to connect to the Kubernetes API server. By default, it's located at `$HOME/.kube/config`. |
| `VKUBELET_POD_IP` | The IP address of the node that is used to connect to the Kubernetes API server. If the API server is running in a Docker container, this is typically the IP address of the `docker0` interface. |
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

# Tables
## Table 1: Scenarios when launching vk-cmd

|                    | CRI       | Available $HOME in container | Need to bind pipeline located at $HOME/hostpipe/vk-cmd | Available host network in container | Available env variables from host shell |
|--------------------|-----------|------------------------------|---------------------------------------------------------|-------------------------------------|-----------------------------------------|
| Jiriaf2301         | Docker    | No                           | Yes                           | No                                  | No                                      |
| ifarm              | Apptainer | Yes                          | No                                                      | Yes                                 | Yes                                     |
| Perlmutter (NERSC) | Shifter   | Yes                          | No                                                      | Yes                                 | Yes                                     |

## Table 2: Steps of running vk-cmd image

|                    | Step 0                                        | Step 1                           | Step 2                | Step 3                                                                                                  |
|--------------------|-----------------------------------------------|----------------------------------|-----------------------|---------------------------------------------------------------------------------------------------------|
| Jiriaf2301         | Build SSH tunnel from worker to control plane | Build pipeline in the background | setenv NODENAME vk-xxx | docker run -d -v $HOME/hostpipe:/root/hostpipe --network="host" -e NODENAME=$NODENAME jlabtsai/vk-cmd:tag |
| ifarm              |                                               |                                  |                       | apptainer run docker://jlabtsai/vk-cmd:tag                                                              |
| Perlmutter (NERSC) |                                               |                                  | export NODENAME=vk-xxx | shifter --image=docker:jlabtsai/vk-cmd:tag --entrypoint                                               |



## Table 3: Shell cmds in job pod YAML to run images

|                    | The Spec.Containers[0].Command in pod YAML to run image app                                                             |
|--------------------|-------------------------------------------------------------------------------------------------|
| Jiriaf2301         | "echo 'docker run godlovedc/lolcow:latest' > /root/hostpipe/vk-cmd"                               |
| ifarm              | "echo 'apptainer run docker://sylabsio/lolcow:latest' > $HOME/hostpipe/vk-cmd"   |
| Perlmutter (NERSC) | "echo 'shifter --image=godlovedc/lolcow:latest --entrypoint' > $HOME/hostpipe/vk-cmd" |


# Use kubernetes API to get information about the cluster
Please see `tools/kubernetes-api/readme.md` for details.


## References
The implementation of `vk-cmd` is based on the mock provider in [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet). The source code of this repository is stored in [virtual-kubelet-cmd](https://github.com/tsaie79/virtual-kubelet-cmd). The `vk-cmd` image is built using the Dockerfile in this repository and refers to [KinD](https://github.com/kubernetes-sigs/kind). The image is stored in [Docker Hub](https://hub.docker.com/repository/docker/jlabtsai/vk-cmd). 