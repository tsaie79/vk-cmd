# Find PIDs of processes running in a container

To use process-exporter, one needs to know the PIDs of the processes to be monitored. This is easy if the processes are running on the host, but if they are running in a container, it is not. Here is a way to find the PIDs of processes running in a container. It is tested on Perlmutter. It may not work on other machines.


## 1. Launch a container with `setsid`
`setid` is a command that launches a process in a new session. It is useful for this purpose because it makes the container the session leader, and all processes in the container are children of the session leader. This makes it easy to find the PIDs of all processes in the container.

```
setsid shifter docker-img & echo $! >> pid.out
```
For example: 
```
setsid shifter --image=docker:jlabtsai/read-resources:latest -- stress-ng -c 2 --timeout 100 & echo $! >> pid.out
```

## 2. Find the PIDs of all processes in the container
The `pid.out` file contains the **PID/PID-1** of the leader process of the container. To find the PIDs of all processes (including the leader) in the container, run the following command:
```
pgrep -s $(cat pid.out)
```
**Warning**: `pid.out` gives 2 numbers based on the scenario.
- If the container is launche via `vk-cmd`, then it is the PID of the leader process of the container.
- If the container is launched directly from `shifter` on the shell, then `number-in-pid.out + 1` is the PID of the leader process of the container.


# Custom process-exporter image
The process-exporter image used in this example is built from the Dockerfile in this directory. This works with the existing file containing the leader PID of the container. If the file is not present, the process-exporter will not work.

## Files to build the process-exporter image
1. `get_cmd.sh` is used to generate the configuration file for the process-exporter. 
2. `exe.sh` is the main script running the process exporter.
3. `process-exporter-config.yml` is the template of configuration file for the process-exporter.


## Commands in the user's pod configuration file (pod.yml)

1. When user's pod is launched via `vk-cmd`, the `$HOME/pid.out` must be created and the PID of the leader process of the pod must be written to it. 

```
The 1st part of `command` in the `pod.yml` file must be:

(setsid shifter --image=docker:jlabtsai/stress:v20231026 --entrypoint& echo $! > ~/pid.out)
```

2. Launch the process-exporter container with the following command with the environment variables set:
```
PROCESS_EXPORTER_PORT: export the port number of the process-exporter container
PROM_SERVER: export the address of the prometheus server
```
```
The 2nd part of `command` in the `pod.yml` file must be:

(export PROCESS_EXPORTER_PORT=1913 && export PROM_SERVER=jeng-yuantsai@72.84.73.170 && setsid shifter --image=jlabtsai/process-exporter:v1.0 -V /proc:/host_proc --entrypoint &)
```
3. Port-forward the process-exporter port to the host. 
```
The 3rd part of `command` in the `pod.yml` file must be:

(export PROCESS_EXPORTER_PORT=1913 && export PROM_SERVER=jeng-yuantsai@72.84.73.170 && ssh -NfR $PROCESS_EXPORTER_PORT:localhost:$PROCESS_EXPORTER_PORT $PROM_SERVER)
```