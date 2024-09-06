# Security Primitives
- In kubernetes, we have 2 issues to address:
  - Authentication: Who are you?
  - Authorization: What are you allowed to do?

When we defense the cluster. We focus kube-apiserver, because it is the entry point to the cluster.

# Authentication
- We have 3 ways to authenticate:
  - Password based authentication (Not recommended) (Basic Auth) (Deprecated)
    - Username and password
  - Token based authentication
    - Username and token
  - Certificate based authentication
    - Client certificate
    - Server certificate
  - External authentication provider
    - LDAP
    - OAuth
    - OpenID Connect
  - Service Account
    - Used by pods to authenticate to the API server
    - Automatically created by the API server
    - Or we can create them manually and assign them to pods

# Authorization
- We have 2 ways to authorize:
  - ABAC (Attribute Based Access Control) (Deprecated)
    - Static file that defines user access
  - RBAC (Role Based Access Control)
    - Define roles and role bindings
    - Roles are sets of permissions
    - Role bindings assign roles to subjects
  - Node Authorization
    - Authorize kubelet to access the API server
  - Webhook Mode
    - Use external service to make authorization decision
  - AlwaysDeny
    - Deny all requests

# TLS Certificates
- TLS certificates are used to secure communication between components in the cluster


# Network Policies
- By default, pods can communicate with each other
- Network policies allow you to restrict traffic between pods
