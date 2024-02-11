#!/usr/bin/env bash

VICTIM_PATH="./network"
ATTACK_PATH="./dragonslayer"

usage() {
    echo "Usage: ${0} <victim|attack> <iface>" >&2
    exit 1
}

log() {
    local level=$1
    local error=$2

    case $level in
        "success")
            echo -n "[+] "
            ;;
        "warning")
            echo -n "[!] "
            ;;
        "error")
            echo -n "[-] "
            ;;
        *)
            ;;
    esac

    echo "${error}"
}

nmcli_is_managed() {
    if [ $nmcli == "0" ]; then
        if [ "$(nmcli d | grep ${iface} | grep unmanaged)" != "" ]; then
            managed="no"
        else
            managed="yes"
        fi
    fi
}

# restore the state of the interface used as it was before
restore() {
    if [ "$nmcli" == "0" ] && [ $managed != "no" ]; then
        # tell nmcli to manage the interface again
        sudo nmcli device set ${iface} managed yes >/dev/null 2>/dev/null
    fi
}

# prepare the interface to use
prepare() {
    if [ "$nmcli" == "0" ] && [ $managed != "no" ]; then
        # tell nmcli not to manage the interface
        sudo nmcli device set ${iface} managed no >/dev/null 2>/dev/null
        if [ "$?" != "0" ]; then
            log "error" "Unable to set unmanaged state of Network Manager for ${iface}." >&2
            exit 1
        fi
    fi
}

stop() {
    docker compose down
    restore
}

start_victim() {
    cd ${VICTIM_PATH}
    docker compose up
}

start_attack() {
    cd ${ATTACK_PATH}
    docker compose up
}

start() {
    prepare

    case $target in
        "victim")
            start_victim
            ;;
        "attack")
            start_attack
            ;;
        *)
            usage
            ;;
    esac
}

if [ "$#" != "2" ]; then
    usage
fi

target=$1
iface=$2

ip_cmd=$(which ip 2>&1)
if [ "$?" != "0" ]; then
    log "error" "${ip_cmd}" >&2
    exit 1;
fi

which nmcli >/dev/null 2>/dev/null
nmcli=$?
nmcli_is_managed

trap "stop" SIGINT

start