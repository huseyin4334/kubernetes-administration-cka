# API SERVER
- API Server is the front-end of the Kubernetes control plane.
- It is designed to scale horizontally.

## Example
``` shell
kubectl get pods -n kube-system

# kubectl command is used to interact with the Kubernetes cluster.
# When we call this command, it will interact with the API server.
# Api server get the request
# Api server authenticate the request and validate the request.
# it will retrieve the data from the etcd.
# etcd give the information to the API server.
# API server will return the response.

# We don't have to use the kubectl command to interact with the API server.
# We can use the curl command to interact with the API server. Because it is a RESTful API.


curl -X POST /api/v1/namespaces/default/pods -d '{"apiVersion": "v1", "kind": "Pod", "metadata": {"name": "busybox"}, "spec": {"containers": [{"name": "busybox", "image": "busybox", "command": ["sleep", "3600"]}]}'

# -X POST: This is a POST request.
# /api/v1/namespaces/default/pods: This is the endpoint.
# -d: This is the data that we are sending to the API server.
# We are creating a pod with the name busybox.

# Api server will authenticate the request and validate the request.
# It will update the etcd with the new pod information.
# Etcd will return the response to the API server.
# API server will return the response to the curl command like "Pod created"

# Scheduler monitors the API server for new some commands.
# It will see the not created pod in any node.
# Scheduler will determine the best node for the pod and tell the API server.
# API server go to node and tell the kubelet to create the pod with the given information.
# Kubelet tell the container runtime to create the container.
# When the container is created, kubelet will tell the API server that the pod is created.
# API server will update the etcd with the new pod information.

# Every change request will go through this way.
# Just The API server speaks with etcd. If Other components want to get or update information, they will get it from the API server.
```

## API Server Configuration
``` shell
# We can install the API server with the following command.
wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-apiserver

# We can start the API server with the following command.
./kube-apiserver --advertise-address=... --etcd-servers=... --service-cluster-ip-range=...

# In other way, we can use the kubeadm tool to start the API server.
kubeadm init --control-plane-endpoint=... --pod-network-cidr=...

# kube-apiserver.service -> /etc/systemd/system/kube-apiserver.service
# this file is used to start the API server. This is configured with the above command.
# Every component in the Kubernetes cluster is running seperately. 
# Because of that, we should set some security and ip configurations for connecting each other.

# In the other way, we can look at options with kubeadm tool.
# these files same options with the above command.
cat /etc/kubernetes/manifests/kube-apiserver.yaml
cat /etc/systemd/system/kube-apiserver.service

# We can see the running API server options with the following command.
ps -aux | grep kube-apiserver
```


> Read: [Pdf](../sources/pdfs/core-concept/Kubernetes+-CKA-+0100+-+Core+Concepts.pdf) 