# Scheduler
- Scheduler is a component of the Kubernetes control plane that manages the scheduling of pods onto nodes in the cluster.

## How does the scheduler work?
- The scheduler is a control the not inserted nodeName property in the pod spec.
- Later, It's call which node to schedule the pod on.
- When scheduler find the best node, it will insert the nodeName property in the pod spec.
- The kubelet on the node will see the nodeName property and start the pod on that node.


## No Scheduler
- When you create a pod, you can specify the nodeName property in the pod spec.
- If you didn't specify the nodeName property, the pod will be stayed in the pending state.

But if we created the pod and not specified the nodeName property, we can not edit the pod.
Because of that we have to create a Binding object to bind the pod to the node.

- Binding object is a resource that binds a pod to a node.

```yaml
apiVersion: v1
kind: Binding
metadata:
  name: my-binding
target:
    apiVersion: v1
    kind: Node
    name: my-node
```

- We should assign the Binding object with the following command.

```bash
curl --header "Content-Type: application/json" --request POST --data \
'{"apiVersion": "v1", "kind": "Binding", "metadata": {"name": "my-binding"}, "target": {"apiVersion": "v1", "kind": "Node", "name": "my-node"}}' \
http://localhost:8080/api/v1/namespaces/default/pods/pod-name/binding/
```


# Labels And Selectors
- Labels are key-value pairs that are attached to objects for grouping and selecting.

```shell
kubectl get pods --selector env=prod
```

```yaml
apiVersion: v1
kind: Replicaset
metadata:
  name: my-replicaset
  labels:
    env: prod
spec:
    replicas: 3
    selector:
        matchLabels:
            env: prod # this matcher have to be same with the labels of the pods, if not match, command will get error.
    template:
        metadata:
            labels:
                env: prod
                frontend: web
        spec:
            containers:
            - name: my-container
              image: nginx
```


# Annotations
- Annotations are key-value pairs that are attached to objects for metadata(general information).

```yaml
apiVersion: v1
kind: Replicaset
metadata:
  name: my-replicaset
  labels:
    env: prod
  annotations:
    buildVersion: 1.34
    developer: john
...
```


# Taints And Tolerations
- Taints are used to point the nodes that for special pods run into them.
- When we taint a node, if pods don't have tolerations, they can't run on that node.
- But Kubernetes don't guarantee that tolerated pods will run on this node that we taint.

- Taints have three parts:
    - key
    - value
    - taint-effect
        - NoSchedule
          - If a pod is already running on the node, it will not be evicted.
        - PreferNoSchedule
          - The control plane will try to avoid placing a Pod that does not tolerate the taint on the node, but it is not guaranteed.
        - NoExecute
          - If a pod is already running on the node, it will be evicted immediately.
> https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

```shell
kubectl taint nodes node-name key=value:taint-effect
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    containers:
    - name: my-container
      image: nginx
    tolerations:
    - key: "key"
      operator: "Equal" # Exists, Equal, Exists, NotExists
      value: "value"
      effect: "NoSchedule" # NoSchedule, PreferNoSchedule, NoExecute
```

- Master node has a taint that is NoSchedule effect automatically.
- If we want to run a pod on the master node, we have to add the toleration to the pod.

```shell
kubectl describe node master-node-name | grep Taints
```

-- Remove taint from the node
```shell
kubectl taint nodes node-name key=value:NoSchedule-
```


# Node Selector
- Node Selector is a way to select the nodes that the pod will run on them.
- We can set the nodeSelector property in the pod spec.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    containers:
    - name: my-container
      image: nginx
    nodeSelector:
      size: Large
      color: Blue
```

- We can set the labels to the nodes with the following command.

```shell
kubectl label nodes node-name size=Large
kubectl label nodes node-name color=Blue
```

- Delete the labels from the nodes with the following command.

```shell
kubectl label nodes node-name size-
kubectl label nodes node-name color-
```

## Limitations
- We can't use the nodeSelector property in the Deployment and Replicaset.
- We can not set nodeSelector with `or` and `not` keywords, it's working just with `and` keyword.

size is Large and color is Blue


# Node Affinity
- Node Affinity is a way to set the rules for the pods to run on the nodes.
- We can set the nodeAffinity property in the pod spec.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    containers:
    - name: my-container
      image: nginx
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution: # requiredDuringSchedulingIgnoredDuringExecution, preferredDuringSchedulingIgnoredDuringExecution
          nodeSelectorTerms:
          - matchExpressions:
            - key: size
              operator: In # In, NotIn, Exists, DoesNotExist
              values:
              - Large
              - Medium
            - key: color
              operator: NotIn
              values:
              - Blue
            - key: point
              operator: Exists
```

- We said with this definition that the pod will run on the nodes that have the size label with Large or Medium and color label with not Blue and point label exists.

- Explain the during cases:
  - requiredDuringSchedulingIgnoredDuringExecution
    - The pod will run on the nodes that match the rules. If the node doesn't match the rules, the pod will not run.
    - But if the node doesn't match the rules, but the pod is already running on the node, it will not be evicted.
  - preferredDuringSchedulingIgnoredDuringExecution
    - The control plane will try to avoid placing a Pod that does not tolerate the taint on the node, but it is not guaranteed.
    - But if the node doesn't match the rules, but the pod is already running on the node, it will not be evicted.
  - requiredDuringSchedulingRequiredDuringExecution (**Planned for v1.22**)
    - The pod will run on the nodes that match the rules. If the node doesn't match the rules, the pod will not run.
    - But if the node doesn't match the rules, and the pod is already running on the node, it will be evicted immediately.


# Combination of Node Selector and Node Affinity and Taints and Tolerations
- We can node base filter with taint and toleration. We can not guarantee that the pod will run on the node that we want.
- We can use nodeSelector and nodeAffinity pod base filter. We can guarantee that the pod will run on the node that we want.