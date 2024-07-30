# Kube Proxy
- Kube Proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept.
- Kube Proxy maintains network rules on nodes. Every node have a kube-proxy component.
- These network rules allow network communication to your Pods from network sessions inside or outside of your cluster.
- Kube proxy have ip tables rules to forward the traffic to the correct pod. For example;
  - We created a pod with name `nginx` and it's ip is `10.32.0.15`. This is kube-proxy ip addresses for the pod.
  - This ip is not reachable from outside of the node. Because this is just living in the node.
  - Kube-proxy table save a row like this: `10.96.0.12` | `10.32.0.15`
    - `10.96.0.12` is the service ip address. This is reachable from outside of the cluster.
    - When the traffic comes from `10.96.0.12` to the node, kube-proxy forward the traffic to the pod.
    - Basically, kube-proxy is working like this.

## Installation

``` bash

wget https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-proxy

./kube-proxy --kubeconfig=/etc/kubernetes/kube-proxy.conf --logtostderr=true --v=2

# We can see default parameters in kube-proxy.service file or kube-proxy.yaml file.
# /etc/kubernetes/manifests/kube-proxy.yaml
# /etc/systemd/system/kube-proxy.service

# We can see the kube-proxy pods how many running in the cluster for each node.
kubectl get pods -n kube-system | grep kube-proxy

# Deamonsets is a kubernetes object. It's a controller that ensures that a pod runs on all (or some) nodes in desired count.
kubectl get deamonsets -n kube-system | grep kube-proxy


```