# CNI
Container Network Interface (CNI) is a specification and libraries for writing plugins to configure network interfaces in Linux containers. 
It is a standard for connecting containers to networks.

- Create Network Namespace
- Create Bridge Interface
- Create veth pair
- Attach vEth to namespace
- Attach vEth to bridge
- Assign ip address to vEth in namespace and bridge
- Bring up vEth in namespace and bridge
- Enable NAT for outgoing traffic
- IP Masquerade for outgoing traffic

All of these steps are done by CNI plugins.

CNI plugins are executed by container runtime (like Docker, Kubernetes) when a container is created.

Bridge plugin is the default plugin for Docker. It executes the steps above.

There are many CNI plugins like flannel, calico, weave, etc. They are used for different network configurations.

All CNI plugins developed with container network interface (CNI) specification. They can be used with any container runtime that supports CNI.

---

But docker does not use CNI. It has container network model (CNM). It uses bridge, host, and none network modes.

When orchestrator (like Kubernetes) uses Docker as container runtime, it runs container with network mode none.
After that, it adds container to the network with bridge. It uses CNI plugins for this operation.
`bridge add <container_id> <network_id>` command is used for this operation.

When orchestrator uses containerd as container runtime, it uses CNI plugins directly. Because containerd supports CNI.