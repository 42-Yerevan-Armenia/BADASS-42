#!/bin/bash
set -Eeuo pipefail
ip addr flush dev eth0 2>/dev/null || true
ip addr flush dev eth1 2>/dev/null || true
ip addr flush dev eth2 2>/dev/null || true
ip link set eth0 down 2>/dev/null || true
ip link set eth1 down 2>/dev/null || true
ip link set eth2 down 2>/dev/null || true
ip link del vxlan10 2>/dev/null || true
ip link del br0 2>/dev/null || true
