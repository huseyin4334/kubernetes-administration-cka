# Manual Schedule

```shell
# replace the pod with the new configuration
kubectl replace --force -f <path-to-file>
```

# Labels And Selectors

```shell
kubectl get pods --selector env=prod

# count the number of rows (header is not included)
kubectl get pods --selector env=prod --no-headers | wc -l

# count the number of rows (header is included)
kubectl get pods --selector env=prod | wc -l

# show the labels of the pods
kubectl get pods --selector env=prod --show-labels

kubectl get pods --selector env=prod,app=nginx
```


# Static Pods

```shell
# read the kubelet configuration for finding the static pod path
# staticPodPath: /etc/kubernetes/manifests
cat /var/lib/kubelet/config.yaml

# we will see the static pod path in the kubelet service file
ls /etc/kubernetes/manifests

# create a static pod with the busybox image and sleep 1000 command in the /etc/kubernetes/manifests directory.
# restart=Never means the pod will not restart when it is failed.
kubectl run static-busybox --image=busybox --restart=Never --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml


################
# Find the static pod in another node and delete it.
# Pod name is static-greenbox -> static-greenbox-node01

# Find the node internal IP
kubectl get nodes -o wide

# ssh to the node
ssh 192.657.1.1

# Find the static pod path
# staticPodPath: /etc/find-the-path
cat /var/lib/kubelet/config.yaml

# Find the file
# greenbox.yaml
ls /etc/find-the-path

# Delete the file
rm /etc/find-the-path/greenbox.yaml

exit

# Check the pod. Kubelet will terminate the pod.
kubectl get pods --watch
```

# Multiple Schedulers

```shell
# create a configmap for the scheduler configuration from the file. File contains the configuration of the scheduler (KubeSchedulerConfiguration).
kubectl create configmap my-scheduler-config --from-file=my-scheduler-config.yaml

# deployment have schedulerName: my-scheduler
kubectl create -f my-scheduler-deployment.yaml
```