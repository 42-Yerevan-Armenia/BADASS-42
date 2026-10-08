#!/bin/bash
set -Eeuo pipefail

ip link del vxlan10 2>/dev/null || true
ip link set br0 down 2>/dev/null || true
ip link del br0 2>/dev/null || true
ip addr flush dev eth2
ip addr add 10.1.1.10/30 dev eth2
ip link set eth2 up

ip link add br0 type bridge
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set eth0 master br0
ip link set vxlan10 master br0
ip link set eth0 up
ip link set vxlan10 up
ip link set br0 up

cat > /etc/frr/frr.conf <<'EOF'
hostname leaf4-arakhurs
!
interface lo
 ip address 1.1.1.4/32
!
router bgp 65001
 bgp router-id 1.1.1.4
 neighbor 1.1.1.1 remote-as 65001
 neighbor 1.1.1.1 update-source lo
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
!
router ospf
 ospf router-id 1.1.1.4
 network 10.1.1.8/30 area 0
 network 1.1.1.4/32 area 0
EOF

/etc/init.d/frr restart
