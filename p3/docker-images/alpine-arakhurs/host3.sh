#!/bin/bash
set -e

ip addr del 10.1.1.13/24 dev eth0 2>/dev/null || true
ip addr add 10.1.1.13/24 dev eth0
ip link set eth0 up

ip route del default 2>/dev/null || true
ip route add default via 10.1.1.4 dev eth0
