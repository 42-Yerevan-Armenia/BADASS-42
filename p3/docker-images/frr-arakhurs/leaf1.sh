#!/bin/bash
# underlay
ip link set eth0 up
ip addr add 192.168.0.11/24 dev eth0

# bridge
ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0

# vxlan (EVPN — no multicast)
ip link add vxlan10 type vxlan id 10 dstport 4789 local 192.168.0.11 nolearning
ip link set vxlan10 up
ip link set vxlan10 master br0
