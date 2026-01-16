#!/bin/bash
set -e
ip addr flush dev eth0
ip link set eth0 down
brctl delbr br0 2>/dev/null || true
ip link del vxlan10 2>/dev/null || true
