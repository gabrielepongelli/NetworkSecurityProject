FROM debian:12.4

ARG DEBIAN_FRONTEND=noninteractive

# install dependencies needed to compile hostapd
RUN apt-get update && apt-get install -y \
    make \
    gcc \
    pkg-config \
    libnl-3-dev \
    libnl-genl-3-dev \
    dnsmasq

# add and build the required openssl version (1.0.2g)
ADD https://www.openssl.org/source/openssl-1.0.2g.tar.gz /prj/
WORKDIR /prj
RUN tar xzvf ./openssl-1.0.2g.tar.gz
WORKDIR /prj/openssl-1.0.2g
RUN ./config --prefix=/usr/local --openssldir=/usr/local && make -j 4 && make install

# add and build vulnerable version of hostapd (2.5)
ADD https://w1.fi/releases/hostapd-2.5.tar.gz /prj/
WORKDIR /prj
RUN tar xzvf ./hostapd-2.5.tar.gz
WORKDIR /prj/hostapd-2.5/hostapd
ADD ./build/defconfig .config
RUN make -j 4 && make install

# add the entrypoint script
WORKDIR /prj
ADD ./scripts/entrypoint.sh .
RUN chmod 755 entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]