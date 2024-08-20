# DaemonSet
- DaemonSet ensures that all (or some) Nodes run a copy of a Pod
- We can use it to run monitoring agents, log collectors, etc.
- It is similar to ReplicaSet, but it runs a copy of a Pod on each Node
- ReplicaSet ensures a specific number of Pods are running, but DaemonSet ensures that all Nodes run a copy of a Pod

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-daemon
spec:
    selector:
        matchLabels:
          app: monitoring-agent
    template:
        metadata:
          labels:
            app: monitoring-agent
        spec:
          containers:
          - name: monitoring-agent
            image: monitoring-agent:v2
```

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: monitoring-replicaset
spec:
    replicas: 3
    selector:
        matchLabels:
          app: monitoring-agent
    template:
        metadata:
          labels:
            app: monitoring-agent
        spec:
          containers:
          - name: monitoring-agent
            image: monitoring-agent:v2
```