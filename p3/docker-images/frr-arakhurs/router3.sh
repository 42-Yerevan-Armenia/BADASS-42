#!/bin/bash
set -e

IP_UNDERLAY="10.1.1.3"
ip addr add ${IP_UNDERLAY}/24 dev eth0
ip link set eth0 up

ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link set eth1 up

ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
ip link set vxlan10 master br0
ip link set vxlan10 up

FRR_CONF="/etc/frr/frr.conf"

cat > ${FRR_CONF} <<EOF
hostname leaf3
!
router ospf
 network 10.1.1.0/24 area 0
 ospf router-id ${IP_UNDERLAY}
!
router bgp 65001
 bgp router-id ${IP_UNDERLAY}
 neighbor 10.1.1.1 remote-as 65001
 address-family l2vpn evpn
  advertise-all-vni
 exit-address-family
EOF

/etc/init.d/frr start
