#!/bin/bash

export PROCESS_EXPORTER_CONFIG_BASE="/workspaces/vk-cmd/prom"
export PROCESS_EXPORTER_IMG="jlabtsai/process-exporter:v0.1"
export PROCESS_EXPORTER_PORT="1914"

# docker run -d --rm -e PROCESS_EXPORTER_PORT=$PROCESS_EXPORTER_PORT -p $PROCESS_EXPORTER_PORT:9256 --privileged -v /proc:/host/proc -v $PROCESS_EXPORTER_CONFIG_BASE:/config $PROCESS_EXPORTER_IMG --procfs /host/proc -config.path /config/process-exporter.yml

docker run -d --rm -e PROCESS_EXPORTER_PORT=$PROCESS_EXPORTER_PORT -p $PROCESS_EXPORTER_PORT:$PROCESS_EXPORTER_PORT -v /proc:/host/proc -v $PROCESS_EXPORTER_CONFIG_BASE:/config $PROCESS_EXPORTER_IMG --procfs /host/proc --config.path /config/process-exporter.yml --web.listen-address=:$PROCESS_EXPORTER_PORT
