# Kubernetes Infrastructure
We have some solution types;
- Turnkey solutions
  - Provision vm's
  - Configure Vm's
  - Deploy cluster
  - Maintain Vm's
  - ...
- Hosted Solutions
  - GKE
  - EKS
  - AKS
  - ...

Openshift, cloud foundry, vmware cloud pks, vagrant, ... are turnkey solutions.
Azure AKS, Google GKE, Amazon EKS, Openshift Online, ... are hosted solutions.

# High Availability
For high availability;
- Multiple masters
- Multiple etcd
- Multiple workers
- Load balancer

When we create multiple master nodes;
We need to understand how is working cluster.

---

Api Server

- Api Server is the entry point for all the requests that are coming to the cluster.
- Then just we should have a load balancer in front of the api server for separating the traffic between the master nodes.
  - (https://master1:6443, https://master2:6443, https://master3:6443)


---

Kube Controller Manager

Kube controller manager works on the leader election mechanism.
- One of the master nodes will be the leader.

We can set some parameters for leader election;
- --leader-elect
  - It uses the leader election mechanism to ensure there is only one active controller manager.
  - true
  - false
- --leader-elect-lease-duration
  - It is the duration that non-leader candidates will wait to force acquire leadership.
  - 15s
  - 1m
  - 1h
- --leader-elect-renew-deadline
  - It is the duration that the acting leader will retry refreshing leadership before giving up.
  - 10s
- --leader-elect-retry-period
  - It is the duration the LeaderElector clients should wait between tries of actions.

---

ETCD

ETCD is a distributed key-value store that is used to store the cluster state.
It works separately from the master nodes for the high availability.

Etcd servers connect with each other and they are sharing the data between them from 2380 port.

Kube-apiserver connects to the etcd servers from 2379 port.

(Kube-apiserver) <----> (etcd1:2379, etcd2:2379, etcd3:2379)
--etcd-servers=https://etcd1:2379,https://etcd2:2379,https://etcd3:2379

ETCD works leader election mechanism as well.
For the leader election, etcd uses the raft consensus algorithm.

Every etcd server has a time for the leader election.
If the leader does not send a heartbeat to the followers in the time, the followers will start to send a request to the leader for the leadership.
When Get the majority of the votes, the follower will be the leader.

In the etcd server, just leader can write the data.
Api server can read the data from all the etcd servers.

For the write operation consistency, etcd uses the quorum.

Quorum uses N/2 + 1.

For example, if we have 3 etcd servers, the quorum is 2.
If we have 5 etcd servers, the quorum is 3.

Because of that, we should have an odd number of etcd servers.
Not 2, 4, 6, 8, ... -> should be 3, 5, 7, 9, ...

Peers can be set in initial-cluster parameter in the etcd configuration file.

--initial-cluster=etcd1=https://etcd1:2380,etcd2=https://etcd2:2380,etcd3=https://etcd3:2380

We can reach the etcd with the etcdctl command.

```bash
export ETCDCTL_API=3

etcdctl --endpoints=https://etcd1:2379,https://etcd2:2379,https://etcd3:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  endpoint health
```
