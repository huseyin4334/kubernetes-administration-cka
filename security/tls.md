# TLS Basics
- TLS (Transport Layer Security) is a cryptographic protocol that provides secure communication over a computer network.
- SSL (Secure Sockets Layer) is the predecessor of TLS.
- Certificate is a digital document that contains information about the public key and the identity of the owner.
  - Certificates verify the identity of the server and are used to establish a secure connection.

## Scenario
We want to authenticate the bank website. Website is hosted on `http://_mybank.com`

### Scenario 1
- When I fill the form and click submit, the data is sent to the server without encryption.
- So, Hacker can intercept the data and read it.
- We failed.

### Scenario 2
- When I fill the form and click submit, the data is sent to the server with encryption.
- But I have to send the decryption key to the server too.
- So, Hacker can intercept the key and decrypt the data.
- Name of this way is `Symmetric Encryption`.
- Because of that, we failed again.

### Scenario 3
- We will use `Asymmetric Encryption` to solve the problem.
- We will use `Public Key` and `Private Key`.
- Public Key is used for encryption and Private Key is used for decryption.
- Every user or server has a pair of keys.
- When I want to send a message to the server, I will use the server's public key to encrypt the message.
- The server will use its private key to decrypt the message.
- When the server wants to send a message to me, it will use my public key to encrypt the message.
- I will use my private key to decrypt the message.
- So, Hacker can't intercept the message because he doesn't have the private key.
- We succeeded.


---

- Create a key pair (Public Key and Private Key) (Server Side)

```bash
openssl genrsa -out private.key 2048
# This command creates a private key with 2048 bits.

openssl rsa -in private.key -pubout > public.pem
# This command creates a public key from the private key.

# These keys connect to each other mathematically.
```

- When I connect to the server, the server sends the public key to me.

```bash
cat public.pem
```

- I will use the public key to encrypt the message.

```bash
echo "Hello" | openssl rsautl -encrypt -pubin -inkey public.pem -out encrypted.txt
# This command encrypts the message with the public key and writes it to the file.
```

- The server will use the private key to decrypt the message.

```bash
openssl rsautl -decrypt -inkey private.key -in encrypted.txt
# This command decrypts the message with the private key.
```

---

Also, we can send our symmetric key with the public key.
Server will use the private key to decrypt the symmetric key.
Server will save the symmetric key for the decryption of the messages.
After that, we can use the symmetric key to encrypt the message for send data to the server.
Server will use the symmetric key to decrypt the message.


## Certificate
- Certificate is a digital document that contains information about the public key and the identity of the owner.

The hackers can create a fake website. we can also connect to the fake website.
And this fake website server can take our data. Because our data is encrypted with the public key of the fake website.

To prevent this, we need to verify the identity of the server.
The servers send their public keys and certificates to us. We can check the certificate to verify the identity of the server.

- We can use the `openssl` command to check the certificate of the website.

```bash
openssl s_client -connect _mybank.com:443 | openssl x509 -text
# This command connects to the server and shows the certificate in detail.
```

- We can use the `curl` command to check the certificate of the website.

```bash
curl -v https://_mybank.com
# This command connects to the server and shows the certificate in detail.
```

- Open certificate file with the text editor.

```bash
cat certificate.pem
```

- But every one can sign a certificate.
- Every browser has a list of trusted certificate authorities.
- If the certificate is signed by a trusted certificate authority, the browser will trust the certificate.
- If the certificate is not signed by a trusted certificate authority, the browser will show a warning message. (Your connection is not private)

```text
Certificate:
    Data:
      Serial Number: 456234225435645
    Signature Algorithm: sha256WithRSAEncryption
      Issuer: CN=Kubernetes
      Validity
        Not Before: Mar  1 00:00:00 2021 GMT
        Not After : Mar  6 23:59:59 2022 GMT
      Subject: CN=blabla.com (This is the domain name)
      Subject Alternative Name: DNS:blabla-3.com, DNS:blabla-2.com, DNS:blabla-1.com
      Subject Public Key Info:
        Public Key Algorithm: 
          00:b9:b0:55:44:5e:ba:5f:3b:4c
```

### Certificate Authorities
- Certificate Authorities are the organizations that issue the certificates.
- The browsers have a list of trusted certificate authorities.
  - Symantec
  - DigiCert
  - GlobalSign
  - Comodo
  - GoDaddy
  - ...

When we want to sign a certificate, we need to pay money to the certificate authority.
The certificate authority will check our identity and sign the certificate.

- Send a certificate signing request to the certificate authority `((Certificate Signing Request) CSR)`

```bash
openssl req -new -key private.key -out mybank.csr -subj "/C=TR/ST=Istanbul/L=Istanbul/O=MyBank/OU=IT/CN=mybank.com"
# This command creates a certificate signing request.
```

- Send the certificate signing request to the certificate authority.

- After the certificate authority checks our identity. `(Validation Information)`
- The certificate authority will sign the certificate. `(Sign And Send Certificate)`


- We can see the bowser's trusted certificates in the browser settings (Security -> Certificates -> Trusted Root Certification Authorities)


# Public Key Infrastructure (PKI)
- Public Key Infrastructure is a set of roles, policies, and procedures needed to create, manage, distribute, use, store, and revoke digital certificates and manage public-key encryption.
- So, All we have talked about is a part of the Public Key Infrastructure.


# Naming Strategy

Certificate (Public Key)
- *.crt
- *.pem

server.crt
server.pem
client.crt
client.pem

---

Private Key
- *.key
- *-key.pem

server.key
server-key.pem
client.key
client-key.pem
