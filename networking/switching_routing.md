# IP Address
IP address is a unique address that identifies a device on the network.

Mask is used to separate the network part and the host part of the IP address.
Network part is used to identify the network. If any number change in this ip address, it means the device is in a different network.
Host part is used to identify the device on the network.

---

- Every part of the IP address is 8 bits.
- IP address is 32 bits. Every 8 bit skip a dot.
- `<first_part>.<second_part>.<third_part>.<fourth_part>/<mask>`
- Because of that, the range of the every part is 0-255.
- With the mask, we will separate the network part and the host part. 
  - 255.255.255.0/24 -> fourth part can be 0-255 (256 combinations)
  255.255.0.0/16 -> third part and fourth part can be 0-255. (65,536 combinations)

---

192.168.1.0/24
- 192.168.1.0, 192.168.1.1, 192.168.1.2, .... can communicate with each other with switch.

192.168.1.0/24
192.168.2.0/24
- These IP addresses are in different networks. And they can't communicate with each other directly.
- We need a router to communicate between these networks.
- Router is a layer 3 device that uses IP addresses to forward traffic between devices on different networks.

# Switching (1 Network)
I have a 2 system that names are A and B.
How does system A reach B?

We can use a switch to connect A and B. Switches are layer 2 devices that use MAC addresses to forward traffic between devices on the same network.
Once it has the MAC address, it can send packets directly to B.

The important thing is that switch is a network. We can connect multiple devices to the switch.

---

We need an interface on each server to connect to the switch.
We can use the `ip` command to configure the interface.

Let's assume, switch have ip that `192.168.1.0`.

Inside the A and B machine separately,

```bash
# ip lik command is used to show the interfaces
ip link

# ip link set command is used to set the interface up or down
# dev is used to specify the interface. it means device
# up is used to set the interface up
# eth0 is the interface name
# this command will set the eth0 interface up.
ip link set dev eth0 up
```

---

Add an IP address to the interface.

Inside the A machine,

```bash
# ip addr add command is used to add an IP address to the interface
# This ip address is used to communicate with other devices on the network
# This device is open to the network with this ip address.
ip addr add 192.168.1.10/24 dev eth0
```

Inside the B machine,

```bash
ip addr add 192.168.1.11/24 dev eth0
```

---

Now, A can reach B by sending packets to B's MAC address.

In the A machine,

```bash
# ping command is used to send packets to the destination
ping 192.168.1.11
```


# Routing (Multiple Servers Connecting Each Other) (Networks)
We will use a router to connect multiple switches.
We will take help from the router to reach the different networks (switches).

For understand the example,
- Switch 1:
  - Switch IP: 192.168.1.0
  - Server A IP: 192.168.1.11
  - Server B IP: 192.168.1.10
- Switch 2:
  - Switch IP: 192.168.2.0
  - Server C IP: 192.168.2.10
  - Server D IP: 192.168.2.11

In this example, server B wants to reach server C.

Router is a layer 3 device that uses IP addresses to forward traffic between devices on different networks.

Switch 1 will have a router with 192.168.1.1 ip address.
Switch 2 will have a router with 192.168.2.1 ip address.

# Gateway
- Gateway is the IP address of the router. It's a gate to the other networks.
- This gate will open this router to the other networks.

---

> Very important: We should create an ip address and subnet mask and route (gateway) for each system (Server A, B, C, D).

We can see the current route configuration with the `route` command.

Open server A, B, C, D look at the route configuration.

```bash
# route command is used to show the current route configuration
route

# Destination is the network that we want to reach
# Gateway is the IP address of the router
# Genmask is the mask of the network
# Flags is the status of the route
# Metric is the cost of the route
# Ref is the reference count
# Use is the number of lookups ()
# Iface is the interface that we will use to reach the destination
```

Add a route to the system for forwarding the packets to the other network.
Again open server A, B separately.

```bash
# This means, if you want to send a packet to the 192.168.2.0 network, forward it to the 192.168.1.1 (Router IP).
# This router will forward the packet to the other network.
ip route add 192.168.2.0/24 via 192.168.1.1

# Destination: 192.168.2.0
# Gateway: 192.168.1.1 (Router IP) -> This is the gate to the other network
# Genmask: 255.255.255.0
# Flags: UG (Up and Gateway)
# Metric: 0 (Cost)
# Ref: 0 (Reference count)
# Use: 0 (Number of lookups)
# Iface: eth0 (Interface)
```

Open server C, D separately.

```bash
# This means, if you want to send a packet to the 192.168.1.0 network, forward it to the 192.168.2.1 (Router IP).
# This router will forward the packet to the other network.
ip route add 192.168.1.0/24 via 192.168.2.1
```

But you know, we can have multiple websites to reach. We can't add a route for each website.
Because of that, we can use the default route.
We could also use 0.0.0.0 as the destination. (It's same with default)

```bash
# This means, if you want to send a packet to the other network, forward it to the <Router IP>.
# This router will forward the packet to the other network.
ip route add default via <Router IP>
```

# Example

A can reach B.
B can reach C.

A want to reach C by using B.

I have 3 systems that names are A, B, C.
I have 2 router that names are R1, R2.
I have 2 switch that names are S1, S2.

A ip address: 192.168.1.5 (eth0)
B have 2 ip address with 2 interfaces. (eth0, eth1) (R1, R2)
C ip address: 192.168.2.5 (eth0)

R1 ip address: 192.168.1.6
R2 ip address: 192.168.2.6

S1 ip address: 192.168.1.0
S2 ip address: 192.168.2.0


Open server A;

```bash
ping 192.168.2.5
# Connect: Network is unreachable

ip link set dev eth0 up

ip addr add 192.168.1.5 dev eth0

ip route add 192.168.2.0/24 via 192.168.1.6

ping 192.168.2.5
# Wait for the response
```

Open server B;

```bash
# create 2 interfaces
ip link set dev eth0 up
ip link set dev eth1 up

ip addr add 192.168.1.6 dev eth0
ip addr add 192.168.2.6 dev eth1

ip route add 192.168.1.0/24 via 192.168.2.6

# in default B can not forward the packets A to C
# We need to enable the forwarding
cat /proc/sys/net/ipv4/ip_forward
# 0

echo 1 > /proc/sys/net/ipv4/ip_forward
# 1

# in this file we can enable the forwarding permanently. This is the second way.
cat /etc/sysctl.conf
```

Open server C;

```bash
ip link set dev eth0 up

ip addr add 192.168.2.5 dev eth0
```


Open server A again;

```bash
ping 192.168.2.5
# Reply from .....
# Reply from .....
# Reply from .....
```