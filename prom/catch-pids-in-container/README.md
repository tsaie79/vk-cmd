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
The `pid.out` file contains the **PID/PID-1** of the leader process of the container. To find the PIDs of all processes in the container, run the following command:
```
pgrep -s $(cat pid.out)
```
**Warning**: `pid.out` gives 2 numbers based on the scenario.
- If the container is launche via `vk-cmd`, then it is the PID of the leader process of the container.
- If the container is launched directly from `shifter` on the shell, then `number-in-pid.out + 1` is the PID of the leader process of the container.
