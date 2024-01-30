#!/bin/bash

usage() {
    echo "Usage: ${0} <start|stop> <iface>" >&2
    exit 1
}

start() {
    #sudo nmcli n off
    #sudo nmcli r wifi off
    sudo nmcli device set $1 managed no
    #sudo systemctl stop NetworkManager.service
    sudo systemctl stop dnsmasq.service
    #sudo rfkill unblock wlan
    #sudo ifconfig $1 192.168.123.1/24 up
    sudo ip addr add 192.168.123.1/24 dev $1
    sudo ip link set $1 up
}

stop() {
    #sudo ifconfig $1 down
    sudo ip link set $1 down
    sudo ip addr del 192.168.123.1/24 dev $1
    sudo systemctl start dnsmasq.service
    #sudo systemctl start NetworkManager.service
    #sudo nmcli n on
    #sudo nmcli r wifi on
    sudo nmcli device set $1 managed yes
}

if ! [ "$#" -eq 2 ]; then
    usage
fi

case $1 in
    start)
        start "$2"
        ;;
    stop)
        stop "$2"
        ;;
    *)
        usage
        ;;
esac
