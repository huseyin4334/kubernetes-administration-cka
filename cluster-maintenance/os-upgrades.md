# How is Controlling Nodes By Kubernetes?
Kubernetes control node status with kubelet. When kubernetes can not take information from kubelet, it waits 5 minutes.
If the problem is not resolved, the pods marked dead. If these pods have replicaset, the replicaset creates new pods in another nodes.

This 5 minutes time is called `pod-eviction-timeout`. You can change this time with `--pod-eviction-timeout` flag.

If the problem solved after 5 minutes, nodes will come empty.

```bash
# kube-controller-manager is the controller of kubernetes. You can change the pod-eviction-timeout with this command.
kube-controller-manager --pod-eviction-timeout=10m
```


# Version Upgrade
When we upgrade the version of kubernetes, we should upgrade the control nodes first. After that, we can upgrade the worker nodes.
Because of that, we will do this upgrade node by node.

## Drain Node
Before upgrading the node, we should drain the node. Drain means that we will move the pods to another node and not create new pods on this node.

> If the pod not have replicaset, drain command will give an error. You should use `--force` flag.

```bash
# --ignore-daemonsets flag is used to ignore the daemonsets.
# if we do not use this flag, we will get an error. Because the daemonsets should be on every node.
kubectl drain <node-name> --ignore-daemonsets
```

## After The Upgrade
After the upgrade, we should uncordon the node. Uncordon means that we will allow the pods to create on this node.

```bash
kubectl uncordon <node-name>
```

## Cordoned Nodes
We can close the nodes for scheduling with the following command. Rather than draining, this command does not move the pods to another node.

```bash
kubectl cordon <node-name>
```