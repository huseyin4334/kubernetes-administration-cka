# ETCD
- ETCD is a key-value store. 
- It is a distributed, reliable key-value store that is simple, secure, and fast.
- It is written in Go and uses the Raft consensus algorithm to manage a highly-available replicated log.
- We can install and use it like database in our computer.
- We can interact with etcd using etcdctl command.

## Intallation
- Download Binaries
``` shell
curl -L https://github.con/etcd-io/etcd/releases/download/v3.5.0/etcd-v3.5.0-linux-amd64.tar.gz -o etcd-v3.5.0-linux-amd64.tar.gz
```
- Extract the tarball
``` shell
tar xzvf etcd-v3.5.0-linux-amd64.tar.gz
```
- Run etcd service (It's an executable file)
``` shell
./etcd-v3.5.0-linux-amd64/etcd
```
- Some examples
``` shell
./etcdctl set mykey myvalue
./etcdctl get mykey
```

- Version Check
``` shell
./etcdctl --version

etcdctl version: 3.5.0
API version: 3.5
```

- Help
``` shell
./etcdctl
```

- Change Version
``` shell
export ETCDCTL_API=3

./etcdctl --version

etcdctl version: 3.5.0
API version: 3.5
```

## Cluster Manual Setup
``` shell
wget -q --https-only "https://github.com/coreos/etcd/releases/download/v3.3.5/etcd-v3.3.5-linux-amd64.tar.gz"

# etcd.service -> /etc/systemd/system/etcd.service
# this file is used to start etcd service.

--advertise-client-urls http://${INTERNAL_IP}:2379 \\

# advertise-client-urls: The URL to listen on for client traffic.
# Client is the one who is going to interact with the etcd cluster. (like kubectl, api-server)
```

- Start etcd service
``` shell
sudo systemctl daemon-reload
sudo systemctl start etcd
```

## Setup with kubadm
- kubeadm is a tool that helps you bootstrap a minimum viable Kubernetes cluster that conforms to best practices.
- kubeadm init will create a new Kubernetes cluster.

``` shell
kubectl get pods -n kube-system

# etcd is running as a pod in the kube-system namespace. (etcd-master)

# We can run exec command to get information from etcd
kubectl exec etcd-master -n kube-system etcdctl get / --prefix --keys-only

# --prefix: Get all keys with the given prefix.
# --keys-only: Get only the keys, do not get the values.
# /: Root key
# This command will return all the keys in the etcd cluster.
```

## ETCD In HA Environment
- ETCD is a critical component of the Kubernetes cluster.
- It is recommended to run etcd in a highly available configuration.
- We can run etcd in a cluster of 3, 5, or 7 nodes.
- HA is highly available.

``` shell
etcd.service -> /etc/systemd/system/etcd.service

# --initial-cluster: List of initial members of the cluster. These members are etcd nodes.
# initial-cluster controller-0=http://{INTERNAL_IP_OF_CONTROLLER_0}:2380,controller-1=http://{INTERNAL_IP_OF_CONTROLLER_1}:2380
```

## Example
``` shell

kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key"

# --cacert: The certificate authority certificate file for the etcd cluster. (This is the certificate that is used to sign the etcd server certificate)
# --cert: The certificate file for the etcd server. (This is the certificate that is used by the etcd server)
# --key: The private key file for the etcd server. (This is the private key that is used by the etcd server)
# --limit: The maximum number of keys to return. (In this case, we are returning only 10 keys.
# ETCDCTL_API=3: This is used to specify the etcd API version. (In this case, we are using version 3)

```

> Read: [Pdf](../sources/pdfs/core-concept/Kubernetes+-CKA-+0100+-+Core+Concepts.pdf) 