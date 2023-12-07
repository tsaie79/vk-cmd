# jlabtsai/read-resources:latest

# Use lightweight linux image
FROM alpine:3.12

#install stress
RUN apk add stress-ng

# # Run stress test
# ENV NUMBER="2"
# ENV TIME="60"

ENTRYPOINT stress-ng --metrics-brief -c $NUMBER --timeout $TIME