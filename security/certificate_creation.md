# Creation of a Certificate
- We can use some tools to create a certificate.
  - `openssl`
  - `cfssl`
  - `easy-rsa`
- We will use the `openssl` tool to create a certificate.

In the concept, First, we will create a root CA certificate. After that, we will create server components certificates and admin certificate.
Root CA certificate is used to sign the server and client certificates.
Root CA certificate will be stayed in the client and other components to verify the components certificates.

## Root CA Certificate

Generate Key
```bash
openssl genrsa -out ca.key 2048
# This command creates a private key with 2048 bits.
```

---

Certificate Signing Request (CSR)
- We need to create a Certificate Signing Request (CSR) file.

```bash
openssl req -new -key ca.key -out ca.csr -subj "/CN=Kubernetes-ca"

# -new: Create a new CSR
# -key: Use the private key
# -out: Output file
# -subj: Subject of the certificate -> Common Name (CN)
```

---

Self-Signed Certificate

```bash
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt

# x509: Certificate data management -> X.509 is a standard that defines the format of public key certificates.
# -req: Use the CSR
# -in: Input file
# -signkey: Use the private key to sign the certificate
# -out: Output file
```

---

Check the Certificate

```bash
openssl x509 -in ca.crt -text -noout

# -in: Input file
# -text: Show the certificate in detail
# -noout: Don't show the encoded data
```


## Admin Certificate
Generate Key
```bash
openssl genrsa -out server.key 2048
# This command creates a private key with 2048 bits.
```

---

Certificate Signing Request (CSR)

```bash
openssl req -new -key admin.key -out admin.csr -subj "/CN=Kubernetes-server/O=system:masters"

# -new: Create a new CSR
# O: Organization -> system:masters is a group that has all the permissions in the Kubernetes cluster.
```

---

Self-Signed Certificate
We will use the root CA certificate to sign the server certificate.

```bash
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt
```


















## Components Certificates
- We will create certificates for the components.
  - kube-apiserver
  - kube-controller-manager
  - kube-scheduler
  - kube-proxy
  - kubelet
  - etcd

We assume we gave the root CA certificate to the components. Because these components verify the certificates with the root CA certificate.

### Kube-apiserver

Generate Key
```bash
openssl genrsa -out apiserver.key 2048
```

---

Certificate Signing Request (CSR)
- We will define dns names and ip addresses in the configuration file.

```bash
openssl req -new -key apiserver.key -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
```

- We can connect the api server with the dns names and ip addresses.

```cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[ v3_req ]
...
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 172.76.6.7
```

Connection Example with DNS Name

```bash
openssl s_client -connect kubernetes:6443
```

---

Self-Signed Certificate
We will use the root CA certificate to sign the server certificate.

```bash
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt
```

### Kubelet
We can see the certificates in kubelet configuration file.

```yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  x509:
    clientCAFile: "/etc/kubernetes/pki/ca.crt" # This is the certificate of the root CA
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
...
tlsCertFile: "/etc/kubernetes/pki/kubelet.crt" # This is the certificate of the kubelet
tlsPrivateKeyFile: "/etc/kubernetes/pki/kubelet.key" # This is the private key of the kubelet
```


# View Certificates
We will look at component certificates and explain how they communicate with each other.

```bash
cat /etc/kubernetes/manisfest/kube-apiserver.yaml

# --client-ca-file=/etc/kubernetes/pki/ca.crt -> This is the certificate of the root CA
# --tls-cert-file=/etc/kubernetes/pki/apiserver.crt -> This is the certificate of the kube-apiserver
# --tls-private-key-file=/etc/kubernetes/pki/apiserver.key -> This is the private key of the kube-apiserver

# --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt -> This is the certificate of the root CA of the etcd
# --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt -> This is the certificate of the kube-apiserver to communicate with the etcd
# --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key -> This is the private key of the kube-apiserver to communicate with the etcd

# --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt -> This is the certificate of the kube-apiserver to communicate with the kubelet
# --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key -> This is the private key of the kube-apiserver to communicate with the kubelet
```

- When api server communicate with kubelet;
  - Api server send a request to the kubelet with the certificate of the api server (apiserver-kubelet-client.crt)
  - Kubelet will look at the certificate signer. If the certificate is signed by the trusted certificate authority, kubelet will trust the certificate. (For example, our root CA certificate)
  - Tls handshake will start. 
    - If kubelet trust the certificate, kubelet will send the public key.
    - If the api server trust the certificate, api server will encrypt the symmetric key with the public key of the kubelet.
    - Kubelet will decrypt the symmetric key with the private key.
    - They will use the symmetric key to encrypt the messages. (Client sends the symmetric keys in the communication.)
  - Request will execute and the response will encrypt with the symmetric key and send to the api server.
  - Api server will decrypt the message with the symmetric key.

---

Let's look at the certificate;

```bash
openssl x509 -in /etc/kubernetes/pki/apiserver-kubelet-client.crt -text -noout

# In the certificate, we can see the issuer, subject, public key, signature, and other information.
# Issuer: The certificate authority that signed the certificate (Root CA)

# Subject: The owner of the certificate
# Public Key: The public key of the certificate

# Dns names and ip addresses are in the certificate.

# Not After: The certificate expiration date
```


# Example
- We will change the etcd certificate of the api server. Api server will not get information from the etcd.

```bash
crictl ps -a | grep apiserver

# Find the api server container id

crictl logs <container-id>

# 127.0.0.1:2379 -> This is the etcd server address
# Connection refused -> Api server can't connect to the etcd server
```

```bash
crictl ps -a | grep etcd

# Find the etcd container id

crictl logs <container-id>

# We will see the logs of the etcd server
# /etc/kubernetes/pki/etcd/server-bla.crt : no such file or directory


ls /etc/kubernetes/pki/etcd
# /etc/kubernetes/pki/etcd/server.crt -> This is the certificate of the etcd
# But api-server send a request with the server-bla.crt. Because of that, etcd can't find the certificate.

vim /etc/kubernetes/manifests/kube-apiserver.yaml

# Change the certificate file name to the correct name
# --etcd-certfile=/etc/kubernetes/pki/etcd/server.crt

# After that, api server will connect to the etcd server.
```

---

- We will change the etcd ca certificate in the api server. Because of that etcd will not trust the api server certificate.

```bash
crictl ps -a | grep apiserver

# Find the api server container id

crictl logs <container-id>

# Err: Connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority"

# Api server can't connect to the etcd server. Because etcd doesn't trust the certificate of the api server.

crictl ps -a | grep etcd

# Find the etcd container id

crictl logs <container-id>

# We will see the logs of the etcd server
# rejected connection from "<api-server-ip>:<port> (error "remote error: tls: bad certificate")"

# Etcd doesn't trust the certificate of the api server.

cat /etc/kubernetes/manisfest/kube-apiserver.yaml | grep etcd

# --etcd-cafile=/etc/kubernetes/pki/ca.crt -> This is wrong path. We need to change the path to the etcd root CA certificate.

vim /etc/kubernetes/manifests/kube-apiserver.yaml

# Change the certificate file name to the correct name
# --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt

# etcd have own root CA certificate.
```

