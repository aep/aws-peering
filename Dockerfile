FROM alpine:latest

RUN apk add --no-cache strongswan dumb-init curl ebtables iptables

COPY entrypoint.sh /entrypoint.sh
COPY aws.sh  /aws.sh
COPY peer.sh /peer.sh
COPY updown-peer.sh /updown-peer.sh
COPY updown-aws.sh /updown-aws.sh
WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]

