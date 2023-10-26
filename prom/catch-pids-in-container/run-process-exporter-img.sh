#!/bin/bash


docker run -d --rm -p 9256:9256 --privileged -v /proc:/host/proc -v /workspaces/vk-cmd/prom:/config ncabatoff/process-exporter --procfs /host/proc -config.path /config/process-exporter.yml


#   docker run -d --rm -p 9256:9256 --privileged -v /proc:/host/proc -v `pwd`:/config ncabatoff/process-exporter --procfs /host/proc -config.path /config/filename.yml


#   docker run -d --rm -p 9256:9256 --privileged ncabatoff/process-exporter -config.path /workspaces/vk-cmd/prom/process-exporter.yml


#   docker run -d --rm -p 9256:9256 --privileged jlabtsai/process-exporter:v0.1 -config.path /workspaces/vk-cmd/prom/process-exporter.yml



