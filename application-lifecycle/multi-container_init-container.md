# Multi Container And Init Container
We can create multiple containers in a single pod. 
This is useful when we want to run multiple processes in a single pod. For example, we can run a web server and a log collector in a single pod. 
We can also run an init container before the main container starts.
The init container runs before the main container starts and can be used to perform tasks like setting up the environment, downloading files, etc.

---
When 1 container down, the pod is restarted.

The process running in the log agent container is expected to stay alive as long as the web application is running. If any of them fails, the POD restarts.
---

But at times you may want to run a process that runs to completion in a container.
For example a process that pulls a code or binary from a repository that will be used by the main web application.
Or a process that waits  for an external service or database to be up before the actual application starts.

In that case each init container is run one at a time in sequential order.
If any of the initContainers fail to complete, Kubernetes restarts the Pod repeatedly until the Init Container succeeds.

> https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

---

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
    containers:
    - name: web-server
      image: nginx
    - name: log-collector
      image: busybox
      args: [/bin/sh, -c, 'while true; do echo $(date) >> /var/log/access.log; sleep 5; done']
    initContainers:
    - name: init-container
      image: busybox
      args: [/bin/sh, -c, 'echo "Initializing the environment"; sleep 5']
```