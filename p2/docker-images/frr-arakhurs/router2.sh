#!/bin/bash
set -e
ip link del vxlan10 2>/dev/null || true
ip link set br0 down 2>/dev/null || true
ip link del br0 2>/dev/null || true

ip addr del 10.1.1.2/24 dev eth0 2>/dev/null || true
ip addr add 10.1.1.2/24 dev eth0
ip link set eth0 up
ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link set eth1 up
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
ip link set vxlan10 master br0
ip link set vxlan10 up

FRR_CONF="/etc/frr/frr.conf"

cat > "${FRR_CONF}" <<EOF
frr version 8.1
frr defaults traditional
hostname router-arakhurs-2
log stdout

router ospf
 ospf router-id 10.1.1.2

router bgp 65001
 bgp router-id 10.1.1.2
 neighbor 10.1.1.1 remote-as 65001
EOF

/etc/init.d/frr restart 2>/dev/null || /etc/init.d/frr start
