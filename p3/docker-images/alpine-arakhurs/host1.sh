#!/bin/sh
set -eu

# Hosts share the bridged VXLAN segment; they are not part of the OSPF underlay.
ip addr flush dev eth1
ip addr add 30.1.1.1/24 dev eth1
ip link set eth1 up
