# Service Account
- Service Account is a special type of account used by an application or a virtual machine (VM) instance, not a person.
- Service accounts are used to perform automated tasks, such as running applications and virtual machines (VMs), without requiring user intervention.
- Service accounts have a token for JWT (JSON Web Token) authentication.

---

Create a service account:
```bash
kubectl create serviceaccount my-service-account

kubectl get serviceaccount my-service-account -o yaml

kubectl describe serviceaccount my-service-account

# We will see  mountable secrets and tokens
# my-service-account-token-kbbdm
```

When we created a service account, it's create a secret for save the token.

```bash
kubectl get secret my-service-account-token-kbbdm -o yaml

# I will see 3 keys in data section
# ca.crt, namespace, token
# ca.crt is the certificate authority
# token is the JWT token
# namespace is the namespace of the service account
```

Send a request to the Kubernetes API server:

```bash
kubectl proxy --port=8001

curl http://localhost:8001/api/v1/namespaces/default/pods -insecure \
  --header "Authorization: Bearer $(kubectl get secret my-service-account-token-kbbdm -o jsonpath={.data.token} | base64 -d)"
```

---

## How Kubernetes Manage Service Accounts
- Kubernetes have a default service account for each namespace.
- When created a pod in kubernetes, kubernetes automatically assign the default service account to the pod for connecting to the API server by pod.
- However, kubernetes volume mounts the service account token to the pod.
- If you want to use a specific service account, you can assign the service account to the pod.
- When we assign a service account to the pod, kubernetes automatically mount the service account token to the pod.
- However, we will see our service account volume mounted to the pod. We can see it with describe pod command.

> We can see the service account information in the pod's `/var/run/secrets/kubernetes.io/serviceaccount` directory.
> - ca.crt
> - namespace
> - token

I can set the service account in the pod definition file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    serviceAccountName: my-service-account
    containers:
    - name: my-container
      image: nginx
```

---

We can also say the kubernetes, "I don't want to mount the service account token to the pod." with `automountServiceAccountToken: false` field in the pod definition file.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    serviceAccountName: my-service-account
    automountServiceAccountToken: false
    containers:
    - name: my-container
      image: nginx
```

This we add automountServiceAccountToken: false field to the pod definition file, kubernetes doesn't mount the service account token to the pod.
So, we can add serviceAccountName, but it won't work like we want.

---

## Security Concerns And After 1.24 Version
- We have 4 problem. KEP 1205 - Bound Service Account Tokens
  - JWTs are not audience bound. Because of this, if the JWT token is stolen, it can be used by anyone.
  - The current model of storing the service account token in a secret and delivering it to nodes results in a broad attack surface for the kubernetes control plane when powerful components are run.
    - Because the secret is stored in etcd, and etcd is accessible by the kubelet.
  - JWTs are not time-bound. Because of this, if the JWT token is stolen, it can be used by anyone without an expiration time.
  - JWTs require a kubernetes secret per service account, which can be cumbersome to manage at scale.

And TokenRequest API is introduced in kep 1205. It's released in 1.24 version. This API is used to create a token for a service account.

- It's audience bound. (Token have aud field in the payload. It's the API server address. So, the token can be used only for the API server.)
  - And We don't have a secret that assigned to the service account. Then no one stole the token.
- It's time-bound. (Token have exp field in the payload.)
- Object bound. (Token have a reference to the service account.)
- Because token have extra fields for these problems.

---

Let's explain with an example:
But don't forget. We create a token, but it's not set to the service account with a secret. Also, we don't have to set it too. Because the token is created for the service account.

```bash
# Create a service account
kubectl create serviceaccount my-service-account

# Create a token for the service account
# This token is bound to the service account
kubectl create token my-service-account-token

# When we look at it with decrypted, we will see exp field.

jq -R 'split(".") | select(length > 0) | .[0],.[1] | @base64d | fromjson' <<< eyJhbG....
```

But if we want to create a service account token without expiration time, we should create our own secret.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
secrets:
- name: my-secret

---

apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: my-secret
  annotations:
    kubernetes.io/service-account.name: my-service-account
```
