# Deployment
- Deployment is version control component of replicaset.
- We can update the deployment without deleting the old one.
- We can rollback and pause, scale the pods with deployment.
- Deployment is a higher level object than replicaset.

## Yaml Architecture
- It's same with replicaset but the apiVersion have to be apps/v1.

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-1
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