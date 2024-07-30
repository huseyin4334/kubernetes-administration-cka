# Scheduler
- [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/)
- Scheduler is a control plane component that watches for newly created Pods with no assigned node, and selects a node for them to run on.
- Scheduler just say where to run the pod, it doesn't run the pod. Kubelet runs the pod.
- Scheduler looks container source requirements.
  - It filters out nodes that don't meet the container's requirements.
  - It ranks the remaining nodes to choose the best one.

## Installation
``` bash
wget https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-scheduler

./kube-scheduler --kubeconfig=/etc/kubernetes/scheduler.conf --logtostderr=true --v=2

# We can see default parameters in kube-scheduler.service file or kube-scheduler.yaml file.
# /etc/kubernetes/manifests/kube-scheduler.yaml
# /etc/systemd/system/kube-scheduler.service


# Check the scheduler is running
ps aux | grep kube-scheduler

```