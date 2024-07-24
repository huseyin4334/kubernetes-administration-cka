# Container Runtime
- Container runtime is a software that is responsible for running containers. It is responsible for pulling images from a container registry, creating containers, starting containers, stopping containers, and deleting containers.
- Docker is a container runtime that is widely used in the industry. It is a complete platform that includes a container runtime, an image registry, and a set of tools for building, running, and managing containers.
- Containerd is a container runtime that is designed to be lightweight and modular. It is used by Docker as its container runtime, but it can also be used as a standalone container runtime.
- Containerd is a part of the CNCF (Cloud Native Computing Foundation) and is used by many other container platforms, such as Kubernetes and CRI-O.

In early days, Kubernetes used Docker as its container runtime. But Kubernetes grows and customers started to use other container runtimes likes rkt, cri-o etc.
Kubernetes started to use Container Runtime Interface (CRI) to support multiple container runtimes. 
CRI is a plugin interface that allows Kubernetes to use different container runtimes without changing the core Kubernetes code.
CRI have 2 specifications:
- imageSpec: This is specification for image management.
- runtimeSpec: This is specification for container runtime.

But, Docker is not CRI compliant. So, Kubernetes started to use dockershim to make Docker CRI compliant because Docker is widely used in the industry.
Later, Docker used containerd as its container runtime. So, Kubernetes started to use containerd as its container runtime.
In this way, Kubernetes standardized CRI with containerd and removed dockershim.

## Containerd
- Containerd is a container runtime that is designed to be lightweight and modular. It is used by Docker as its container runtime, but it can also be used as a standalone container runtime.
- It started as a part of Docker, but it was later donated to the CNCF (Cloud Native Computing Foundation) and is now a standalone project.

> Getting Started: https://github.com/containerd/containerd/blob/main/docs/getting-started.md

### Features
- ctr: A command line tool for managing containers and images. It's coming with containerd.
  - ctr is not very user friendly. It is only support limited features.
  - ctr designed for debugging and testing.
- nerdctl: A command line tool that is compatible with Docker CLI. It is built on top of containerd and provides a more user-friendly interface for managing containers and images.
  - It's more user friendly than ctr.
  - It provides a Docker-like CLI.
  - It is not a part of containerd. It is a separate project.
  - It support docker-compose.
  - It supports new containerd features.
    - Encrypted container images
    - Lazy pull
    - ...
- crictl: A command line tool for managing containers and images. It is designed to be compatible with the CRI (Container Runtime Interface).
  - It is used by Kubernetes to manage containers and images.
  - It can work with any CRI compliant container runtime.
  - It is designed to be compatible with the CRI (Container Runtime Interface).
  - It's same with docker commands.
- ctr images pull docker.io/library/alpine:latest
- docker run --rm -t alpine:latest echo hello -> nerdctl run --rm -t alpine:latest echo hello
- crictl pull docker.io/library/alpine:latest
- crictl images
- crictl ps -a
- crictl logs <container-id>
- crictl exec -it <container-id> sh

| | ctr | nerdctl | crictl     |
| -- | --- | --- |------------|
| Purpose | Debugging | General Use | Debugging  |
| Community | containerd | containerd | Kubernetes |
|Works with| containerd | containerd | CRI Compliant Container Runtime |


## Docker
- Docker is a container runtime that is widely used in the industry. It is a complete platform that includes a container runtime, an image registry, and a set of tools for building, running, and managing containers.
- Docker is high level tool that uses containerd as its container runtime.

## Containerd vs Docker
- If we don't need high level tools like Docker, we can use containerd as a standalone container runtime.

> Read: [Docker vs Containerd](https://www.docker.com/blog/containerd-vs-docker/#:~:text=In%20short%2C%20containerd%20is%20a,%2C%20networking%20capabilities%2C%20and%20more.)

> Read: [Dockershim](https://ammarsuhail155.medium.com/dokcershim-vs-containerd-5ab14447cb8f#:~:text=Docker%20Shim%3A,was%20the%20default%20container%20runtime.)


## Changes in Kubernetes
- Before v1.24, Kubernetes used dockershim to make Docker CRI compliant.
  - ***unix:///var/run/dockershim.sock***
  - ***unix:///var/run/containerd/containerd.sock***
  - ***unix:///run/crio/crio.sock***
  - ***unix:///var/run/cri-dockerd.sock***
  - dockershim is a shim layer that translates Kubernetes CRI calls to Docker API calls.
  - dockershim is a part of kubelet.
  - dockershim is deprecated in v1.24 and will be removed in v1.25.
  - dockershim is replaced with containerd in v1.24.
- With And After v1.24, Kubernetes started to use containerd for Docker CRI compliant.
  - ***unix:///var/run/containerd/containerd.sock***
  - ***unix:///run/crio/crio.sock***
  - ***unix:///var/run/cri-dockerd.sock***
  - containerd is a standalone container runtime that is used by Docker as its container runtime.
  - containerd is a part of kubelet.
- crictl --runtime-endpoint=unix:///var/run/containerd/containerd.sock
  - It is used to get or specify the runtime endpoint for the container runtime.
  - export CONTAINER_RUNTIME_ENDPOINT=unix:///var/run/containerd/containerd.sock


> Read: [Pdf](../sources/pdfs/core-concept/Docker+vs+Containerd+resource.pdf) 