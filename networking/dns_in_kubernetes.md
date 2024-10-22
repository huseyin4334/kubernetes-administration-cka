# DNS in Kubernetes
Kubernetes has a built-in DNS service that automatically assigns DNS names to containers and services. 
This is useful for service discovery and for connecting services together. The DNS service is implemented as a set of pods that run in the cluster. 
These pods are managed by the kube-dns service, which is responsible for starting and stopping the DNS pods as needed.

For example,
We have 2 namespaces `default` and `apps`.
We have a pod inside the `default` namespace with the name `web-1`.
We have a pod inside the `apps` namespace with the name `web` and a service with the name `web-service`.

Kube DNS will assign the following DNS names to these resources:

| Hostname    | Namespace | Type    | Root          | Ip Address     |
|-------------|-----------|---------|---------------|----------------|
| 10-244-1-1  | default   | pod     | cluster.local | 10.244.1.1     |
| 10-244-2-5  | apps      | pod     | cluster.local | 10.244.2.5     |
| web-service | apps      | service | cluster.local | 10.1017.37.188 |

Root is the default domain name for the cluster. It is defined in the kube-dns ConfigMap.

```bash
curl web-service.apps.svc.cluster.local

curl 10-244-2-5.apps.pod.cluster.local
```

The kube-dns service is responsible for resolving these DNS names to IP addresses.


But after the release of Kubernetes 1.12, the kube-dns service was replaced by the CoreDNS service.

CoreDNS is a flexible, extensible DNS server that is written in Go. 
It is designed to be fast and efficient, and it supports a wide range of plugins that can be used to extend its functionality.

It's working is similar to kube-dns.

When we create a pod kubernetes set coreDNS pod ip address to `/etc/resolv.conf` file of the pod like nameserver.

```bash
curl web-service.apps.svc.cluster.local
curl web-service
curl web-service.apps
# ....
# coredns can resolve the service name with or without the namespace

# But for the pod, we need to specify all the parts of the DNS name
curl 10-244-2-5.apps.pod.cluster.local
```

We can see the configuration of the CoreDNS service by running the following command:

```bash
kubectl get configmap coredns -n kube-system -o yaml

# or
kubectl exec -n kube-system -it coredns-xxxxx -- cat /etc/coredns/Corefile
```

We can see the clusterDNS and clusterDomain in the kubelet configuration file.
It will set these values in the `/etc/resolv.conf` file of the pod.

```bash
cat /var/lib/kubelet/config.yaml

# clusterDNS:
# - 10.96.0.10
# clusterDomain: cluster.local
```

# Lab

Where is the configuration file of the CoreDNS service located?

- /etc/coredns/Corefile

```bash
kubectl get configmap coredns -n kube-system -o yaml

# This file contains the configuration of the CoreDNS service.
# This file transforms the Corefile from the ConfigMap into a CoreDNS configuration file.
```

In default namespace;
- Pods
  - hr
  - test
- Services
  - web-service (It's looking hr pod)

In payroll namespace;
- Pods
  - web
  - mysql
- Services
  - web-service (it's looking web pod)
  - mysql

```bash
kubectl exec test -- curl web-service
# Welcome to the HR department

kubectl exec test -- curl web-service.payroll
# Welcome to the web app
```

Let's get nslookup result to the file.

```bash
kubectl exec hr -- nslookup mysql.payroll > /tmp/mysql.txt

# Server: .... (it's the CoreDNS service IP address.)

# Name: mysql.payroll.svc.cluster.local
# Address: 10.1017.37.188
```