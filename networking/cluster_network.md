# Cluster Network
In cluster, all nodes is a system on the network.

For example, your network is `192.168.1.0/24`. You have 3 nodes. 
Their ip addresses are `192.168.1.10`, `192.168.1.11`, `192.168.1.12`.
And All nodes have eth0 interface with these ip addresses.
And all nodes have a unique hostnames and mac addresses.

- Master Node
  - Hostname: master
  - IP Address: `192.168.1.10`
  - Mac Address: `00:00:00:00:00:01`
- Worker Node 1
  - Hostname: worker1
  - IP Address: `192.168.1.11`
  - Mac Address: `00:00:00:00:00:02`
- Worker Node 2
  - Hostname: worker2
  - IP Address: `192.168.1.13`
  - Mac Address: `00:00:00:00:00:03`

---

In the node, The components are some specific ports in the system. They use these ports for communication.
- Kubelet
  - 1025
- Etcd
  - 2379 (For Client Communication)
  - 2380 (For Leader Election)
- Kube-apiserver
  - 6443
- Kube-controller-manager
  - 10257
- Kube-scheduler
  - 10259
- Service
  - 30000-32767 (NodePort)


# Lab
Let's look at master node ip address.

```bash
kubectl get nodes -o wide
```

Find the network interface of the master node.

```bash
ip addr

# find the ip address of the master node in which interface
# assume we found the ip address in eth0 interface

ip addr show eth0
# more clear output
```

Find the network interface of the worker node.

```bash
# we have to find ip address and ssh to the worker node
# Because this network interface is inside the worker node.
kubectl get nodes -o wide

ssh <worker_node_ip_address>
# or
# system can find the ip address of the worker node with hostname
# Because cluster save the ip address of the worker node in /etc/hosts file
ssh node1

ip addr
# find the ip address of the worker node in which interface
# assume we found the ip address in eth0 interface

ip addr show eth0
# more clear output
```

Let's see containerd bridge interface name.

```bash
ip addr show type bridge
```

If I ping the google, where will go to the packet first?

```bash
ip route
# find the default route
# Default route is the gateway of the system
```


# Pod Network
We should know requirements of the pod network.
- All pods can communicate with other pods any other node without NAT.


Let's assume we have 3 nodes and have a cluster network.

Cluster Network: `192.168.1.0/24`
- Master Node
  - Hostname: master
  - IP Address: `192.168.1.11`
- Worker Node 1
  - Hostname: worker1
  - IP Address: `192.168.1.12`
- Worker Node 2
  - Hostname: worker2
  - IP Address: `192.168.1.13`

---

Nodes have an internal bridge network (switch). (v-net-0)
And all pods connect to this bridge network with a veth pair.

`ip link add v-net-0 type bridge`
`ip link set v-net-0 up`
`ip addr add <v-net-0 ip address> dev v-net-0`
`ip route add <node eth0 ip address> dev v-net-0` (For communication with the outside of the node)
- Master Node 
  - Network: `10.244.1.0/24`
  - v-net-0 ip address: `10.244.1.1`
- Worker Node 1
  - Network: `10.244.2.0/24`
  - v-net-0 ip address: `10.244.2.1`
- Worker Node 2
  - Network: `10.244.3.0/24`
  - v-net-0 ip address: `10.244.3.1`

---

After that, a script will execute for creating a veth pair for each pod.

2 pods in the worker node 1. They got 2 ip addresses from the worker node 1 bridge network.
- Pod 1
  - IP Address: `10.244.1.2`
- Pod 2
  - IP Address: `10.244.1.3`

It happened with the script. The script creates a veth pair for each pod.

`ip link add veth0 type veth peer name veth1`
`ip link add veth2 type veth peer name veth3`

And connect one side of the veth pair to the pod network bridge network.

`ip link set veth0 master v-net-0`
`ip link set veth2 master v-net-0`

And connect the other side of the veth pair to the pod network namespace.

`ip link set veth1 netns <pod_namespace>`
`ip link set veth3 netns <pod_namespace>`

And assign the ip address to the pod network namespace.

`ip netns exec <pod_namespace> ip addr add <ip_address> dev veth1`
`ip netns exec <pod_namespace> ip addr add <ip_address> dev veth3`

And up the veth pair.

`ip netns exec <pod_namespace> ip link set veth1 up`
`ip netns exec <pod_namespace> ip link set veth3 up`

---

After that we can assume that we have these;

- Worker Node 1
  - eth0: `192.168.1.12`
  - v-net-0: `10.244.2.1`
  - pod 1: `10.244.2.2`
  - pod 2: `10.244.2.3`
- Worker Node 2
  - eth0: `192.168.1.13`
  - v-net-0: `10.244.3.1`
  - pod 1: `10.244.3.2`


How will the pod 1 in the worker node 1 communicate with the pod 1 in the worker node 2?

Nodes in same network. Because of that for all pods in the cluster, system create a route command in other nodes.
Already we executed route for v-net-0 bridge network for reaching the outside of the node.

Run this command in the node 1.
`ip route add 10.244.3.2 via 192.168.1.13`

Run this command in the node 2.
`ip route add 10.244.2.2 via 192.168.1.12`
`ip route add 10.244.2.3 via 192.168.1.12`



All of that is the pod networking.
But we did manually. We can use the CNI plugins for this. Already CNI plugins do this automatically in the cluster.


---

We can find the cni configurations in the `/etc/cni/net.d` directory.
In this directory, we can see the network configuration files.
In the directory, we can open the `10-bridge.conf` file. This file is the bridge network configuration file.
When we change this file with other configuration, node will use this configuration for the pod network.


we can open `/opt/cni/bin/` directory. In this directory, cni plugins binary files are located.
These binary files are used for creating the network configuration in the `/etc/cni/net.d` directory.

We can see the `bridge` binary file in this directory. This binary file is used for functionality of the bridge network configuration.

`./net-script.sh` have cni commands.

```bash
cat /opt/cni/bin/

./net-script.sh add <container_id> <namespace>
./net-script.sh del <container_id> <namespace>
```


# Weave Network
Weave network is a CNI plugin. It is a network overlay solution.
Weave network creates a virtual network between the nodes.
Weave network uses the VXLAN protocol for creating a virtual network.
It's efficient when the nodes are in different networks or different data centers or so many nodes.

WE can use the weave network with apply the yaml file.

```bash
# It will create a daemonset in the cluster.
# And it will create some other resources for security.
kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')

# It creates a deamonset because it should run in all nodes.
# And it creates this in the kube-system namespace.


# We can see the weave pod logs with this command.
kubectl logs -n kube-system weave-net-xxxxx weave
```

When we applied the weave network, it creates a virtual network between the nodes.
And it writes the network configuration in the `/etc/cni/net.d/10-weave.configlist` file automatically.


## Lab

Look at the container runtime in the node.

```bash
# inside the node
ps aux | grep -i kubelet | grep -i container-runtime-endpoint
```