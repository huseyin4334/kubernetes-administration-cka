# Upgrade A Node
- New version is 1.31.0

Update package manager for find last version. We should check the latest version of the package before upgrading.

```bash
vim /etc/apt/sources.list.d/kubernetes.list
# deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31.0/deb/ /
# paste the line above to the file and save it.

sudo apt-get update

# apt-cache madison <package-name> to find the latest version
sudo apt-cache madison kubeadm
# | kubeadm | 1.31.0-00 | https://pkgs.k8s.io/core:/stable:/v1.31.0/deb/  | amd64 | Kubernetes for Ubuntu
```

---

Upgrade kubeadm.

```bash
# apt-mark unhold is used for remove the holded package.
# when a package is holded, it will not be updated. Because of that, we need to remove the hold mark from the package.
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.31.0-00
sudo apt-mark hold kubeadm

# Check the version
kubeadm version
```

---

Apply the upgrade.

```bash
kubeadm upgrade plan v1.31.0
kubeadm upgrade apply v1.31.0

# or

kubeadm upgrade node
```

---

Upgrade kubelet and kubectl.

```bash
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.31.0-00 kubectl=1.31.0-00
sudo apt-mark hold kubelet kubectl

# restart kubelet
# daemon-reload is used for reload the configuration file of the service.
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```


> https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/


# All Commands
```bash
# If node is a worker node, drain the node.
kubectl drain <node-name> --ignore-daemonsets

vim /etc/apt/sources.list.d/kubernetes.list
# deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31.0/deb/ /

sudo apt-get update
sudo apt-cache madison kubeadm

sudo apt-get install -y kubeadm=1.31.0-00
kubeadm version

kubeadm upgrade apply v1.31.0

sudo apt-get install -y kubelet=1.31.0-00 kubectl=1.31.0-00
sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl uncordon <node-name>
```

# Summary
> Read: [Upgrade A Node](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

> Read: [Pdf](https://medium.com/@walissonscd/keeping-your-kubernetes-cluster-secure-understanding-and-managing-certificates-14b21416c127#:~:text=Kubernetes%20certificates%20are%20digital%20documents,and%20services%2C%20within%20the%20cluster.)