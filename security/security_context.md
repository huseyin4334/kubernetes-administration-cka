# Security Context
We spoke about the security in the container with the docker.

In this lesson, we will talk about the security in the pod with the kubernetes.

---

We have 2 options for the security in the pod:
- we can configure in the pod level
- we can configure in the container level
- if we configure them both, the container level configuration overrides the pod level configuration

---

Do the security configuration in the pod level:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  securityContext:
    runAsUser: 1000 # run the container as the user with the UID 1000
    runAsGroup: 3000 # run the container as the group with the GID 3000
    fsGroup: 2000 # fsGroup is the group that owns the volume. This means the group with the GID 2000 owns the volume.
  containers:
    - name: my-container
      image: nginx
```

---

Do the security configuration in the container level:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    containers:
    - name: my-container
      image: nginx
      securityContext:
        runAsUser: 1000 # run the container as the user with the UID 1000
        runAsGroup: 3000 # run the container as the group with the GID 3000
        fsGroup: 2000 # fsGroup is the group that owns the volume. This means the group with the GID 2000 owns the volume.
```

---

> Don't forget, capabilities are only supported in the container level.

Let's see the capabilities in the container level:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    containers:
    - name: my-container
      image: nginx
      securityContext:
        capabilities:
          add: ["SYS_TIME", "SYS_ADMIN"]
          drop: ["SYS_ADMIN"]
```




## Lab Codes

```bash
whoami

kubectl exec -it my-pod -- whoami
```