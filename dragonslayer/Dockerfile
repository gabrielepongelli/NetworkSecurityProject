FROM debian:12.4

ARG DEBIAN_FRONTEND=noninteractive

# install dependencies needed to compile wpa_supplicant
RUN apt-get update && apt-get install -y \
    make \
    gcc \
    pkg-config \
    libnl-3-dev \
    libssl-dev \
    libnl-genl-3-dev \
    libdbus-1-dev \
    git \
    net-tools

# add and build dragonslayer code
ADD ./src/wpa_supplicant /prj/wpa_supplicant
ADD ./src/src /prj/src
WORKDIR /prj/wpa_supplicant
RUN cp defconfig .config && make -j 4

# add the entrypoint script
WORKDIR /prj/script
ADD ./src/dragonslayer/dragonslayer-client.sh ./dragonslayer.sh
RUN chmod 755 dragonslayer.sh
ENTRYPOINT [ "./dragonslayer.sh" ]