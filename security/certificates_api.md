# Certificates API
- When we need to access to the cluster, we need to have a certificate. for example, you are admin in the cluster.
- 1 developer come to you and ask you to give him a certificate to access the cluster.
- You tell him that you should create a private key and a certificate signing request (CSR) and send it to the cluster admin.
- The cluster admin will sign the CSR and send back the certificate to the developer.
- But this certificate will expire after a while, so the developer should renew it.
- Because of that, we have a certificates API in k8s to manage the certificates.
- This api will be an CA (Certificate Authority) in the cluster.

When a cluster created, kubeadm will create a CA in master node. Because of that, this server also called as CA server.

---

- Create a private key and a certificate signing request (CSR):

```bash
openssl genrsa -out hus.key 2048

openssl req -new -key hus.key -out hus.csr -subj "/CN=hus"
# Output is hus.csr
```

---

- Create a certificatesigningrequest object:

```bash
cat hus.csr | base64 -w 0
# Output is base64 encoded csr. We will add this to the yaml file.
# -w 0 means no wrap.
```

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: hus-csr
spec:
  expirationSeconds: 604800 # 7 days
  usages:
    - digital signature # digital signature means that this certificate can be used to sign other certificates.
    - key encipherment # key encipherment means that this certificate can be used to encrypt data.
    - server auth # server auth means that this certificate can be used to authenticate a server.
  request: <base64 encoded csr>
  signerName: kubernetes.io/kube-apiserver-client # kube-api-server-client will sign this csr.
```

```bash
kubectl apply -f csr.yaml
```

---

- Review the certificatesigningrequest and approve it:

```bash
kubectl get csr
kubectl certificate approve hus-csr
kubectl certificate deny hus-csr

kubectl get csr -o jsonpath='{.items[0].status.certificate}'

kubectl get csr -o yaml
```

---


This mechanism controls from control manager. It has 2 component. CSR-APPROVING, CSR-SIGNING. CSR-APPROVING is responsible for approving the CSR. CSR-SIGNING is responsible for signing the CSR.

We can see them in the kube-controller-manager.yaml file.

```bash
cat /etc/kubernetes/manifests/kube-controller-manager.yaml

# --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
# --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
```