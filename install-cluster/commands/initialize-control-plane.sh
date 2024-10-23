# inside the master node
IP_ADDR=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address $IP_ADDR --pod-network-cidr=10.244.0.0/16

# Above command will give some information about joining the cluster. Save the information to a file.
kubeadm token create --print-join-command > join-command.sh

# Create a directory for the kubeconfig files
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply weave network
kubectl apply -f https://github.com/weaveworks/weave/releases/download/latest_release/weave-daemonset-k8s-1.11.yaml

# We can set IPALLOC_RANGE to a different value if needed
# 10.244.0.0/16