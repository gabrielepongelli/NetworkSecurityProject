#!/usr/bin/env bash

VICTIM_PATH="./network"
ATTACK_PATH="./dragonslayer"
TEMPLATE_DIR="templates"
TEMPLATE_PATH="./${TEMPLATE_DIR}"

usage() {
    echo "Usage: ${0} <victim|attack> <iface>" >&2
    exit 1
}

log() {
    local level=$1
    local error=$2

    case "$level" in
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

check_ip_cmd() {
    local res=$(which ip 2>&1)
    if [ "$?" != "0" ]; then
        log "error" "${res}" >&2
        exit 1;
    fi
}

check_iface() {
    local iface=$1

    local res=$(ip a s "${iface}" 2>&1)
    if [ "$?" != "0" ]; then
        log "error" "${res}" >&2
        exit 1;
    fi
}

has_nmcli_cmd() {
    which nmcli >/dev/null 2>/dev/null
    if [ "$?" == "0" ]; then
        echo "yes"
    else
        echo "no"
    fi
}

nmcli_is_iface_managed() {
    local has_nmcli=$1
    local iface=$2

    if [ "$has_nmcli" == "yes" ]; then
        if [ "$(nmcli d | grep "${iface}" | grep unmanaged)" != "" ]; then
            echo "no"
        else
            echo "yes"
        fi
    fi
}

# restore the state of the interface used as it was before
restore() {
    local iface=$1
    local has_nmcli=$2
    local is_iface_managed=$3

    if [ "$has_nmcli" == "yes" ] && [ "$is_iface_managed" == "yes" ]; then
        # tell nmcli to manage the interface again
        sudo nmcli device set "${iface}" managed yes >/dev/null 2>/dev/null
    fi
}

# prepare the interface to use
prepare() {
    local iface=$1
    local has_nmcli=$2
    local is_iface_managed=$3

    if [ "$has_nmcli" == "yes" ] && [ "$is_iface_managed" == "yes" ]; then
        # tell nmcli not to manage the interface
        sudo nmcli device set "${iface}" managed no >/dev/null 2>/dev/null
        if [ "$?" != "0" ]; then
            log "error" "Unable to set unmanaged state of Network Manager for ${iface}." >&2
            exit 1
        fi
    fi
}

configure() {
    local iface=$1

    find "$TEMPLATE_PATH" -type f | while IFS= read -r line; do
        local new_file_path=$(echo "$line" | sed "s=/${TEMPLATE_DIR}==")
        echo "$(export IFACE="$iface"; cat "$line" | envsubst)" > "${new_file_path}"
    done
}

stop() {
    docker compose down
}

start() {
    configure $@
    docker compose up
}

main() {
    if [ "$#" != "2" ]; then
        usage
    fi

    local target=$1
    local iface=$2

    check_ip_cmd
    check_iface "$iface"

    local has_nmcli=$(has_nmcli_cmd)
    local is_iface_managed=$(nmcli_is_iface_managed "$has_nmcli" "$iface")

    prepare "$iface" "$has_nmcli" "$is_iface_managed"

    case "$target" in
        "victim")
            cd ${VICTIM_PATH}
            ;;
        "attack")
            cd ${ATTACK_PATH}
            ;;
        *)
            usage
            ;;
    esac

    start "$iface"
    stop
    restore "$iface" "$has_nmcli" "$is_iface_managed"
}

main $@