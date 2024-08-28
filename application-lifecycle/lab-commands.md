# Multi Container
```bash
# Into the pod with the web-server container
kubectl exec -it multi-container-pod -c web-server -- /bin/bash

kubectl exec -it multi-container-pod -- cat /log/app.log
```

---

We can share data between containers in a pod using volumes.
For example, 
- we can mount a volume to the web-server container and the log-collector container.
- The web-server container writes logs to the volume.
- The log-collector container reads logs from the volume.
- When we into the log-collector container, we can see in the /log directory the logs written by the web-server container.
- When /var/log/nginx directory have;
  - access.log
  - error.log
  - other_log.log (It's written by the log-collector container)
  - ...
- When /log directory have;
  - access.log
  - error.log
  - other_log.log (It's written by the log-collector container)
  - ...

We shared the logs between the web-server container and the log-collector container.

```bash
# Into the pod with the log-collector container
kubectl exec -it multi-container-pod -c log-collector -- /bin/sh

# Check the logs written by the web-server container
cat /log/access.log
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
    containers:
    - name: web-server
      image: nginx
      volumeMounts:
        - mountPath: /var/log/nginx # The directory where the logs are written by the web-server container. This directory will write this folder to the volume. And It will equalize the other unavailable files in the container.
          name: log-volume
    - name: log-collector
      image: busybox
      volumeMounts:
        - mountPath: /log
          name: log-volume
    volumes:
      - name: log-volume
        emptyDir: {}
```

# Init Container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: myimage
      command:
        - sh
        - -c # The command to run in the shell. It will be a string.
        - sleep 20
```

```bash
# Into orange pod, the init-container is a container of initContainer section.
kubectl logs orange -c init-container
```