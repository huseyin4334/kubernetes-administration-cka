# IP Address Management In The Cluster
CNI is telling in the standards, "must manage IP address assignment to PODs".
Ok cni assigns ip addresses but, how is this managed in the cluster?

First remember;
System automatically assigns ip address ranges to the cluster, pods, and services.

- `--cluster-cidr` flag is used for the cluster.
  - This information defines the range of IP addresses that are available for pods.
  - It defines generally for all pods in the cluster.
  - Default value is `10.244.0.0/16`.
  - This information is used by the CNI plugin and set with kube-controller-manager.
  - This information uses for assign ip addresses to the nodes.
- `--pod-cidr` flag is used for the pods.
  - This information defines the range of IP addresses that are available for pods.
  - It defines generally for all pods in the node.
  - Default value is `10.244.<node_number>.0/24`.
  - This information is used by the CNI plugin and set with kubelet.
  - This information uses for assign ip addresses to the pods.
- `--service-cluster-ip-range` flag is used for the services.
  - This information defines the range of IP addresses that are available for services.
  - Default value is `10.96.0.0/12`.
  - This information set in the kube-apiserver.
  - This information uses for assign ip addresses to the services.

---

After these information;
Every node have ip ranges for the pods.
It has a list for ip addresses that are available for the pods.

| IP         | Status   | Pod   |
|------------|----------|-------|
| 10.244.1.2 | Assigned | Pod 1 |
| 10.244.1.3 | Assigned | Pod 2 |
| 10.244.1.4 | Free     |       |


In the cluster NNI has ip table management plugin for managing the ip addresses.
Host-local, dhcp are the examples of the ip table management plugins.

CNI configuration has a field for the ip table management plugin.
We can see this field in the CNI configuration file with the `ipam` field.

```bash
cat /etc/cni/net.d/10-bridge.conf
```

```json
{
    "cniVersion": "0.3.1",
    "name": "mynet",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.244.0.0/16",
        "routes": [
            { "dst": "0.0.0.0/0" }
        ]
    }
}
```


# Weave Management
Weave manage ip addresses differently.
Weave in default, uses the `10.32.0.0/12` ip address range for all clusters.
This gives us 1.048.576 ip addresses for the pods.

We can set the ip ranges in the weave yaml file.

```yaml
spec:
  initContainers:
    - name: weave-init
  ...
  containers:
    - name: weave
      env:
        - name: IPALLOC_RANGE
          value: 10.244.0.0/16
```

We can see the default configured range in the weave configuration file or in the logs.

```bash
kubectl logs -n kube-system weave-net-xxxxx

# ipalloc-range: 10.244.0.0/16
```

```bash

cat /etc/cni/net.d/10-weave.conf

# ipam > range field
```


# Lab

See the default gateway in the node1

```bash
# find node ip or use node name directly.
kubectl get nodes -o wide

# ssh to the node
ssh node1

# find the pod ip ranges
ip route

# find the default gateway
```



# Service IP Address Management
Service ip addresses are managed by the kube-apiserver.
Service ip addresses are assigned from the `--service-cluster-ip-range` flag.

But you know services have some types.

Cluster IP
- Cluster ip just accessible in the cluster.
- When we create service with this type, it gets an ip address from the `--service-cluster-ip-range` flag.

NodePort
- NodePort is accessible from the outside of the cluster.
- When we create service with this type, it gets an ip address from the `--service-cluster-ip-range` flag.
- And it gets a port from the `--service-node-port-range` flag or from the defined range.


---

In the nodes, we have a kubelet and kube-proxy.
kubelet is control the pods via kube-apiserver.
When create or delete a pod also cni plugin is called by the kubelet to for execute the network operations.

Kube-proxy is responsible for the services.
When we create a service, kube-proxy creates iptables rules for the service.
Services not specific to the nodes. Because of that, kube-proxy creates iptables rules in all nodes.

Kube proxy has some modes:
- userspace
- ipvs
- iptables

These modes are used that how manage the rules in the system. 
We can set the mode with the `--proxy-mode` flag.

iptables mode is the default mode. When create a service, kube-proxy creates iptables rules in the kernel level.
Then, all rules managing by the kernel in the system. Because of that it is faster than the other modes.

## Example

I have a pod with db name and `10.244.1.2` ip address in the node1.

I have a service with db-service name, `10.103.132.104` ip address, `3306` pod in the cluster.


Let's look at the nat table in the node1.

```bash
iptables -t nat -L | grep db-service

# KUBE-SVC-XXXXX  tcp --  anywhere 10.103.132.104 /* default/db-service: cluster IP */ tcp dpt:3306
# DNAT       tcp --  anywhere  anywhere /* default/db-service: cluster IP */ tcp to:10.244.1.2:3306
# DNAT is the destination definition for the service.
```

Also, we can see these rules in the kube-proxy logs.

```bash
kubectl logs -n kube-system kube-proxy-xxxxx

# Using iptables Proxier. -> iptables mode
# ...
# Adding new service "default/db-service:3306" at 10.103.132.104:3306/TCP
```