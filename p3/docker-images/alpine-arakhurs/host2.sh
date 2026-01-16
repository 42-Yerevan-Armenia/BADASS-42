#!/bin/bash
set -e

ip addr add 10.1.1.12/24 dev eth0
ip link set eth0 up

ip route add default via 10.1.1.3
