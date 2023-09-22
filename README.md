# Intro
This vk-cmd is a Virtual Kubelet that translates the commands from Kubernetes to the host shell commands. It is not running a container, but running shell commands on the host. This is based on the Virtual Kubelet (vk-mock) and is designed for running on various resources where a user can't reach the container runtime directly. We reference the Virtual Kubelet (vk-mock) and KinD to build this package.

The implementation of vk-cmd is based on the Virtual Kubelet (vk-mock in https://github.com/virtual-kubelet/virtual-kubelet) and is stored at https://github.com/tsaie79/vk-mock. The image of vk-cmd is built by Dockerfile in this repo. The image is stored at https://hub.docker.com/repository/docker/jlabtsai/vk-cmd.

# Build image
- Config file of apiserver (control plane) is located at docker `/images/base/activate/config`. 
    - Port, cert and key are set by KinD (`~/.kube/config`), as an example. These require to be set by users when building this image.
    - URL of apiserver is set to `127.0.0.1` implying that building a ssh tunnel mapping from vk to control plane is required.
- `Client.crt` and `client.key` are equired but not used in this package. These are created by `tools/create-client-cert.sh`.
- Dockerfile is located at `docker/images/base/Dockerfile`.
    - Build the docker image by Makefile. (`make quick`)

# Launch vk-cmd
- Build a ssh tunnel mapping from vk to control plane. (`ssh -NfL localhost:port1:localhost:port xxx@control-plane`).
    - If host network is not available, use `docker --network="host"`. (need higher credential) (see Column 4 in Table 1)

- Build pipeline for executing commands on the host within the container, see `tools/pipeline/README.md`. 
    - Docker command of binding volumes: `docker -v $HOME/hostpipe:/path/to/pipeline/in/container`.
    - Notice that some resources bind `$HOME` automatically; thus one doesn't need to bind pipeline if it's located under `$HOME`. (see Columns 2 and 3 in Table 1)

- Set unique env variable `$JOBNAME`. This sets the name of worker node in Kubernetes cluster, and it is used for job pod names that must be unique.
    - Convey env variables to a docker container, e.g. `docker -e JOBNAME="vk-xxx"` (vk-xxx is required, but xxx can be any string)
    - Notice that some resources allow a container to share env variables with its host. (see Column 5 in Table 1)


- Run vk-cmd by various commands; see Table 2.

# Deploy job pods
- Refer to `toos/job_pod_template.yaml`.
- Set `Metadata.Name` (pod name) and `Sepc.NodeSelector.Kubernetes.io/hostname` in YAML as the `$JOBNAME`, to prevent conflict when launching new jobs.
- Assign shell commands at the key of `Spec.containers[0].Command` in YAML.
    - See Table 3.
    - Notice that if `$HOME` is mounted and bound automatically, then `$HOME` in the container is the same as that in the host.
- Launch job pod on control plane: `kubectl apply -f job_pod_template.yaml`.

    

# Tables
- Table 1: Scenarios when launching vk-cmd

|                    | CRI       | Available $HOME in container | Need to bind pipeline located at $HOME/hostpipe/vk-cmd | Available host network in container | Available env variables from host shell |
|--------------------|-----------|------------------------------|---------------------------------------------------------|-------------------------------------|-----------------------------------------|
| Jiriaf2301         | Docker    | No                           | Yes                           | No                                  | No                                      |
| ifarm              | Apptainer | Yes                          | No                                                      | Yes                                 | Yes                                     |
| Perlmutter (NERSC) | Shifter   | Yes                          | No                                                      | Yes                                 | Yes                                     |

- Table 2: Steps of running vk-cmd image

|                    |                     Step 0                    |              Step 1              |         Step 2        |                                                  Step 3                                                 |                        Step 4                        |
|--------------------|:---------------------------------------------:|:--------------------------------:|:---------------------:|:-------------------------------------------------------------------------------------------------------:|:----------------------------------------------------:|
| Jiriaf2301         | Build SSH tunnel from worker to control plane | Build pipeline in the background | setenv JOBNAME vk-xxx | docker run -d -v $HOME/hostpipe:/root/hostpipe --network="host" -e JOBNAME=$JOBNAME jlabtsai/vk-cmd:tag |                                                      |
| ifarm              |                                               |                                  |                       | apptainer run docker://jlabtsai/vk-cmd:tag                                                              |                                                      |
| Perlmutter (NERSC) |                                               |                                  | export JOBNAME=vk-xxx | shifterimg pull jlabtsai/vk-cmd:tag                                                                     | shifter --image=jlabtsai/vk-cmd:tag --entrypoint |



- Table 3: Shell cmds in job pod YAML to run images

|                    | The Spec.Containers[0].Command in pod YAML to run image app                                                             |
|--------------------|-------------------------------------------------------------------------------------------------|
| Jiriaf2301         | "echo 'docker run godlovedc/lolcow:latest > $HOME/out.txt && ls -l $HOME/out.txt' > /root/hostpipe/vk-cmd"                               |
| ifarm              | "echo 'apptainer exec lolcow_latest.sif cowsay moo > $HOME/out.txt && ls -l $HOME/out.txt' > $HOME/hostpipe/vk-cmd"    |
| Perlmutter (NERSC) | "echo 'shifter --image=godlovedc/lolcow:latest --entrypoint > $HOME/out.txt && ls -l $HOME/out.txt' > $HOME/hostpipe/vk-cmd" |



# Reference
- This package is based on Virtual Kubelete - https://github.com/virtual-kubelet/virtual-kubelet.
- Vk-cmd is based on vk-mock in the above repo and stored in: https://github.com/tsaie79/vk-mock.
- Dockerfile is built referenced by KinD - https://github.com/kubernetes-sigs/kind.