#!/bin/bash


# /bin/process-exporter --procfs /host_proc --config.path /config.yml --web.listen-address=:$PROCESS_EXPORTER_PORT


/bin/process-exporter --procfs /host_proc --config.path /config.yml --web.listen-address=:$PROCESS_EXPORTER_PORT