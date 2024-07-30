# Kubelet
- [Kubelet](https://kubernetes.io/docs/concepts/overview/components/#kubelet)
- Kubelet is an agent that runs on each node in the cluster. It makes sure that containers are running in a Pod.
- Kubelet control pod and node status continuously. It reports the status of the pod to the api-server.
- If the pod is unhealthy, it will restart the pod.
- Kubelet give container source requirements to the container runtime.
- Container runtime is responsible for running the containers.


## Installation
``` bash

wget https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubelet

./kubelet --kubeconfig=/etc/kubernetes/kubelet.conf --logtostderr=true --v=2

# We can see default parameters in kubelet.service file or kubelet.yaml file.

# /etc/kubernetes/manifests/kubelet.yaml
# /etc/systemd/system/kubelet.service

# Check the kubelet is running
ps aux | grep kubelet


# Kubeadm tool can not install kubelet. We need to install kubelet manually.
```