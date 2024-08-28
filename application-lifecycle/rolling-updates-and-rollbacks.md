# Rollout And Versioning
- Rollout is the process of deploying a new version of an application to a set of pods in a cluster.

- Rollout is a multi-step process that can include the following steps:
  - Create a new version of the application.
  - Update the deployment to use the new version.
  - Monitor the rollout to ensure it is successful.
  - Rollback the deployment if the new version is not working as expected.

- Rollout is a key feature of Kubernetes that allows you to update your applications without downtime.

```bash

kubectl create deployment myapp --image=myapp:v1 --replicas=10

kubectl set image deployment/myapp myapp=myapp:v2

# Check the status of the rollout
kubectl rollout status deployment/myapp

# ....
# Waiting for rollout to finish: 9 out of 10 new replicas have been updated...
# deployment "myapp" successfully rolled out

# This will show the history of the deployment
kubectl rollout history deployment/myapp

# deployments "myapp"
# REVISION  CHANGE-CAUSE --> Revision means the version of the deployment
# 1         <none>
# 2         kubelet set image deployment/myapp myapp=myapp:v2

# Rollback the deployment
kubectl rollout undo deployment/myapp
```

## Deployment Strategies
- There are several deployment strategies that you can use to update your applications in Kubernetes:
  - **Recreate**: This strategy creates a new set of pods with the new version of the application and then deletes the old set of pods in the same time.
    - This can cause downtime.
    - This is the default strategy.
  - **RollingUpdate**: This strategy updates the pods in a rolling fashion, one at a time, to minimize downtime.
    - It deletes 1 old pod and creates 1 new pod at a time.
    - It waits for the new pod to be ready before deleting the next old pod.
  - We can do other deployments strategies with manual steps.
    - **Blue/Green**: This strategy creates a new set of pods with the new version of the application and then switches traffic to the new set of pods.
      - This strategy works like rolling update, but it creates a new service to switch traffic to the new pods.
    - **Canary**: This strategy gradually rolls out the new version of the application to a subset of users to test it before rolling it out to all users.
- We can see selected strategy in the described deployment object. The name is `StrategyType`.

> When I changed the strategy type of the deployment, the deployment won't be redeployed. But it will work when updated the deployment.

---

Examples:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
    replicas: 3
    selector:
        matchLabels:
          app: myapp
    template:
        metadata:
          labels:
            app: myapp
        spec:
          containers:
          - name: myapp
            image: myapp:v1
    strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1 # This means that only 1 pod can be unavailable at a time. We can set this value like percentage. For example, 25% of the total number of pods.
          maxSurge: 1 # This means that only 1 pod can be created at a time. We can set this value like percentage. For example, 25% of the total number of pods.
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
    replicas: 3
    selector:
        matchLabels:
          app: myapp
    template:
        metadata:
          labels:
            app: myapp
        spec:
          containers:
          - name: myapp
            image: myapp:v1
    strategy:
        type: Recreate
```


## Upgrading Deployment
When we upgraded the deployment. Deployment creates a new replica set. And delete 1 old pod and create 1 new pod at a time. This is called `RollingUpdate` strategy.

When we call `kubectl get replicasets`, we can see the old replicaset with 0 desired pods and the new replicaset with the desired number of pods.


## Rollback Deployment
For example, We upgraded the deployment. But we found a very big problem in the new version. We can rollback the deployment to the previous version.

```bash
kubectl rollout undo deployment/myapp

# We can also rollback to a specific revision
kubectl rollout undo deployment/myapp --to-revision=1

# We can also pause the rollout
kubectl rollout pause deployment/myapp

# We can also resume the rollout
kubectl rollout resume deployment/myapp

# We can also cancel the rollout
kubectl rollout cancel deployment/myapp

# We can also restart the rollout
kubectl rollout restart deployment/myapp

# When we call the replicasets, we can see the old replicaset with the desired number of pods and the new replicaset with 0 desired pods.
kubectl get replicasets
```

