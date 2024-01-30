#!/bin/bash

# start the DHCP service
dnsmasq -C ./dhcp.conf

# start hostapd
hostapd /etc/hostapd/hostapd.conf