# Backup And Restore Lab
```bash
# We will look at config to see the current context
kubectl config view

# We will have 2 cluster definitions in the config file
# Because of that, we will change the context with command.
kubectl config use-context cluster1


# we can ssh to access to other nodes
ssh node01


kubectl describe pod etcd-master -n kube-system | grep --data-dir
# show the data directory of etcd


# Find the External etcd directory
ssh <ip-address>

# Find data directory of etcd
# ps is a command to show the current processes
# -ef is a flag to show all processes (e flag) and full format (f flag)
ps -ef | grep etcd
# We will find --data-dir flag in the output
# Find --listen-client-urls flag for call etcdctl command
# However, we will look at certificates to call etcdctl command


# Find members of the etcd cluster
export ETCDCTL_API=3
etcdctl member list
--cacert=/etc/kubernetes/pki/etcd/ca.crt
--cert=/etc/kubernetes/pki/etcd/server.crt
--key=/etc/kubernetes/pki/etcd/server.key
--endpoints=https://127.0.0.1:2379
```

- Take backup stacked etcd and get this file to external node

```bash
ssh master

export ETCDCTL_API=3

# Take a snapshot
kubectl describe pod etcd-master -n kube-system
# Find certificate files
# Find the --advertise-client-urls flag. This ip address uses

etcdctl --endpoints=https://<advertise-client-urls-ip>:2379
--cacert=/etc/kubernetes/pki/etcd/ca.crt
--cert=/etc/kubernetes/pki/etcd/server.crt
--key=/etc/kubernetes/pki/etcd/server.key
snapshot save /opt/snapshot-pre-boot.db

exit

# scp command is used to copy files between different hosts. scp stands for secure copy protocol.
scp master:/opt/snapshot-pre-boot.db /opt/snapshot-pre-boot.db
```


-- Apply backup to external etcd

```bash
# send the snapshot file to the external etcd node
scp /opt/snapshot-pre-boot.db <ip-address>:/opt/snapshot-pre-boot.db


ssh <ip-address>

export ETCDCTL_API=3

# Restore the snapshot
etcdctl snapshot restore /opt/snapshot-pre-boot.db --data-dir=/var/lib/etcd-data-new
--cacert=/etc/kubernetes/pki/etcd/ca.crt
--cert=/etc/kubernetes/pki/etcd/server.crt
--key=/etc/kubernetes/pki/etcd/server.key

# Change the owner of the new data directory
# R is for recursive
chown -R etcd:etcd /var/lib/etcd-data-new

# If node have a pod for etcd. We should change the data directory in the etcd pod yaml file
# If system started with service file, we should change the service file
# We can find how started to etcd with systemctl command
# If etcd started with systemctl, we can change the service file
# If we can not see the etcd service with systemctl, we should change the pod yaml file
systemctl status etcd

# 1.option
# Change the data directory in the etcd pod yaml file
vim /etc/kubernetes/manifests/etcd.yaml

# 2.option
# Change service file
vim /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart etcd
exit


ssh master
systemctl restart kubelet
```

```yaml
apiVersion: v1
kind: Pod
...
spec:
  containers:
  - command:
    - etcd
    - --data-dir=/var/lib/etcd-data-new
    ...
  volumeMounts:
  - mountPath: /var/lib/etcd-data-new
    name: etcd-data
```

```service
[Unit]
Description=etcd key-value store
...
ExecStart=/usr/local/bin/etcd 
    --data-dir=/var/lib/etcd-data-new
    ...
```





