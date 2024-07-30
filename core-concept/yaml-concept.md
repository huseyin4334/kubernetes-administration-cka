# Kubernetes Yaml Architecture
- Kubernetes uses yaml files to define the resources that it manages.

Every yaml file has 4 parts:
- apiVersion
- kind
- metadata
- spec

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
  labels:
    app: redis
spec:
    containers:
    - name: redis
      image: redis
```

- apiVersion: It defines the version of the Kubernetes API that we are using.
- This version is different for each resource type.

 Kind       | Version 
------------|---------
 Pod        | v1      
 Service    | v1      
 ReplicaSet | apps/v1 
 Deployment | apps/v1 

- kind: It defines the type of the resource that we are creating.
- metadata: It defines the data that is used to identify the resource.
- spec: It defines the desired state of the resource.
  - containers: It defines the containers that will run in the pod. It is List. 