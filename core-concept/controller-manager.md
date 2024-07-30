# Controller Manager
- Controller Manager responsible for running controllers.
- Controllers are responsible for controlling the state of the cluster and nodes.
- Controller Manager is a daemon that runs in the master node.
- It watches the state of the cluster and makes changes to the cluster to match the desired state.
- It is responsible for the following controllers:
  - Node Controller
  - Replication Controller
  - Endpoints Controller
  - Service Account & Token Controllers
  - Service Account & Token Controllers
  - Namespace Controller
  - Service Controller
  - Job Controller
  - DaemonSet Controller
  - Deployment Controller
  - StatefulSet Controller
  - PersistentVolume Controller
  - PersistentVolumeClaim Controller
  - StorageClass Controller
  - Volume Controller
  - CSINode Controller
  - CSIDriver Controller
  - Lease Controller
  - TokenCleaner Controller
- These controllers using the API server to get the state of which objects they are responsible for.

For example;
- Node Controller watches the state of the nodes.
- It has 5 seconds to check the state of the nodes. (Node monitor period)
- Node controller send monitor request to the API server.
- If Node Controller sees that any problem in the node, it will take action to fix the problem.
- For that, it will send a request to the API server to update the state of the node.
- Node server if the node is not healthy, it will mark the node as not ready.
- But it gives 40 seconds for the node to become ready again. (Node monitor grace period)
- After marked as not ready, the node controller wait for 5 minutes for the node come back to ready state. (Pod eviction timeout)
- If the node is not ready after 5 minutes, the node controller will evict the pods from the node.
- Node controller will send a request to the API server to update the state of the pods.
- API server will update the state of the pods in the etcd.
- Replication Controller responsible for maintaining the desired number of pods.
- If the number of pods is less than the desired number, Replication Controller will create new pods.
- It will send a request to the API server to create new pods.


## Installation

``` shell

# We can install the Controller Manager with the following command.
wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager

# We can start the Controller Manager with the following command.
./kube-controller-manager --kubeconfig=... --address=... --cluster-cidr=... --service-cluster-ip-range=...

# In the other way, we can change options with the file.
cat /etc/kubernetes/manifests/kube-controller-manager.yaml
cat /etc/systemd/system/kube-controller-manager.service

# kubeadm tool can be used to start the Controller Manager.
kubeadm init --control-plane-endpoint=... --pod-network-cidr=...

# When we create the cluster with kubeadm, it will create the Controller Manager configuration file.
kubectl get pods -n kube-system

#kube-controller-manager-master is running as a pod in the kube-system namespace.

ps -aux | grep kube-controller-manager

```