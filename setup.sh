#!/bin/bash

usage() {
    echo "Usage: ${0} <start|stop> <iface>" >&2
    exit 1
}

start() {
    sudo nmcli device set $1 managed no
    sudo ip link set $1 up
}

stop() {
    sudo ip link set $1 down
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
