FROM ubuntu:latest

# update and install dependencies
RUN apt-get update && apt-get upgrade -y

# Install packages
RUN apt-get install -y  software-properties-common \
    curl \
    wget \
    git \
    vim \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    gpg


# Install Vagrant
RUN sh ./commands/vagrant-setup.sh

# git clone the repo and vagrant up
RUN sh ./commands/prepare-nodes-with-vagrant.sh

# nodes are up and running
# prepare the nodes
RUN vagrant ssh kubemaster

RUN sh ./commands/containerd-setup.sh
RUN sh ./commands/kubelet-kubectl-kubeadm.sh
RUN sh ./commands/initialize-control-plane.sh

RUN vagrant ssh kubenode01
RUN sh ./commands/containerd-setup.sh
RUN sh ./commands/kubelet-kubectl-kubeadm.sh
RUN sh ./commands/join-node.sh

RUN vagrant ssh kubenode02
RUN sh ./commands/containerd-setup.sh
RUN sh ./commands/kubelet-kubectl-kubeadm.sh
RUN sh ./commands/join-node.sh

CMD ["vagrant", "ssh", "kubemaster"]