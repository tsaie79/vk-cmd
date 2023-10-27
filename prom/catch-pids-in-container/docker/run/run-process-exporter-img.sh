#!/bin/bash


export PROCESS_EXPORTER_IMG="jlabtsai/process-exporter:v0.1"
export PROCESS_EXPORTER_PORT="1111"


docker run -d --rm -e PROCESS_EXPORTER_PORT=$PROCESS_EXPORTER_PORT -p $PROCESS_EXPORTER_PORT:$PROCESS_EXPORTER_PORT -v /proc:/host_proc $PROCESS_EXPORTER_IMG


# shifter --image=$PROCESS_EXPORTER_IMG -V /proc:/host_proc --entrypoint