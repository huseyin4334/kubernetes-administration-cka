# Replicaset And Replication Controller
- Replicaset and Replication Controller are both used to manage multiple pods. 
- They ensure that a specified number of pod replicas are running at any given time. 
- If a pod crashes, the Replicaset or Replication Controller replaces it. 
- They are both similar but have some differences.
  - Replicaset is the next-generation Replication Controller.
  - Replicaset supports the new set-based selector requirements.
    - Replicaset have a selector that checks the labels of the pods.
    - Replication Controller uses equality-based selector requirements.
  - Replicaset is the recommended way to manage pod replication.
- Both of them have the same structure.
  - `apiVersion`
  - `kind`
  - `metadata`
  - `spec`
    - `replicas`
    - `template`  (Template is equal to the pod definition.) 
      - `metadata`
        - `labels`
      - `spec`
        - `containers`
          - `name`
          - `image`

# Replicaset
``` yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-1
  labels:
    app: frontend
spec:
    replicas: 2
    selector:
      matchLabels:
        app: nginx
    template:
      metadata:
        labels:
          app: nginx
      spec:
        containers:
        - name: nginx
          image: nginx:1.14.2
```


# Replication Controller
``` yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: replication-controller-1
  labels:
    app: nginx
spec:
    replicas: 2
    template:
      metadata:
        labels:
          app: nginx
      spec:
        containers:
        - name: nginx
          image: nginx:1.14.2
```
