# Resource Limits
We have 2 way to limit the resources of a container:
- Required minimum resources
- Maximum resources

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-limits-demo
spec:
    containers:
    - name: resource-limits-demo-ctr
      image: nginx
      resources:
        requests: # Required minimum resources
          memory: "64Mi"
          cpu: "250m"
        limits: # Maximum resources quota
          memory: "128Mi"
          cpu: "500m"
```

- When we set this configuration, the container will be scheduled to a node that has enough resources to satisfy the minimum required resources.

- Cloud provided CPU
- This name is used to describe the CPU resources that are provided by the cloud provider. The following are the names used by the cloud providers:
  - 1 AWS vCPU
  - 1 Azure Core
  - 1 GCP Core
  - 1 Hyperthread

- Memory Name
  - 1 Gi (Gibibyte) = 1024 Mi (Mebibytes) = 1073741824 bytes
  - 1 G (Gigabyte) = 1000 M (Megabytes) = 1000000000 bytes


## Behavior of resource limits

### No Request And No Limit
- If i don't use limitations, 1 pod can use all resources and other pod can't use and maybe crash.

### No Request But Set Limit
- If i don't set request but set limit, the pod can use all resources but can't use more than limit.
- But maybe in these pods need more than limit and can't use although there is enough resources.

### Set Request And Set Limit
- If i set request and limit, the pod can use resources between request and limit.
- But if the pod needs more than limit, although there is enough resources.

### Set Request But No Limit
- If i set request but don't set limit, the pod can use resources more than request.
- But we said every pod will be up (with request limiting). And if pods need resources more than request, they can use if there is enough resources.


## Limit Range
- LimitRange is a policy to constrain resource allocations (to Pods or Containers) in a namespace.
- If you create a pod before limit range, it won't be affected.
- The default section will set up the default limits for a container in a pod. Any container with no limits defined will get these values assigned as default.
- The defaultRequest section will set up the default requests for a container in a pod. Any container with no requests defined will get these values assigned as default.
- The max section will set up the maximum resources that a container in a pod can use.
- The min section will set up the minimum resources that a container in a pod can use.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-range-demo
spec:
  limits:
    - default: # this is mean limit
        cpu: 500m
        memory: 512Mi
      defaultRequest: # this is mean request
        cpu: 250m
        memory: 256Mi
      type: Container # Pod or Container
      max: # Maximum resources.
        cpu: "1"
        memory: 1Gi
      min: # Minimum resources.
        cpu: 100m
        memory: 100Mi
```


## Resource Quota
- ResourceQuota is a policy to constrain resource consumption in a namespace.
- For example, all pods can use 1 CPU and 1Gi memory in a namespace totally.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: resource-quota-demo
spec:
    hard:
        requests.cpu: "1"
        requests.memory: 1Gi
        limits.cpu: "2"
        limits.memory: 2Gi
```
