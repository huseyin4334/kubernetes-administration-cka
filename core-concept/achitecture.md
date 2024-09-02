# CORE CONCEPTS

We will explain the core concepts of the architecture of the platform with the ship example.

![architecture](../sources/images/kubernetes-cluster-architecture.svg)

## Kubernetes
Kubernetes is an open-source platform designed to automate deploying, scaling, and operating application containers. It is a container orchestration system for automating application deployment, scaling, and management. It was originally designed by Google and is now maintained by the Cloud Native Computing Foundation.
It is the platform that manages the containers and the resources of the cluster.

## Cluster
A cluster is a set of nodes that are grouped together. The nodes are the machines that run the containers. The cluster is the platform that manages the resources of the nodes and the containers.
Kubernetes is the platform that manages the cluster.

## Node
A node is an individual machine that is part of a cluster. It may be a physical machine or a virtual machine. Each node has the necessary services to run pods and is managed by the master components of the cluster.

### Master Node
The master node is the control plane of the cluster. 
It is responsible for managing the cluster and the resources of the nodes. 
It runs the master components of the cluster.

#### Master Components
- **API Server**: The API server is the front end for the Kubernetes control plane. It is the primary management point for the cluster.
  - It is responsible for handling the requests from the users and the components of the cluster.
  - Other components of the cluster communicate each other through the API server.
  - It's operation manager. It's brain of the cluster.
- **Controller Manager**: The controller manager is responsible for managing the controllers that regulate the state of the cluster.
- **Node Controller**: The node controller is responsible for managing the nodes of the cluster.
- **Replication Controller**: The replication controller is responsible for managing the replication of the pods. It's control desired state of the pods.
- **etcd**: etcd is a distributed key-value store that is used to store the state of the cluster.
- **Cloud Controller Manager**: The cloud controller manager is responsible for managing the cloud provider-specific control loops.
- **Kube-scheduler**: The kube-scheduler is responsible for scheduling the pods on the nodes. They know the resources of the nodes and the requirements of the pods.

### Worker Node
The worker node is the node that runs the containers.
It has some services to run the containers and is managed by the master components of the cluster.

#### Worker Components
- **Kubelet**: The kubelet is the primary "node agent" that runs on each node. It makes sure that the containers are running in a pod.
  - It's captain of the ship. It's responsible for the containers.
- **Kube-proxy**: The kube-proxy is responsible for maintaining network rules on the nodes.
  - It's responsible for the network of the cluster. 
  - It's responsible for the communication between the pods and the nodes.
- **Container Runtime**: The container runtime is responsible for running the containers.
  - It's the engine of the ship. It's responsible for running the containers.
  - Docker, containerd, cri-o, etc.


> Read: [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

> Read: [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)

> Read: [Kubernetes Architecture And Components](https://medium.com/@himanshusangshetty/kubernetes-architecture-and-components-explained-e489e98db15d)

> Read: [Pdf](../sources/pdfs/core-concept/Core+concepts+-2.pdf)

> Read: [Pdf](https://medium.com/@maheshwar.ramkrushna/kubernetes-directory-structure-c1fe0d3aa8ef#:~:text=Kubernetes%20directory%20structure%20includes%20%2Fetc,%2Fetc%2Fcni%2Fnet.)