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
