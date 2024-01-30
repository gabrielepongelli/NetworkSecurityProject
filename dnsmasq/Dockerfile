FROM alpine:latest

RUN apk --no-cache add dnsmasq

EXPOSE 67/udp
EXPOSE 53/udp

ENTRYPOINT ["dnsmasq", "-k"]
