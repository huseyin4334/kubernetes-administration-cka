# Kubernetes Release Versioning
- v1.11.3
  - v1: Major version
    - If the major version is changed, it means that there are big changes in the software.
  - 11: Minor version
    - If the minor version is changed, it means that there are new features or functionalities in the software.
  - 3: Patch version
    - If the patch version is changed, it means that there are bug fixes in the software.

Generally, in some of the months, a new minor version is released. After that, the patch versions are released for bug fixes.
First big version release was v1.0.0 in July 2015.
Last stable version is v1.13.0 in December 2018.

In other hand;
- v1.11.3-alpha
  - Alpha version is the first version of the software. It is not stable. It's not tested well.
- v1.11.3-beta
  - Beta version is the second version of the software. It is more stable than alpha version. It's tested more than alpha version.
  - After this version, the software will release as stable version.

---

We install the kubernetes package from GitHub. For example, we installed v1.13.4.

We will see the components of the kubernetes packages:
- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kubelet
- kubectl
- kube-proxy

These components have the same version.

These components are not in the kubernetes package. These components are:
- ETCD Cluster (v3.3.10)
- CoreDNS (v1.2.6)


# How Should We Upgrade The Kubernetes Version?
The relationship between the versions can only be this way.
Kube-apiserver have to be same or higher version than the other components except kubectl.
- kube-apiserver: 
  - X version 
  - v1.10
- controller-manager:
  - X-1 version 
  - v1.9 or v1.10
- scheduler:
  - X-1 version
  - v1.9 or v1.10
- kubelet:
  - X-2 version
  - v1.8 >
- kube-proxy:
  - X-2 version
  - v1.8 >
- kubectl:
  - X+1 > X-1
  - Version can be v.1.11 => version =< v1.9

---

Kubernetes supports last 3 versions. If you have v1.10 and the last stable version is v1.13, v1.10 is not supported anymore.
When you upgrade the version, you should upgrade version by version. You shouldn't upgrade from v1.10 to v1.13 directly.

---

When we upgrade we have 3 way:
- Cloud Provider
  - If we have a cluster in cloud, we can upgrade the version with just a button.
- kubeadm
  - We can upgrade the version with kubeadm tool.
  - kubeadm is a tool for creating, upgrading and maintaining kubernetes clusters.
  - `kubeadm upgrade apply` command is used for upgrading the version.
  - `kubeadm upgrade plan` command is used for seeing the upgrade plan.
- The hard way
  - We can upgrade the version manually.


---

When we upgrade the master node, our worker nodes will continue to work. Just all management will be stopped.
We can not use kubectl command. We can not delete, update or create any resource.

---

We have 3 strategies for upgrading the version in worker nodes:
- All at once
  - We can upgrade all worker nodes at the same time.
  - We can not use this strategy in production. Because all worker nodes will be down until the upgrade is completed.
- One by one
  - We can upgrade the worker nodes one by one.
  - The pods will be moved to another node.
- Add a new node
  - We can add a new node with the new version.
  - We will move the pods to the new node.
  - In that time, we can upgrade the old node.


# Kubeadm Upgrade
First, we will find the plan for upgrading the version.

```bash
kubeadm upgrade plan
# ----
# Cluster Version: v1.11.8
# kubeadm version: v1.11.3
# Latest stable version: v1.13.4
# Latest version in the v1.11 series: v1.11.8
# ----
# We will see 2 plans.
# 1. We will see the manual upgrade plan for some components. (kubelet)
# 2. We will see the automatic upgrade plan for some components. (kube-apiserver, kube-controller-manager, kube-scheduler)
```

---

We should upgrade kubeadm first. After that, we can upgrade the other components.
In every step, we will upgrade the version of the kubeadm with the same version of the kubernetes new version.

```bash
apt-get upgrade -y kubeadm=1.12.0-00
```

---

Let's upgrade the node.
 
```bash
kubeadm upgrade apply v1.12.0
```

But we will see the old version in the node. Because we didn't upgrade the kubelet.

```bash
apt-get upgrade -y kubelet=1.12.0-00

systemctl restart kubelet
```

---

We can do this upgrade like this too.

```bash
apt-get upgrade -y kubeadm=1.12.0-00
apt-get upgrade -y kubelet=1.12.0-00

kubeadm upgrade node config --kubelet-version v1.12.0
systemctl restart kubelet
```
