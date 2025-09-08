#!/bin/bash
set -e
ip link del vxlan10 2>/dev/null || true
ip link set br0 down 2>/dev/null || true
ip link del br0 2>/dev/null || true
ip addr flush dev eth0
ip addr flush dev eth1