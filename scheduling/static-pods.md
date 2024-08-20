# Static Pods
- Static Pods are managed directly by the kubelet daemon on a specific node, without the API server observing them.

---

Kubelet just know about the pod creation and deletion.
Generally, we used api server to give pod definition files to kubelet. But in case of static pods, we can directly give pod definition files to kubelet.
When we update, create or delete the objects from files or delete files directly, kubelet will take care of it.

> Don't forget, kubelet work pod level. Because of that, it doesn't know about the deployment, replica set, stateful set, etc.
> Because of that, just we can create static pods with kubelet.


---

Directory is `/etc/kubernetes/manifests` by default. But it can be changed with `--pod-manifest-path` flag.
In another way, we can delete the flag from the kubelet service file. we can add the `--config` flag to the kubelet service file.
We will create a scheduler-config.yaml file and give the path of this file to the `--config` flag.

---

First Way:

```bash
# kubelet service file is in /etc/systemd/system/kubelet.service
cat ./kubelet.service

# We will see the --pod-manifest-path=/etc/kubernetes/manifests flag in the file.

# For change; (Absolutely we should this in the node)
# 1. Edit the file
# 2. Reload the service
# 3. Restart the service
systemctl daemon-reload
systemctl restart kubelet
```
---

Second Way:

Create yaml file for the kubelet config.

```yaml
staticPodPath: /etc/my-way
```

```bash
vim kubelet.service

# Add the --config flag
--config=/etc/kubernetes/kubelet-config.yaml

# Reload and restart the service
systemctl daemon-reload
systemctl restart kubelet
```

## Kube-api server and Kubelet
When we create a pod with the api server, it will create a pod object in the etcd. And It will send information with the HTTP request to the kubelet.

But when we create a static pod, kubelet send a mirror object to the api server. And the api server will create a pod object in the etcd.
Because of that, we can not replace and delete the static pods with the api server.
We have to modify the files in the static pod directory.

When created a static pod, naming strategy is `<pod-name>-<node-name>`. We can see the pod name with `kubectl get pods` command.


## Use Cases
For example in the case of the control plane components, we can use static pods. Because we don't want to lose the control plane components. 
we can delete the static pods in the control plane components, and we can see the kubelet will create the pods again.


Because of that, when our system crashed, we can see the control plane components will be up again.


## Static Pods Vs DaemonSets
- DaemonSets are used to run a copy of a pod on each node. (Kube-api server level)
- Static Pods are used to run a pod on a specific node. (Kubelet level)
- Ignored by the kube-scheduler both of them.


## Owner References
- We can control the owner references with the describe command. We can see the pod how created with the describe command.

```bash
kubectl describe pod kube-apiserver-minikube -n kube-system

# ownerReferences:
# - apiVersion: v1
#   controller: true
#   kind: Node
#   name: minikube # Node name


kubectl describe pod coredns-74ff55c5b-7z5z5 -n kube-system

# ownerReferences:
# - apiVersion: apps/v1
#   blockOwnerDeletion: true # If we delete the owner, the pod will be deleted.
#   controller: true
#   kind: ReplicaSet
#   name: coredns-74ff55c5b # ReplicaSet name
```
