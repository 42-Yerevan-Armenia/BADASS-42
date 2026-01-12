## Router1 Script
echo '#!/bin/bash
set -e
ip addr add 10.1.1.1/24 dev eth0
ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
ip link set vxlan10 master br0
ip link set vxlan10 up
ip link set eth1 up
' > /root/router1.sh
chmod +x /root/router1.sh

## Router2 Script
echo '#!/bin/bash
set -e
ip addr add 10.1.1.2/24 dev eth0
ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
ip link set vxlan10 master br0
ip link set vxlan10 up
ip link set eth1 up
' > /root/router2.sh
chmod +x /root/router2.sh

## Host1 Script
echo '#!/bin/sh
set -e
ip addr add 10.0.10.1/24 dev eth0
ip link set eth0 up
' > /root/host1.sh
chmod +x /root/host1.sh

## Host2 Script
echo '#!/bin/sh
set -e
ip addr add 10.0.10.2/24 dev eth0
ip link set eth0 up
' > /root/host2.sh
chmod +x /root/host2.sh

## Router Reset Script
echo '#!/bin/bash
set -e
ip link del vxlan10 2>/dev/null || true
ip link set br0 down 2>/dev/null || true
ip link del br0 2>/dev/null || true
ip addr flush dev eth0
ip addr flush dev eth1
' > /root/reset_router.sh
chmod +x /root/reset_router.sh

## Host Reset Script
echo '#!/bin/sh
ip addr flush dev eth0
' > /root/reset_host.sh
chmod +x /root/reset_host.sh

## Router checks
ip -d link show vxlan10
ip link add br0 type bridge
ip link set eth1 master br0
ip link set vxlan10 master br0
ip link set br0 up
ip link set vxlan10 up
