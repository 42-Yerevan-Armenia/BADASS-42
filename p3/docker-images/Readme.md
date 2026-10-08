# P3 - BGP EVPN

This topology demonstrates VXLAN VNI 10 with BGP EVPN MAC learning. Router 1 is the route reflector (RR). Routers 2, 3, and 4 are VTEPs. Each VTEP bridges one host into the VXLAN segment.

## Topology

| Link | Purpose |
| --- | --- |
| `router-arakhurs-1 eth0` <-> `router-arakhurs-2 eth0` | RR to VTEP 2, `10.1.1.0/30` |
| `router-arakhurs-1 eth1` <-> `router-arakhurs-3 eth1` | RR to VTEP 3, `10.1.1.4/30` |
| `router-arakhurs-1 eth2` <-> `router-arakhurs-4 eth2` | RR to VTEP 4, `10.1.1.8/30` |
| `router-arakhurs-2 eth1` <-> `host-arakhurs-1 eth1` | Host-facing bridge port |
| `router-arakhurs-3 eth0` <-> `host-arakhurs-2 eth0` | Host-facing bridge port |
| `router-arakhurs-4 eth0` <-> `host-arakhurs-3 eth0` | Host-facing bridge port |

Loopbacks are `1.1.1.1/32` through `1.1.1.4/32`. All BGP speakers use AS `65001`. Hosts are on `30.1.1.0/24`:

| Node | Address |
| --- | --- |
| `host-arakhurs-1` | `30.1.1.1/24` on `eth1` |
| `host-arakhurs-2` | `30.1.1.2/24` on `eth0` |
| `host-arakhurs-3` | `30.1.1.3/24` on `eth0` |

## Start and Configure

1. Build the images from `p3/docker-images`:

```sh
make build
```

2. In GNS3, add four `frr-arakhurs` nodes and three `alpine-arakhurs` nodes. Create the links listed in the topology table, then start all seven nodes.

3. From `p3/docker-images`, apply the configuration scripts to the active GNS3 nodes:

```sh
make configure-gns3
```

The target checks that all seven expected containers and interfaces exist before applying any configuration. It configures the route reflector, all VTEPs, and all hosts.

## Manual Checks

Open a console for the named node in GNS3 and run the commands below.

### 1. Check the RR

On `router-arakhurs-1`:

```sh
ip -4 addr show
vtysh -c 'show ip ospf neighbor'
vtysh -c 'show bgp l2vpn evpn summary'
vtysh -c 'show bgp l2vpn evpn route'
```

Expected:

- `eth0`, `eth1`, and `eth2` have `10.1.1.1/30`, `10.1.1.5/30`, and `10.1.1.9/30`.
- Loopback has `1.1.1.1/32`.
- Three OSPF neighbors are `Full` (`1.1.1.2`, `1.1.1.3`, and `1.1.1.4`).
- Three dynamic BGP EVPN neighbors are established. `State/PfxRcd` is a number, not `Idle`, `Active`, or `Connect`.
- After host traffic, EVPN routes include type-2 routes beginning with `[2]`, one for each host MAC address.

### 2. Check Each VTEP

On `router-arakhurs-2`, `router-arakhurs-3`, and `router-arakhurs-4`:

```sh
ip -4 addr show
bridge link show
ip -d link show vxlan10
vtysh -c 'show ip ospf neighbor'
vtysh -c 'show bgp l2vpn evpn summary'
vtysh -c 'show bgp l2vpn evpn vni'
vtysh -c 'show bgp l2vpn evpn route'
bridge fdb show br br0
```

Expected:

- One OSPF neighbor, `1.1.1.1`, in `Full` state.
- One established EVPN BGP neighbor, `1.1.1.1`.
- `vxlan10` shows `vxlan id 10` and UDP destination port `4789`.
- `br0` contains `vxlan10` and the host-facing interface.
- `show bgp l2vpn evpn vni` shows L2 VNI `10` with `Advertise All VNI flag: Enabled`.
- After pings, the EVPN table and bridge FDB contain remote MAC addresses.

### 3. Check Hosts and Connectivity

BusyBox does not support `ip -br`, so use `ip addr show`.

On `host-arakhurs-1`:

```sh
ip addr show eth1
ping -c 3 30.1.1.2
ping -c 3 30.1.1.3
```

On `host-arakhurs-2`:

```sh
ip addr show eth0
ping -c 3 30.1.1.1
ping -c 3 30.1.1.3
```

On `host-arakhurs-3`:

```sh
ip addr show eth0
ping -c 3 30.1.1.1
ping -c 3 30.1.1.2
```

Expected: every ping reports `0% packet loss`. The first packet can be slower while ARP and EVPN type-2 MAC routes are learned.

## Wireshark Tests

In GNS3, right-click a link and select **Start capture**. Generate traffic with the host ping commands while the capture is active.

### OSPF

Capture one RR-to-VTEP link, for example `router-arakhurs-1 eth0` <-> `router-arakhurs-2 eth0`.

Wireshark display filter:

```text
ospf
```

Expected: OSPF Hello packets and adjacency database exchange traffic. This proves the underlay route protocol is active.

### BGP EVPN

Capture any RR-to-VTEP link. Use either filter:

```text
bgp
```

```text
tcp.port == 179
```

Expected: a TCP session on port 179 between the VTEP loopback and the RR loopback. Use `vtysh -c 'show bgp l2vpn evpn route'` alongside Wireshark to show that this session distributes EVPN routes.

### VXLAN Encapsulation

Capture an RR-to-VTEP link, then ping between two hosts on different VTEPs.

Wireshark display filter:

```text
vxlan
```

Alternative filter:

```text
udp.port == 4789
```

Expected: UDP packets on port 4789 with VNI `10`. Expand the VXLAN layer and confirm the inner Ethernet frame carries the host traffic.

### End-to-End ICMP

While pinging `host-arakhurs-2` from `host-arakhurs-1`, capture either host-facing link or an RR-to-VTEP underlay link.

Wireshark display filter:

```text
icmp
```

On an underlay link, combine it with VXLAN:

```text
vxlan && icmp
```

Expected: ICMP Echo Request and Echo Reply. On underlay links, ICMP is encapsulated inside VXLAN UDP/4789 packets.

## Useful Recovery

To apply configuration again after restarting all GNS3 nodes:

```sh
cd /home/vboxuser/Desktop/project/p3/docker-images
make configure-gns3
```

If the target says that a node is missing an interface, correct that link in GNS3 first. The required port map is documented in [gns3.txt](gns3.txt).
