# Env Variables
- Default way
- Using `env` key

```bash
kubectl run mypod --image=ubuntu --env="key1=value1" --env="key2=value2"
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      env:
      - name: key1
        value: value1
      - name: key2
        value: value2
```


# ConfigMap
- ConfigMap is a key-value pair that stores configuration data.
- We have 2 option to create ConfigMap:
  - Using `kubectl create configmap` command
  - Using `kubectl apply -f` command with yaml file

```bash
kubectl create configmap myconfigmap --from-literal=key1=value1 --from-literal=key2=value2

kubectl create configmap myconfigmap --from-file=config.txt # or another files. --from-file=config.properties

kubectl create configmap myconfigmap --from-file=config.txt --from-file=config2.txt
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfigmap
data:
  key1: "value1"
  key2: "value2"
```

---

We have 2 options to use ConfigMap in a pod:
- Using `env` key
- Using `envFrom` key

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      envFrom:
      - configMapRef:
          name: myconfigmap # This is the name of the ConfigMap. This is get all key-value pairs from the ConfigMap.
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      env:
        - name: key1
          valueFrom:
            configMapKeyRef:
              name: myconfigmap
              key: key1
```


# Secret
- Secret is a key-value pair that stores sensitive data.
- Secrets save in base64 encoded format.
- Because of that, it's not fully secure. But it's better than plain text.
- When we create a secret, secret saves in etcd. But it's not encrypted. It saves base64 decoded format.
  - `password` is base64 encoded format: `cGFzc3dvcmQ=`.
    - We will see this when execute `kubectl get secret mysecret -o yaml` command.
  - But when we look at the etcd, we will see the plain text `password`.
- We can encrypt the secrets.
- We can create with 2 options:
  - Using `kubectl create secret` command
  - Using `kubectl apply -f` command with yaml file

- Everyone can access the secrets in the cluster. But we can restrict the access with `RBAC` (Role-Based Access Control).
- Third party providers provide more secure solutions. For example, `HashiCorp Vault`.

```bash
kubectl create secret generic mysecret --from-literal=password=mypassword

# generic is the type of the secret. We have 3 types:
# - generic: This is the default type. We can store key-value pairs.
# - docker-registry: We can store docker registry credentials.
# - tls: We can store tls certificates.
kubectl create secret generic mysecret --from-file=secret.txt

kubectl create secret docker-registry mysecret --docker-server=myserver --docker-username=myusername --docker-password=mypassword --docker-email=myemail

kubectl create secret tls mysecret --cert=cert.crt --key=key.key
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque # This is the type of the secret. We have multiple types: Opaque, kubernetes.io/service-account-token and etc.
data:
  password: cGFzc3dvcmQ= # echo -n "mypassword" | base64 (encode) ///// echo -n "cGFzc3dvcmQ=" | base64 -d (decode)
```
> https://kubernetes.io/docs/concepts/configuration/secret/


---

- We can use secrets in a pod with 3 options:
  - Using `env` key
  - Using `envFrom` key
  - Using `volumeMounts` key

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      envFrom:
      - secretRef:
          name: mysecret # This is the name of the secret. This is get all key-value pairs from the secret.
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      env:
        - name: password
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: password
```
---
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      volumeMounts:
      - name: myvolume
        mountPath: /etc/secret
    volumes:
    - name: myvolume
      secret:
        secretName: mysecret
```

- When we use `volumeMounts` key, we can see the secret data in the `/etc/secret` directory.

```bash
kubectl exec -it mypod -- /bin/bash

ls /etc/secret

# password file
cat /etc/secret/password
# mypassword
```


# Encrypting Secrets
> https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

- Encryption do by api-server. Because of that, we need to enable the encryption in the api-server.
- We need to add `--encryption-provider-config` flag to the api-server.
- We need to create a `encryption-config.yaml` file.
- When we create EncryptionConfiguration, we need to add `resources` and `providers` fields.
- When we add multiple providers, the api-server uses the first provider. If the first provider fails, the api-server uses the second provider.
- We have multiple encryption providers. We can find details in the official documentation.

```bash
# etcd-client is a tool to access etcd.
# we will use etcdctl to get etcd data.
apt-get install -y etcd-client
```

```bash
ps -aux | grep --encryption-provider-config
# We won't see any result. Because of that, we need to add the flag to the api-server.
```

```bash
# This command gets the secret data from etcd. we are using cert and cacert for the authentication.
ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/default/secret1 | hexdump -C
# We will see the decoded data. "password"
```

```bash
head -c 32 /dev/urandom | base64
# This command generates a 32 byte random string and encodes it with base64.
```

```bash

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets # This is the resource type. We can add multiple resources. For example, secrets, configmaps and etc. This means that the api-server encrypts the secrets.
    providers:
    - aescbc:
      keys:
      - name: key1
        secret: y0xdfgfhsdfsdfsgfjhghjkjhkjhk=  # base64 encoded secret -> head -c 32 /dev/urandom | base64
    - identity: {}
```

```bash
# We need to add the encryption configuration to the api-server.
vim /etc/kubernetes/manifests/kube-apiserver.yaml
# Add the --encryption-provider-config flag to the api-server command line.
# --encryption-provider-config=/etc/kubernetes/encryption-config.yaml

# We need to add volume to the api-server pod.
# Api server is a static pod. Because of that, we don't need to restart the api-server. It will be restarted automatically.
```

- We add volume to the api-server pod. Because api server need to access the encryption configuration file inside the pod.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
    - command:
        - kube-apiserver
        - --encryption-provider-config=/etc/kubernetes/encryption-config.yaml
      volumeMounts:
        - mountPath: /etc/kubernetes/encryption-config.yaml
          name: encryption-config
      name: kube-apiserver
  volumes:
    - name: encryption-config
      hostPath:
        path: /etc/kubernetes/encryption-config.yaml
        type: DirectoryOrCreate
```


```bash
crictl pods
# crictl is a tool to access containerd. We can see the pods with this command.
```

> Don't forget the encryption will work after the restart. Because of that, created secrets before the encryption won't be encrypted. We need to recreate the secrets.

```bash
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
# This command recreates the secrets. Because of that, the secrets will be encrypted.
```
