# Volume
Volume is a way to store the data. When we create a volume docker save the data in the `/var/lib/docker/volumes` directory.
In kubernetes, we can create volumes and assign it directly. Also, we can use the Persistent Volume (PV) and Persistent Volume Claim (PVC) for the volumes.

---

Directly way;

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: nginx
      volumeMounts:
      - mountPath: /container/path # it should be the container path
        name: myvolume # it should be same with the volume name
    volumes:
    - name: myvolume
      hostPath: # https://kubernetes.io/docs/concepts/storage/volumes/#hostpath-volume-types
        path: /data # it should be the host path. Where will be located in the host machine.
        type: Directory
# hostPath just a type of volume. We have some other types like emptyDir, configMap, secret, etc.
# But recommended to use the Persistent Volume (PV) and Persistent Volume Claim (PVC) for the volumes.
# Also, recommended to use cloud storage like AWS EBS, Azure Disk, etc.
```

If we have multiple nodes, this is not useful. Because the data will be stored in the all nodes differently. And we can't access the data from another node.
Because of that, we should use cloud storage like AWS EBS, Azure Disk, etc.


# Persistent Volume (PV) and Persistent Volume Claim (PVC)
In the real life, we won't have just 1 volume or project. Because of that, we can't continue that volume mount in the pod definition file.
This is useless and not efficient.

We can use the Persistent Volume (PV) and Persistent Volume Claim (PVC) for the volumes.

- Persistent Volume (PV) is a piece of storage in the cluster that has been provisioned by an administrator.
- Persistent Volume Claim (PVC) is a request for storage by a user.

We can create the PV and PVC separately. And we can use the PVC in the pod definition file.

```yaml
aiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
spec:
    capacity:
      storage: 1Gi
    accessModes:
      - ReadWriteOnce # https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
    hostPath:
      path: /tmp/data
```

Access modes can be different for chosen volume type. For example, in the hostPath volume type, we can only use ReadWriteOnce because it is local storage.
We can check it in the documentation. [Access Modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)

```bash
kubectl apply -f pv.yaml

kubectl get pv mypv
```
---

When we create a PVC, kubernetes will find the PV that matches the PVC.
If PV bigger than PVC and cluster don't have any other available PV, kubernetes will use the PV for the PVC.
If PV smaller than PVC or PV is not available, PVC will be pending until the PV is available.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
```

```bash
kubectl apply -f pvc.yaml

kubectl get pvc mypvc

kubectl delete pvc mypvc
```

When we delete the PVC, we could set what will PV do. 

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
spec:
  persistentVolumeReclaimPolicy: Retain # Retain, Recycle, Delete
  ...

# Retain: Retain will keep this volume until delete it manually. And this pv will be stay in state
# Delete: will delete the volume when PVC is deleted.
# Recycle: will delete the data in the volume when PVC is deleted and will be available for the new PVC.
```

---

Set the PVC in the pod definition file.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: nginx
      volumeMounts:
      - mountPath: /container/path # it should be the container path
        name: myvolume # it should be same with the volume name
    volumes:
    - name: myvolume
      persistentVolumeClaim:
        claimName: mypvc
```

> https://kubernetes.io/docs/concepts/storage/persistent-volumes/#claims-as-volumes


# Lab
- Add a volume for logs

```yaml
apiVersion: v1
kind: Pod
....
spec:
    containers:
    - name: mycontainer
      image: nginx
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/nginx
    volumes:
      - name: log-volume
        hostPath:
          path: /tmp/logs
          type: Directory
```

- Create a persistent volume
- When we create it, it will be in `AVAILABLE` state.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log
spec:
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /tmp/logs
    type: Directory
  capacity:
    storage: 100Mi
  persistentVolumeReclaimPolicy: Retain
``` 

- Create a persistent volume claim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-log-claim
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 50Mi
```

- When we create pvc, it will be in `pending` state. Because access modes not matched.
- Change pvc with ReadWriteMany

---

- After changing, pcv will be in `BOUNDED` state.

---

- Change the pod volume mapping

```yaml
apiVersion: v1
kind: Pod
....
spec:
    containers:
    - name: mycontainer
      image: nginx
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/nginx
    volumes:
      - name: log-volume
        persistentVolumeClaim:
          claimName: pv-log-claim
```

---

- Delete pvc
  - It will be stuck in the terminating status. Because it's using by a pod
- Let's Delete the pod
  - PVC will be deleted automatically
  - PV will be in `RELEASED` state.


# Storage Class
Storage Class is a way to define the type of the volume. We can define the storage class and use it in the PVC.
For example, when we create a pv and pvc in the cloud storage, we have to create the storage before creating the pv and pvc.

We can create manually with cloud storage command line like this; **(Static Provisioning)**
    
```bash
gcloud beta compute disks create --size=10GB --region=us-west1 my-data-disk
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  gcePersistentDisk:
    pdName: my-data-disk
    fsType: ext4
```

---

But, the best usage is to use the storage class. 
Because it will create the storage automatically when we create the pvc. So, it will be created when we need it. **(Dynamic Provisioning)**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: my-storage-class
provisioner: kubernetes.io/gce-pd
volumeBindingMode: WaitForFirstConsumer # WaitForFirstConsumer, Immediate
parameters:
  type: pd-standard # pd-ssd, pd-standard
  replication-type: none # none, regional-pd

# pd-ssd: SSD
# pd-standard: Standard HDD

# none: Single zone
# regional-pd: Multi zone

# pd-standard and none -> Silver SC
# pd-ssd and none -> Gold SC
# pd-ssd and regional-pd -> Platinum SC

# WaitForFirstConsumer: It will create the storage when any pod uses a pvc with this storage class.
# And the pvc will be in PENDING state until the pod is created.
```

- We won't create a pv. Storage class will create it automatically. And our pvc bound to this pv.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
    accessModes:
      - ReadWriteOnce
    storageClassName: my-storage-class
    resources:
      requests:
        storage: 10Gi
```

---

Local storage class is a way to use the local storage in the nodes.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```