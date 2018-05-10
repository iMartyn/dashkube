FROM alpine:latest
RUN apk add --no-cache tcpdump bash curl
ADD script.sh /
RUN chmod +x /script.sh
ENTRYPOINT /script.sh
