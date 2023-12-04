#!/bin/bash
# run this script on host machine!

# if folder $HOME/hostpip exists, do nothing; otherwise, create it
if [ ! -d "$HOME/hostpipe" ]; then
    mkdir $HOME/hostpipe
fi

# if file $HOME/hostpipe/vk-cmd exists, do nothing; otherwise, create it
if [ ! -p "$HOME/hostpipe/vk-cmd" ]; then
    mkfifo $HOME/hostpipe/vk-cmd

fi

# while true do eval "$(cat $HOME/hostpipe/vk-cmd)" save stderror and stdout to diferent files
# while true; do
#     eval "$(cat $HOME/hostpipe/vk-cmd)" > $HOME/hostpipe/pipeline.out 2> $HOME/hostpipe/pipeline.err
# done

# maybe we cat revise it to:
## while true; do bash -s < fifo 1> stdout 2> stderr; done


while true; do
    # Reading the command from vk-cmd, executing it within a subshell, and capturing its PID
    { cat "$HOME/hostpipe/vk-cmd" & echo $! >&3; } 3> $HOME/hostpipe/pid_file | bash -s > $HOME/hostpipe/pipeline.out 2> $HOME/hostpipe/pipeline.err
    read pid < $HOME/hostpipe/pid_file

    echo "PID of the command written to vk-cmd: $pid"

    # Other operations using $pid
    wait $pid  # Wait for this process to finish if necessary
done
