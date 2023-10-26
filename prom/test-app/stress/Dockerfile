# jlabtsai/read-resources:latest

# Use lightweight linux image
FROM alpine:3.12

#install stress
RUN apk add stress-ng

# ENTRYPOINT ["stress-ng", "-c", "2", "--timeout", "300", "--metrics-brief", "&", "stress-ng", "-c", "1", "--timeout", "300", "--metrics-brief"]
ENTRYPOINT ["stress-ng", "-c", "2", "--timeout", "300", "--metrics-brief", ]