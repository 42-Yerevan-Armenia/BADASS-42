#!/bin/bash
set -Eeuo pipefail

# Route reflector: eth0, eth1 and eth2 each connect to a leaf VTEP.
ip addr flush dev eth0
ip addr flush dev eth1
ip addr flush dev eth2
ip addr add 10.1.1.1/30 dev eth0
ip addr add 10.1.1.5/30 dev eth1
ip addr add 10.1.1.9/30 dev eth2
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

cat > /etc/frr/frr.conf <<'EOF'
hostname rr-arakhurs
!
interface lo
 ip address 1.1.1.1/32
!
router bgp 65001
 bgp router-id 1.1.1.1
 bgp cluster-id 1.1.1.1
 neighbor EVPN-LEAVES peer-group
 neighbor EVPN-LEAVES remote-as 65001
 neighbor EVPN-LEAVES update-source lo
 bgp listen range 1.1.1.0/29 peer-group EVPN-LEAVES
 address-family l2vpn evpn
  neighbor EVPN-LEAVES activate
  neighbor EVPN-LEAVES route-reflector-client
 exit-address-family
!
router ospf
 ospf router-id 1.1.1.1
 network 10.1.1.0/30 area 0
 network 10.1.1.4/30 area 0
 network 10.1.1.8/30 area 0
 network 1.1.1.1/32 area 0
EOF

/etc/init.d/frr restart
