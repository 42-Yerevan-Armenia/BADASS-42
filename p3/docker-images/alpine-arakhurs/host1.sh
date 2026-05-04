#!/bin/bash
set -e

# Assign IP to host
ip addr del 10.1.1.11/24 dev eth0 2>/dev/null || true
ip addr add 10.1.1.11/24 dev eth0
ip link set eth0 up

# Set default gateway to leaf2
ip route del default 2>/dev/null || true
ip route add default via 10.1.1.2 dev eth0
