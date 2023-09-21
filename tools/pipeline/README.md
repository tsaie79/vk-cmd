This is for building a pipeline between a container and the host, which allows to run commands on the host from the container.
- Execute build_pipeline.sh in the background to build the pipeline at $HOME/hostpipe/vk-cmd on the host.
- Run the container and bind the pipeline. E.g. `docker, -v $HOME/hostpipe:/path/to/hostpipe`. (This may not be required if `$HOME/hostpipe` is already mounted in the container.)
- Run commands on the host from the container by using the pipeline. Example: `echo "shell commands" > /path/to/hostpipe/vk-cmd`
- Notice that output of `"shell commands"` is written to `$HOME/hostpipe/pipeline.out` on the host.