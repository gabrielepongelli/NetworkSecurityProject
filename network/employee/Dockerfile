FROM debian:12.4

RUN apt-get update && apt-get install -y iputils-ping iproute2

ENTRYPOINT ["tail", "-f", "/dev/null"]