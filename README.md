# Intro
This vk-cmd is a Virtual Kubelet that translates the commands from Kubernetes to the host shell commands. It is not running a container, but running shell commands on the host. This is based on the Virtual Kubelet (vk-mock) and is designed for running on various compute sites where a user can't reach the container runtime directly. We reference the Virtual Kubelet (vk-mock) and KinD to build this package.

# Build image
- Config file of apiserver (control plane) is located at docker `/images/base/activate/config`. 
    - Port, cert and key are set by KinD (`~/.kube/config`), as an example. These require to be set by users when building this image.
    - URL of apiserver is set to `127.0.0.1` implying that building a ssh tunnel mapping from vk to control plane is required.
- `Client.crt` and `client.key` are equired but not used in this package. These are created by `tools/create-client-cert.sh`.
- Dockerfile is located at `docker/images/base/Dockerfile`. Build the docker image by Makefile. 
    ```bash
    make quick
    ```

# Launch vk-cmd
- Build a ssh tunnel mapping from vk to control plane. 
    ```bash
    ssh -NfL localhost:port1:localhost:port xxx@control-plane
    ```
    - If host network is not available, use `docker --network="host"`. This is not recommended for security reason. (see Column 4 in Table 1)

- Build UNIX pipe for executing commands on the host within the container, see `tools/pipeline/README.md`. 
    - Docker command of binding volumes: 
        ```bash
        docker -v $HOME/hostpipe:/path/to/pipeline/in/container`
        ```   
    - Notice that some compute sites bind `$HOME` automatically; thus one doesn't need to bind pipeline if it's located under `$HOME`. (see Columns 2 and 3 in Table 1)

- Set unique env variable `$NODENAME`. This sets the name of worker node in Kubernetes cluster and must be unique.
    - Convey env variables to a docker container, e.g.,
        ```bash
        docker -e NODENAME="vk-xxx" (vk-xxx is required, but xxx can be any string)
        ```
    - Notice that some compute sites allow a container to share env variables with its host. (see Column 5 in Table 1)
- Run vk-cmd with various commands; see Table 2.
- Supplemental bash scripts are located at `run/`.

# Deploy job pods
- Refer to `toos/job_pod_template.yaml`.
- Set `metadata:name` (job-name/pod-name) and `sepc:nodeSelector:kubernetes.io/role` in YAML as the `agent`, to prevent launching pods in control plane.
- Resources are set by `spec:containers:0:resources:` in YAML.
    - `limits` and `requests` are the upper and lower bounds of resources, respectively.
- Assign shell commands at the key of `spec:containers:0:command` in YAML.
    - See Table 3.
    - Notice that if `$HOME` is mounted and bound automatically, then `$HOME` in the container is the same as that in the host.
- Launch job pod on control plane: 
    ```bash
    kubectl apply -f job_pod_template.yaml
    ```

    

# Tables
- Table 1: Scenarios when launching vk-cmd

|                    | CRI       | Available $HOME in container | Need to bind pipeline located at $HOME/hostpipe/vk-cmd | Available host network in container | Available env variables from host shell |
|--------------------|-----------|------------------------------|---------------------------------------------------------|-------------------------------------|-----------------------------------------|
| Jiriaf2301         | Docker    | No                           | Yes                           | No                                  | No                                      |
| ifarm              | Apptainer | Yes                          | No                                                      | Yes                                 | Yes                                     |
| Perlmutter (NERSC) | Shifter   | Yes                          | No                                                      | Yes                                 | Yes                                     |

- Table 2: Steps of running vk-cmd image

|                    | Step 0                                        | Step 1                           | Step 2                | Step 3                                                                                                  |
|--------------------|-----------------------------------------------|----------------------------------|-----------------------|---------------------------------------------------------------------------------------------------------|
| Jiriaf2301         | Build SSH tunnel from worker to control plane | Build pipeline in the background | setenv NODENAME vk-xxx | docker run -d -v $HOME/hostpipe:/root/hostpipe --network="host" -e NODENAME=$NODENAME jlabtsai/vk-cmd:tag |
| ifarm              |                                               |                                  |                       | apptainer run docker://jlabtsai/vk-cmd:tag                                                              |
| Perlmutter (NERSC) |                                               |                                  | export NODENAME=vk-xxx | shifter --image=docker:jlabtsai/vk-cmd:tag --entrypoint                                               |



- Table 3: Shell cmds in job pod YAML to run images

|                    | The Spec.Containers[0].Command in pod YAML to run image app                                                             |
|--------------------|-------------------------------------------------------------------------------------------------|
| Jiriaf2301         | "echo 'docker run godlovedc/lolcow:latest' > /root/hostpipe/vk-cmd"                               |
| ifarm              | "echo 'apptainer run docker://sylabsio/lolcow:latest' > $HOME/hostpipe/vk-cmd"   |
| Perlmutter (NERSC) | "echo 'shifter --image=godlovedc/lolcow:latest --entrypoint' > $HOME/hostpipe/vk-cmd" |



## Use kubernetes API to get information about the cluster
- Please see `tools/kubernetes-api/readme.md` for details.

# References
The implementation of vk-cmd is based on the mock provider in [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet.). The source code of this repo is stored in [vk-cmd](https://github.com/tsaie79/virtual-kubelet-cmd). The image of vk-cmd is built by Dockerfile in this repo and refer to [KinD](https://github.com/kubernetes-sigs/kind). The image is stored in [dockerhub](https://hub.docker.com/repository/docker/jlabtsai/vk-cmd).