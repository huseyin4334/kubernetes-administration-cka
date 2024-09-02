# ETCD
> https://etcd.io/docs/v3.5/tutorials/

The ETCD key-value database is deployed as a static pod on the master. The version used is v3.

```bash
# we run this command line on the master node
# This export is important for access to wide range of etcdctl commands
export ETCDCTL_API=3

etcdctl version
```

---

Take a snapshot of the ETCD database:

```bash
# -h is the output file
etcdctl snapshot save -h /tmp/snapshot.db
```

If TLS is enabled, you need to specify the certificate and key files:

```bash
etcdctl --endpoints=https://[127.0.0.1]:2379 \  # This is the default as ETCD is running on master node and exposed on localhost 2379.
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db 
```

---

Restore the ETCD database from a snapshot:

```bash
etcdctl snapshot restore -h /tmp/snapshot.db
```

## Some Environment Variables

```bash
# We can reach the ETCD database with first ip address in control plane node
# We can reach the ETCD database with second ip address in internal network
--listen-client-urls=https://127.0.0.1:2379,https://10.44.215.8:2379
```


## Snapshot and Restore

```bash
export ETCDCTL_API=3

# Take a snapshot
kubectl get pods -n kube-system | grep etcd
# pod name is etcd-master

kubectl describe pod etcd-master -n kube-system | grep --listen-client-urls
# url is -> https://127.0.0.1:2379

etcdctl --endpoints=https://127.0.0.1:2379
--cacert=/etc/kubernetes/pki/etcd/ca.crt # these certificate files are volume mounted to the etcd pod
--cert=/etc/kubernetes/pki/etcd/server.crt
--key=/etc/kubernetes/pki/etcd/server.key
snapshot save /opt/snapshot-pre-boot.db
# snapshot is saved

# We have 2 volume mounts in etcd pod
# /etc/kubernetes/pki/etcd -> This is the certificate files
# /var/lib/etcd -> This is the data directory
# --data-dir=/var/lib/etcd is default. But if we change it, we need to change volume mount path in pod yaml file too.



# Restore the snapshot
# 1.option
# --data-dir -> we have to specify the data directory. We can override the default data directory
etcdctl snapshot restore /opt/snapshot-pre-boot.db --data-dir=/var/lib/etcd

# 2.option
etcdctl snapshot restore /opt/snapshot-pre-boot.db --data-dir=/var/lib/etcd-backup
--cacert=/etc/kubernetes/pki/etcd/ca.crt
--cert=/etc/kubernetes/pki/etcd/server.crt
--key=/etc/kubernetes/pki/etcd/server.key

# After restore, we should change the yaml file of etcd pod to use the new data directory.
vim /etc/kubernetes/manifests/etcd.yaml
```

```yaml
apiVersion: v1
kind: Pod
...
spec:
  containers:
  - command:
    - etcd
    - --data-dir=/var/lib/etcd-backup
    ...
  volumeMounts:
  - mountPath: /var/lib/etcd-backup
    name: etcd-data
...
```

# Stacked And External ETCD
We can understand the etcd is stacked or external by looking at the api server configuration file.

## Stacked ETCD
```bash
kubectl describe pods etcd-master -n kube-system | grep --listen-client-urls
# --listen-client-urls=https://https://127.0.0.1:2379

kubectl describe pods kube-apiserver-master -n kube-system | grep --etcd-servers
# --etcd-servers=https://127.0.0.1:2379 (This is localhost ip address)
```


## External ETCD
```bash
kubectl get pods -n kube-system | grep etcd
# It will be empty

ssh master
ls /etc/kubernetes/manifests
# etcd.yaml file is not exist

kubectl describe pods kube-apiserver-master -n kube-system | grep --etcd-servers
# --listen-client-urls=https://193.56.679.3:2379
# This is the external ip address
```





