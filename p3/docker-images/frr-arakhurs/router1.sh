#!/bin/bash
set -e

# --------------------------
# Underlay IP (Spine)
# --------------------------
IP_UNDERLAY="10.1.1.1"
ip addr add ${IP_UNDERLAY}/24 dev eth0
ip link set eth0 up

# --------------------------
# Bridge creation
# --------------------------
ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link set eth1 up

# --------------------------
# VXLAN overlay
# --------------------------
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
ip link set vxlan10 master br0
ip link set vxlan10 up

# --------------------------
# Dynamic FRR config (Spine / RR)
# --------------------------
FRR_CONF="/etc/frr/frr.conf"

cat > ${FRR_CONF} <<EOF
hostname spine1
!
router ospf
 network 10.1.1.0/24 area 0
 ospf router-id ${IP_UNDERLAY}
!
router bgp 65001
 bgp router-id ${IP_UNDERLAY}
 bgp cluster-id ${IP_UNDERLAY}
 neighbor LEAVES peer-group
 neighbor LEAVES remote-as 65001
 neighbor 10.1.1.2 peer-group LEAVES
 neighbor 10.1.1.3 peer-group LEAVES
 neighbor 10.1.1.4 peer-group LEAVES
 address-family l2vpn evpn
  neighbor LEAVES activate
  advertise-all-vni
 exit-address-family
EOF

# Start FRR
/etc/init.d/frr start
