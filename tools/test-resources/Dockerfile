# jlabtsai/read-resources:latest

# Use lightweight linux image
FROM alpine:3.12

#install stress
RUN apk add stress-ng

# Run stress test
ENTRYPOINT ["stress-ng", "-c", "2", "--timeout", "60", "--metrics-brief"]