ARG BASE_IMAGE=debian:bullseye-slim
FROM $BASE_IMAGE as base

# create a stage for building the process-exporter binary
FROM --platform=$BUILDPLATFORM golang:1.17 AS process_exporter_build
ARG PROCESS_EXPORTER_REPO_URL="https://github.com/ncabatoff/process-exporter.git"
RUN git clone -b master "${PROCESS_EXPORTER_REPO_URL}" /go/src/github.com/ncabatoff/process-exporter
ARG TARGETARCH 
ARG BUILDPLATFORM 
WORKDIR /go/src/github.com/ncabatoff/process-exporter
ADD . .
# Build the process-exporter command inside the container.
RUN CGO_ENABLED=0 GOARCH=$TARGETARCH make build


FROM scratch
# Copy the process-exporter binary from the build stage.
COPY --from=process_exporter_build /go/src/github.com/ncabatoff/process-exporter/process-exporter /bin/process-exporter
# Run the process-exporter command by default when the container starts.
ENTRYPOINT ["/bin/process-exporter"]

#------------------ Above is from procee-exporter ------------------