# Kubeconfig
- Kube config is a file used to configure access to Kubernetes clusters with contexts, users, and clusters.
- It's a YAML file that contains information about how to connect to a Kubernetes cluster.

When we send a request for get pods, the request sends with key, certificate, and the root certificate.

```bash
curl https://api.k8s.example.com/api/v1/namespaces/default/pods \
--cacert ca.crt --cert client.crt --key client.key
```

Or when we use `kubectl` command, if we don't have the kubeconfig file, we need to provide the key, certificate, and the root certificate.

```bash
kubectl get pods \
  --server https://api.k8s.example.com \
  --certificate-authority ca.crt \
  --client-certificate client.crt \
  --client-key client.key
```

But we have the kubeconfig file for this, we don't need to provide the key, certificate, and the root certificate.


## Kubeconfig file location
- The default location of the kubeconfig file is `~/.kube/config`. Because of this, the `kubectl` command-line tool uses this file by default.
- You can specify a different location for the kubeconfig file by setting the `KUBECONFIG` environment variable.
- You can also specify the kubeconfig file location using the `--kubeconfig` flag when running `kubectl` commands.

```bash
kubectl get pods --kubeconfig my-kubeconfig
```

or

```bash
export KUBECONFIG=my-kubeconfig
kubectl get pods
```

or

```bash
kubectl get pods
```

## Kubeconfig file structure
- The kubeconfig file is a YAML file that contains three main sections: `clusters`, `users`, and `contexts`.
- The `clusters` section contains information about the Kubernetes clusters you want to connect to.
- The `users` section contains information about the users you want to authenticate with.
- The `contexts` section contains information about the contexts you want to use to connect to the clusters and users.
- We specify with the context which user will be used to connect to which cluster.
- The `current-context` field specifies which context should be used by default.
- We can change the default namespace with the `namespace` field in the context.

```yaml
apiVersion: v1
kind: Config
clusters:
- name: my-cluster
  cluster:
    server: https://api.k8s.example.com
    certificate-authority: etc/kubernetes/pki/ca.crt
    certificate-authority-data: <cat ca.crt | base64 -w 0> # This is an alternative to certificate-authority
users:
- name: my-user
  user:
    client-certificate: etc/my/way/client.crt
    client-key: etc/my/way/client.key
contexts:
- name: my-context
  context:
    cluster: my-cluster
    user: my-user
    namespace: default
current-context: my-context
namespace: other-namespace
```

---

```bash
# config commands
kubectl config -h

# get the current context
kubectl config current-context

# get the current context details
kubectl config view --minify

# get the current context details in YAML format
kubectl config view --minify -o yaml

# get all config details
kubectl config view

# get specified all config details
kubectl config view --kubeconfig=my-kubeconfig


# Change the current context
kubectl config use-context my-context

# Change the current context with the namespace
kubectl config set-context --current --namespace=other-namespace

# Change the context default namespace
kubectl config set-context my-context --namespace=other-namespace





