This is for building a pipeline between a container and the host, which allows to run commands on the host from the container.
- Execute build_pipeline.sh in the background to build the pipeline at $HOME/hostpipe/vk-cmd on the host.
- Run the container with the pipeline mounted at ~/hostpipe/vk-cmd. The command: docker run -d -v $HOME/hostpipe:~/hostpipe IMAGE_NAME. (This may not be required if $HOME is already mounted!)
- Run commands on the host from the container by using the pipeline. Example: echo "touch ~/a.txt" > ~/hostpipe/vk-cmd