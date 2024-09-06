# Certificates
- We have 3 types of certificates:
  - Root CA: Used to sign the client CA
  - Client certificates: Used to secure the communication between the client and the server
  - Server certificates: Used to secure the communication between the server and the client

We use certificates in 3 ways;
- To secure the communication between the client and the server
- To secure the communication between the master node modules each other (etcd, kube-apiserver, kube-controller-manager, kube-scheduler)
- To secure the communication between the master and the worker nodes

---

## Server Certificates
- Kube-api server
  - apiserver.crt
  - apiserver.key
- ETCD
  - etcdserver.crt
  - etcdserver.key
- Kubelet
  - kubelet.crt
  - kubelet.key

These components have https endpoints. Because of that, they are classified as server. Then, they named as server certificates.


## Client Certificates
- Kube-controller-manager
  - controller-manager.crt
  - controller-manager.key
- Kube-scheduler
  - scheduler.crt
  - scheduler.key
- Admin (kubectl)
  - admin.crt
  - admin.key
- Kube-proxy
  - proxy.crt
  - proxy.key

These components are clients of the kube-api server. Because of that, they are classified as client. Then, they named as client certificates.


Also;
- Api-server
  - apiserver-kubelet-client.crt
  - apiserver-kubelet-client.key
- Api-server
  - apiserver-etcd-client.crt
  - apiserver-etcd-client.key
- kubelet
  - kubelet-client.crt
  - kubelet-client.key

Every component has different certificates to communicate with different server components.
For example api server is a client of the kubelet. Because of that, it has a certificate to communicate with kubelet. 
(The true way is use 1 certificate by 1 server component. Because of that, we have 3 certificates for the api server.)