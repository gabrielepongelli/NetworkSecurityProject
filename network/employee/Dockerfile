FROM debian:12.4

RUN apt-get update && apt-get install -y iputils-ping iproute2 jq

ADD ./scripts/entrypoint.sh .
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]