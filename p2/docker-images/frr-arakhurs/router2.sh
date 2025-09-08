#!/bin/bash
set -e
ip addr add 10.1.1.2/24 dev eth0
ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
ip link set vxlan10 master br0
ip link set vxlan10 up
ip link set eth1 up
