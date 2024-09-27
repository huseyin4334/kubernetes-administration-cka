# Image Security

When we set the image system parse the name like this `registry/image:tag`. If we don't set the tag, the system uses the `latest` tag.
- registry: The registry is the location of the image.
- user/account: The user or account is the owner of the image. If we don't set the user or account, the system uses the `library` account.
- image: The image is the name of the image.

docker.io/library/nginx:latest
gcr.io/google-samples/node-hello:1.0

When our image stored in the private registry, cluster needs to authenticate to the registry. We can use the secret for this.

First let's do it manually:

```bash
docker login private-registry.io

docker pull private-registry.io/my-image:latest
```

We will do this with the kubernetes;

```bash
# Create the secret. This secret will be used by the pods to authenticate to the private registry.
# Secrets have some types. We can use the docker-registry type for this.
kubectl create secret docker-registry my-secret \
    --docker-server=private-registry.io \
    --docker-username=my-user \
    --docker-password=my-password
```

We can use the secret in the pod definition file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    containers:
    - name: my-container
      image: private-registry.io/my-image:latest
    imagePullSecrets:
    - name: my-secret
```


# Docker Internal
`Host` is the server that runs the docker daemon. It can be a physical or virtual machine. And the docker daemon is the service that runs on the host and manages the containers.

`Container` Containers are isolated environments that run on the host. But it's not a virtual machine. 
It's a process that runs on the host and uses the host's kernel. Container have a namespace and cgroups.
When we run a container, the docker daemon creates a namespace for the container. This namespace is isolated from the host and other containers.
But the container executes on the host's kernel. So, the container can't have a different kernel than the host.
This container just see it namespace and cgroups. It can't see the other containers' namespace and cgroups.

Also, docker have a namespace too in the host.


When we go inside the container and look at the processes;

```bash
docker exec -it my-container bash

ps aux

# USER      PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root       1  0.0  0.0     4368  652 ?        Ss   14:00   0:00 sleep 1000

# PID is the process id. The process id is unique for each process.
# VSZ is the virtual memory size. It's the total memory that the process can use.
# RSS is the resident set size. It's the memory that the process is using.
# TTY is the terminal that the process is running.
# STAT is the status of the process. Ss means the process is sleeping. S1 means the process is sleeping and has a session leader.

exit

# Let's look at the processes on the host.
ps aux

# USER  PID   %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root  3805  0.0  0.0     4528  455 ?        S1   14:00   0:00 docker-containerd-shim
# ........
# root  3810  0.0  0.0     4368  652 ?        Ss   14:00   0:00 sleep 1000

# We see the same process on the host. The container process is the host process.
```

This is a process isolation in the container.

---

Let's look at the user usage in the container:

When we don't set the user in the container, the container runs as the root user.
We can change it in image or in the pod definition file.

```dockerfile
# In the Dockerfile
USER my-user
```

```yaml
# In the pod definition file
spec:
    containers:
    - name: my-container
      image: my-image
      securityContext:
        runAsUser: 1000
```

When we look at this issue in the security perspective;

Is host root user same as the container root user?
User is same but docker limits the container root user. 

We can see the capabilities `/usr/include/linux/capability.h` in the host.

Docker limits the capabilities of the container root user. It's a security mechanism.
MAC_ADMIN, BROADCAST, NET_ADMIN, SYS_ADMIN, ... not included in the container root user.

If we want to add capabilities to the container root user, we can use the `--cap-add` flag in the `docker run` command.

```bash
docker run --cap-add SYS_ADMIN my-image
```

We can also remove capabilities from the container root user with the `--cap-drop` flag.

```bash
docker run --cap-drop SYS_ADMIN my-image
```

Also, we can all capabilities to the container root user with the `--privileged` flag.

```bash
docker run --privileged my-image
```

When we run the container with the `--privileged` flag, the container root user has all capabilities. It's not a good practice. It's a security risk.