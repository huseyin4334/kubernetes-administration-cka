# Namespace
- A namespace is a way to partition a single Linux instance into multiple virtual instances.
- Each namespace provides an isolated environment for processes, network interfaces, and routing tables.

ARP table: Address Resolution Protocol table
- ARP table is used to store the MAC addresses and their corresponding IP addresses.
- ARP table is used to resolve the MAC addresses to IP addresses.

Routing table
- Routing table is used to store the routes.
- Routes are used to forward the packets to the destination.

Network Namespace
- Network namespace is used to isolate the network resources.
- Each network namespace has its own network interfaces, routing tables, and ARP tables.

---

When we create a pod in Kubernetes, it creates a network namespace for the pod.
- Each pod has its own network namespace.
- Each pod has its own network interfaces, routing tables, and ARP tables.
- Also, each pod have an eth0 interface for the communication.


# Example

I have a system with an eth0 interface.
And I will create network namespaces in this system.

## Create A Network Namespace

Create a network namespace with the `ip netns add` command.

```bash
ip netns add red

ip netns add blue

ip netns list
```

## Let's Look At The Network Interfaces And Execute A Command In The Network Namespace

Let's look at interfaces.
`ip netns exec <namespace>` command is used to execute a command in the network namespace.

```bash
ip link
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 ...
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000 ...

# We will see only the default network namespace's host interfaces.

ip netns exec red ip link
# 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000 ...

# We will see the red network namespace's interfaces if there is any.
# We don't have eth0 interface in the red network namespace.
```

## Let's look at ARP And Routing Tables

Let's look at the ARP table.

```bash
arp
# Address                  HWtype  HWaddress           Flags Mask            Iface
# 172.17.0.21              ether   02:42:ac:11:00:15   C                     eth0
# ....

ip netns exec red arp
# Address                  HWtype  HWaddress           Flags Mask            Iface
```

Let's look at the routing table.

```bash
route
# Kernel IP routing table
# Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
# default         _gateway        0.0.0.0         UG    100    0        0 eth0
# ....

ip netns exec red route
# Kernel IP routing table
# Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
```

## Create A Virtual Ethernet Pair

We are creating a virtual ethernet pair for the communication between the network namespaces.
Ethernet is network interface. And we are creating a pair of ethernet interfaces.

We can use the `ip link add` command to create a virtual ethernet pair.

```bash
ip link add veth-red type veth peer name veth-blue

ip link
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 ...
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000 ...
# 3: veth-red: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000 ...
# 4: veth-blue: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000 ...

ip link set veth-red netns red # (veth-red is moved to the red network namespace)
ip link set veth-blue netns blue # (veth-blue is moved to the blue network namespace)

ip link
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 ...
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000 ...

# You can't see the veth-red and veth-blue interfaces in the default network namespace after moving them to the red and blue network namespaces.
```

Configure red network namespace's interface.

```bash
# We should set an IP address for the veth-red interface in the red network namespace.
# dev is used to specify the device.
ip netns exec red ip addr add 192.168.15.1 dev veth-red
# veth-red interface should be up. 
ip netns exec red ip link set veth-red up
```

Configure blue network namespace's interface.

```bash
# We should set an IP address for the veth-blue interface in the blue network namespace.
# dev is used to specify the device.
ip netns exec blue ip addr add 192.168.15.2 dev veth-blue
# veth-blue interface should be up.
ip netns exec blue ip link set veth-blue up
```

## Control Arp Tables for Matching New Interfaces

Let's look at the ARP table.

```bash
arp
# We won't see new interfaces in the default network namespace's ARP table.

ip netns exec red arp
# Address                  HWtype  HWaddress           Flags Mask            Iface
# 192.168.15.2             ether   0a:0b:0c:0d:0e:0f   C                     veth-red

ip netns exec blue arp
# Address                  HWtype  HWaddress           Flags Mask            Iface
# 192.168.15.2             ether   0a:0b:0c:0d:0e:0f   C                     veth-blue (veth-blue is looking for the veth-red ip address)
```

# Multiple Network Namespaces And Communication Them With Virtual Switch
we applied for 2 network namespaces. We will create a virtual switch to communicate between them.

## Virtual Switch
Virtual switch is a software switch that is used to connect multiple network namespaces.
We have some vehicles for this. We can use linux bridge, Open vSwitch, or macvlan.

We will use the linux bridge for this example.

## Create A Linux Bridge

```bash
ip link add v-net-0 type bridge

ip link
# ...
# 5: v-net-0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000 ...

# We should set the v-net-0 interface up.
ip link set v-net-0 up
```

## Delete The Virtual Ethernet Pair

```bash
ip netns exec red ip link del veth-red
ip netns exec blue ip link del veth-blue
```

## Create New Virtual Ethernet Pairs For The Linux Bridge

We will create a pair. One side of the pair will be connected to the linux bridge. The other side will be connected to the network namespace.

```bash
ip link add veth-red type veth peer name veth-red-br
ip link add veth-blue type veth peer name veth-blue-br

ip link set veth-red netns red
ip link set veth-blue netns blue

ip link set veth-red-br master v-net-0
ip link set veth-blue-br master v-net-0

ip netns exec red ip addr add 192.168.15.1 dev veth-red
ip netns exec red ip link set veth-red up

ip netns exec blue ip addr add 192.168.15.2 dev veth-blue
ip netns exec blue ip link set veth-blue up
```

## Set Ip Address To Bridge Interface

Don't forget if we want to communicate with the bridge interface, we should set an IP address for the bridge interface.
Because the bridge interface is a network interface. Network namespaces listen each other with the IP addresses.
ARP table is used to resolve the MAC addresses to IP addresses.

```bash
ip addr add 192.168.15.5/24 dev v-net-0
```

We set the red and blue bridge interfaces to the bridge interface.

Because of for example, the green network namespace wants to communicate with the red network namespace.

Green will connect to the bridge interface. And the bridge interface will forward the packets to the red network namespace.

```bash 
# 192.168.15.2 is the blue network namespace's ip address. We will send a ping request to the blue network namespace. It will go to the bridge interface.
# The bridge interface will forward the packets to the blue network namespace.
ip netns exec red ping 192.168.15.2
# PING ....
```


## Open The Bridge The Outside Of The Host

For example blue network namespace wants to communicate with the outside of the host.
host have an eth0 interface. And it has `192.168.1.2` ip address.

And LAN working for `192.168.1.0/24` network.

Other host has `192.168.1.3` ip address.

Then, we should set the bridge interface as the gateway for the blue network namespace to communicate with the outside of the host.

```bash
ip exec netns blue ip route add 192.168.1.0/24 via 192.168.15.5

# We said, if blue network namespace wants to communicate with the 192.168.1.0/24 network, forward the packets to the 192.168.15.5 ip address.
```

But don't forget we just opened the blue network namespace to just 1 network.
We can set default route for the blue network namespace to communicate with all networks.

```bash
ip exec netns blue ip route add default via 192.168.15.5
```

Let's route the bridge to the outside of the host.

```bash
# Nat is used to translate the ip addresses.
# So, Nat will translate the bridge interface's ip address to the eth0 interface's ip address.
# And it will do that just when the packets are going to the outside of the host. (POSTROUTING)
# Masquerade is a type of NAT. It is used to translate the ip addresses to the host's ip address.
# Then, with this command, all other network spaces will come to bridge. Bridge ip address will be translated to the host's ip address.
# And requests will go to the outside of the host.
iptables -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE
```

---

If outside system try to reach blue network namespace. But it can not reach it.

```bash
# When any request comes to the host's eth0 interface from 80 port, forward the packets to the blue network namespace's 80 port directly.
iptables -t nat -A PREROUTING -d 80 --to-destination 192.168.15.2:80 -j DNAT
```
