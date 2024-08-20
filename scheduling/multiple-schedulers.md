# Multiple Schedulers
- We can deploy or create multiple schedulers in a single cluster.
- We can set this scheduler names to the objects using the `schedulerName` field.
- We can also set the default scheduler name in the kube-scheduler configuration file. File is located at `/etc/kubernetes/manifests/kube-scheduler.yaml`.

---

Let's create a new scheduler named `my-scheduler` and set it as the default scheduler.

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler
```

---

We can deploy with 3 ways:
- We can install binary and run it with the `--config` flag.
- We can deploy it as a pod in the cluster with object configuration.
- We can deploy it as a pod in the cluster with a manifest file.


---

1 way:

```bash
wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler

chmod +x kube-scheduler

./kube-scheduler --config=my-scheduler-config.yaml
```

---

2 way:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-scheduler
  namespace: kube-system
spec:
    containers:
    - command:
        - kube-scheduler # binary file. It is needed to run the scheduler.
        - --kubeconfig=/etc/kubernetes/kube-scheduler.conf # kubeconfig file. It is needed to connect to the API server.
        - --config=/etc/kubernetes/my-scheduler-config.yaml # scheduler config file. It is needed to set the scheduler name.
      image: k8s.gcr.io/kube-scheduler:v1.21.0
      name: my-scheduler
```

---

3 way:

> https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/
> https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/#define-a-kubernetes-deployment-for-the-scheduler

From documentation:

But instead of creating a pod directly in the cluster, you can use a Deployment for this example. 
A Deployment manages a Replica Set which in turn manages the pods, thereby making the scheduler resilient to failures. 
Here is the deployment config. Save it as my-scheduler.yaml:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-scheduler-config
  namespace: kube-system
data:
  my-scheduler-config.yaml: | # scheduler config file. It is needed to set the scheduler name.
    apiVersion: kubescheduler.config.k8s.io/v1beta2
    kind: KubeSchedulerConfiguration
    profiles:
      - schedulerName: my-scheduler
    leaderElection: # enable leader election. If we set it to true, only one scheduler will be the leader. And the leader will be the only one that makes the scheduling decisions.
      leaderElect: false  # disable leader election. It is needed to avoid multiple schedulers.
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-scheduler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      component: my-scheduler
  template:
    metadata:
      labels:
        component: my-scheduler
    spec:
      containers:
        - command:
            - /usr/local/bin/kube-scheduler # binary file. It is needed to run the scheduler.
            - --config=/etc/kubernetes/my-scheduler-config.yaml
            - --kubeconfig=/etc/kubernetes/kube-scheduler.conf
          image: k8s.gcr.io/kube-scheduler:v1.21.0
          name: my-scheduler
# and so on...
# look at the documentation for the full configuration.
```

## Set Scheduler To The Object

We can set the scheduler name to the object with the `schedulerName` field.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    schedulerName: my-scheduler
    containers:
    - name: my-container
      image: nginx
```

## Find The Events

We can find the events with the `kubectl get events` command.

```bash
kubectl get events -o wide
```


## 1 scheduler with multiple profiles

We can create a scheduler with multiple profiles.
> scheduling-process.md steps explained
> https://kubernetes.io/docs/reference/scheduling/config/

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler
  plugins: # plugins are the steps of the scheduling process. score, bind, filter, preFilter, postFilter, reserve, permit, preBind, postBind, and preScore are the plugins.
    score:
      enabled:
      - name: NodeResourcesBalancedAllocation # NodeResourcesBalancedAllocation is a plugin that checks the resources of the nodes.
    bind:
      enabled:
      - name: DefaultBinder # DefaultBinder is a plugin that binds the pod to the node.
- schedulerName: my-scheduler-high-priority
  plugins:
    score:
      enabled:
      - name: NodeResourcesBalancedAllocation
      - name: NodeResourcesFit
      bind:
        enabled:
        - name: DefaultBinder
```





