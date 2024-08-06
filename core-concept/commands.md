# Lab 1
``` shell
# This command will create a pod with the name redis.
# It will use the image redis123.
# dry-run=client: It will not create the pod. It will just show the yaml file.
# -o yaml: It will export the output as yaml.
kubectl run redis --image=redis123 --dry-run=client -o yaml > redis-definition.yaml

kubectl apply -f redis-definition.yaml

kubectl edit pod redis

# We can see wide information about the pods. (For example, the node that the pod is running on.)
kubectl get pods -o wide
```

# Docker link
``` shell

docker run python-app

# We can link the python-app container to the helper-app container.
# This means that the helper-app container can access the python-app container with the name python-app.
docker run helper-app --link python-app
```

# Lab 2
replicaset-1.yaml
``` yaml
apiVersion: *apps/v1 # api version have to be apps/v1. (Can't v1)
kind: ReplicaSet
metadata:
  name: replicaset-1
  labels:
    app: *frontend # template.metadata.labels.app have to be the same as this.
spec:
    replicas: 2
    selector:
        matchLabels:
        app: nginx
    template:
        metadata:
        labels:
            app: *nginx # template.metadata.labels.app have to be frontend
        spec:
        containers:
        - name: nginx
            image: nginx:1.14.2
```

``` shell

kubectl apply -f replicaset-1.yaml

kubectl get replicaset

kubectl describe replicaset replicaset-1

kubectl get pods

# Edit the replicaset. If we change the container image, we have to delete old pods.
kubectl edit replicaset replicaset-1

# Delete all pods with the label app=nginx
kubectl delete pod -l app=nginx

# Same scale commands
kubectl scale --replicas=5 replicaset replicaset-1
kubectl scale --replicas=2 replicaset-1.yaml

# Replace the replicaset with the new one.
kubectl replace -f replicaset-1.yaml
```

# Kubectl Get All
``` shell
# Get all resources in the default namespace.
kubectl get all

# Get all resources in all namespaces.
kubectl get all --all-namespaces
```


# Lab 3
``` shell

# Create a deployment simulation with the name nginx-deployment and get yaml response to the nginx-deployment.yaml file.
kubectl create deployment --image=nginx nginx-deployment --dry-run=client -o yaml > nginx-deployment.yaml

```

# Lab 4
``` shell
# Expose the pod with the name redis with the port 6379 and the name redis-service.
# This will get pod labels automatically to the selector.
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml > redis-service.yaml

# This won't assign selector automatically. We have to assign it manually.
kubectl create service nodeport redis --tcp=6379:6379 --dry-run=client -o yaml > redis-service-nodeport.yaml
kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml > redis-service-clusterip.yaml
```