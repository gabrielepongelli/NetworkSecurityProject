FROM debian:12.4

ARG DEBIAN_FRONTEND=noninteractive

# install DHCP server
RUN apt-get update && \
    apt-get install -y isc-dhcp-server

# create the dhcpd.leases file
RUN touch /var/lib/dhcp/dhcpd.leases

# expose DHCP port
EXPOSE 67/udp

# run DHCP server
CMD ["dhcpd", "-f", "-d", "--no-pid"]
