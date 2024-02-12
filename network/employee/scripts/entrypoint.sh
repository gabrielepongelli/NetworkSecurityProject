#!/bin/bash

# echo the IPv4 address
echo "IP: $(ip -j address show eth0 | jq -r '.[].addr_info[].local')"

# prevent the termination of the container
tail -f /dev/null