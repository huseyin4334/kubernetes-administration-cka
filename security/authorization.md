# Authorization
- Authorization is the process of determining whether a user, program, or system is allowed to access a resource or perform a given action. It is a security mechanism that enables you to control access to resources based on policies, rules, or roles.
- In Kubernetes, authorization is handled by the API server, which uses the `Authorization` header in the request to determine whether the user is allowed to access the requested resource or perform the requested action.

We have 6 types of authorization modes in Kubernetes:
- Node
  - Node authorization is used to control access to the kubelet API on each node in the cluster.
- ABAC (Attribute-Based Access Control)
  - ABAC is a legacy authorization mechanism that uses a set of rules to determine whether a user is allowed to access a resource or perform an action.
  - If we use ABAC, we have to send a json for give the permissions.
  - This method don't have groups. Because of that we have to give the permissions for each user.
- RBAC (Role-Based Access Control)
    - RBAC is a more flexible and powerful authorization mechanism that allows you to define roles and role bindings to control access to resources and actions in the cluster.
- Webhook
  - Webhook authorization is an external authorization mechanism that allows you to use an external service to make authorization decisions.
- AlwaysDeny
  - AlwaysDeny is a built-in authorization mode that denies all requests.
- AlwaysAllow
  - AlwaysAllow is a built-in authorization mode that allows all requests.


> Note. If we set multiple authorization modes, the API server will start with the first mode that is enabled and configured.
> Api server will check the modes until it finds a mode that allows the request.
> If the request is allowed by any mode, the request will be allowed.
> If the request is denied by all mode, the request will be denied.


When we change the authorization mode, we have to set this information in the kube-apiserver yaml or service file.

```txt
ExecStart=/usr/local/bin/kube-apiserver 
  ...
  --authorization-mode=AlwaysAllow # we can set multiple modes with comma (RBAC,Node)
  ...
```


# RBAC
- RBAC is a more flexible and powerful authorization mechanism that allows you to define roles and role bindings to control access to resources and actions in the cluster.

In this way, we have 4 main components:
- Role
  - A role is a set of rules that define what actions a user is allowed to perform on a resource.
- ClusterRole
  - A cluster role is a set of rules that define what actions a user is allowed to perform on a resource in the entire cluster.
- RoleBinding
  - A role binding is a mapping between a role and a user or group that grants the user or group the permissions defined in the role.
- ClusterRoleBinding
  - A cluster role binding is a mapping between a cluster role and a user or group that grants the user or group the permissions defined in the cluster role.
- ServiceAccount
  - A service account is an identity that can be used by pods to authenticate with the Kubernetes API server.
  - Service accounts are used to give pods access to resources in the cluster.


## Role And RoleBinding
- A role is a set of rules that define what actions a user is allowed to perform on a resource.
- We can set resource names in the role.
- watch is used for watching the resource. It's like a real-time monitoring.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-role
rules:
  - apiGroups: [""] # "" indicates the core API group, which includes resources like pods and services.
    resources: ["pods"] # The resources field specifies the resources that the role applies to.
    verbs: ["get", "list", "watch"] # The verbs field specifies the actions that the role allows.
    resourceNames: ["my-one-pod"]
  - apiGroups: [""]
    resources: ["ConfigMap"]
    verbs: ["create", "update", "delete"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch"]
    resourceNames: ["my-deploy", "other-my-deploy"]
```

We can create the role with the `kubectl` command too.

```bash
kubectl create role \
    --verb=get,list,watch \
    --resource=pods \
    --resource-name=my-one-pod \
    --namespace=default \
    developer-role
```

- A role binding is a mapping between a role and a user or group that grants the user or group the permissions defined in the role.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
subjects:
- kind: User # The kind field specifies the type of the subject, which can be User, Group, or ServiceAccount.
  name: backend-developer
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: frontend-developer
  apiGroup: rbac.authorization.k8s.io
roleRef: # The roleRef field specifies the role that the binding applies to.
  kind: Role # The kind field specifies the type of the role, which can be Role or ClusterRole.
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

We can create the role binding with the `kubectl` command too.

```bash
kubectl create rolebinding \
    --role=developer-role \
    --user=backend-developer \
    --group=frontend-developer \
    --namespace=default \
    developer-binding
```


## Check Access
We can check the access with the `can-i` command.

```bash
kubectl auth can-i create pods --as developer --namespace default

kubectl auth can-i create pods

kubectl auth can-i delete deployments --as developer --namespace default
```


## ClusterRole And ClusterRoleBinding
- A cluster role is a set of rules that define what actions a user is allowed to perform on a resource in the entire cluster.
- The difference between the role and cluster role is that the role is for the namespace and the cluster role is for the entire cluster.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-admin
rules:
    - apiGroups:
      - ""
      resources:
      - Nodes
      verbs:
      - get 
```

We can create the cluster role with the `kubectl` command too.

```bash
kubectl create clusterrole \
    --verb=get \
    --resource=nodes \
    cluster-admin
```

- A cluster role binding is a mapping between a cluster role and a user or group that grants the user or group the permissions defined in the cluster role.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-binding
subjects:
- kind: User
  name: admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

We can create the cluster role binding with the `kubectl` command too.

```bash
kubectl create clusterrolebinding \
    --clusterrole=cluster-admin \
    --user=admin \
    cluster-admin-binding
```