# Build Cluster With Vagrant
We will execute a vagrant script to build a cluster with 3 nodes. The script will create 3 virtual machines with the following characteristics:
- 1 Master node with 2 CPUs and 2GB of RAM
- 2 Worker nodes with 1 CPU and 1GB of RAM
- All nodes will have 20GB of disk space
- All nodes will have Ubuntu 18.04 installed

After that;
- We will do some configurations on all nodes.
- We will setup container runtime on all nodes (containerd).

> https://github.com/mmumshad/kubernetes-the-hard-way
> https://github.com/kodekloudhub/certified-kubernetes-administrator-course
> https://pwittrock.github.io/docs/getting-started-guides/scratch/
> https://medium.com/@mojabi.rafi/create-a-kubernetes-cluster-using-virtualbox-and-without-vagrant-90a14d791617


# Open A Ubuntu Machine In Docker
I will use a docker container to build the cluster. I will use the following command to open a ubuntu machine in docker.

```bash
docker run --it --name cluster --privileged ubuntu
```

# Install Container Runtime (CRI)
We will use containerd as the container runtime interface (CRI). We will install containerd on all nodes.

> https://kubernetes.io/docs/setup/production-environment/container-runtimes/

```bash
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sysctl net.ipv4.ip_forward
```

Install containerd on all nodes.
> https://github.com/containerd/containerd/blob/main/docs/getting-started.md
> https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository


After that continue from here;
> https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd

# Kubeadm Installation

```bash
# set net.bridge.bridge-nf-call-iptables to 1
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# To see the new version labels
sudo apt-cache madison kubeadm

sudo apt-get install -y kubelet=1.31.0-1.1 kubeadm=1.31.0-1.1 kubectl=1.31.0-1.1

sudo apt-mark hold kubelet kubeadm kubectl
```

# Kubeadm Initialization

```bash
# inside the master node
IP_ADDR=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address $IP_ADDR --pod-network-cidr=10.244.0.0/16

# Above command will give some information about joining the cluster. Save the information to a file.
kubeadm token create --print-join-command > join-command.sh

# Create a directory for the kubeconfig files
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

# Join The Worker Nodes To The Cluster
Execute join-command.sh in the worker nodes.

```bash
# inside the worker nodes
sh join-command.sh
```

# Add Network Plugin
```bash
curl -LO https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml

vim kube-flannel.yml
# find the line
# - --ip-masq
# - --kube-subnet-mgr
# add the following line to the file
# - --iface=eth0

kubectl apply -f kube-flannel.yml

# Check the status of the nodes
kubectl get nodes
```























