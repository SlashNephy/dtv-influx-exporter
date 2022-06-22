FROM alpine:3.16

RUN apk add --update --no-cache curl jq

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENV INTERVAL=30
ENTRYPOINT ["/entrypoint.sh"]
