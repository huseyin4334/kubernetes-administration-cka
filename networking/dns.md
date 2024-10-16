# DNS
We spoke about ip addresses.
But, it is hard to remember the ip addresses of the websites. Because of that, we use domain names.
But, the computers don't know the domain names. They know the ip addresses.
Because of that, we need a DNS server.

DNS server is a server that stores the domain names and their ip addresses.

---

Let's speak with an example.

System A have an eth0 interface with `192.168.1.10` ip address.
System B have an eth0 interface with `192.168.1.11` ip address.
They are connected to the switch. Switch have an ip address `192.168.1.0`.
They are in the same network.

System A wants to reach system B.
System B's name is `system-b`.

System A sends a request to System B with its name.

```bash
ping system-b
# unknown host system-b
```

System A doesn't know the ip address of the `system-b`.
We will add this information to local DNS server.

```bash
# /etc/hosts file is used to store the domain names and their ip addresses
# We can add the domain name and ip address of the system-b to the /etc/hosts file.
# This file is used to resolve the domain names to ip addresses.
cat /etc/hosts

vim /etc/hosts

# Add the following line to the /etc/hosts file.
# 192.168.1.11 system-b
```

---

We have a local DNS server. But we can't manage all the domain names and their ip addresses.
Because of that, we need a global DNS server.

We can use the global DNS server to resolve the domain names to ip addresses.

```bash
# /etc/resolv.conf file is used to store the global DNS server's ip address.
# When we add a global server. The host will use this server to resolve the domain names to ip addresses.
cat /etc/resolv.conf

vim /etc/resolv.conf

# Add the following line to the /etc/resolv.conf file.
# nameserver  192.168.1.100 (Global DNS server's ip address)
```

---

For example, 1 name is available in local dns server and the global dns server.
System will accept the local dns server's ip address first.

But we can change the order of the dns servers.

```bash
# /etc/nsswitch.conf file is used to store the order of the dns servers.
# We can change the order of the dns servers.
cat /etc/nsswitch.conf

vim /etc/nsswitch.conf

# Change the following line in the /etc/nsswitch.conf file.
# hosts: files dns (This line means that the system will use the local dns server first and then the global dns server.)
# Change it to
# hosts: dns files (This line means that the system will use the global dns server first and then the local dns server.)
```

---

We are ok, but we can't access the other public domain names.

Then we should add a global and public DNS server to the /etc/resolv.conf file.

The most popular public DNS server is Google's DNS server.

```bash
vim /etc/resolv.conf

# Add the following line to the /etc/resolv.conf file.
# nameserver 8.8.8.8
```

---

## Domain Names
Domain names have a structure.
It has 3 parts.
- www
  - It is the **subdomain**. It is optional.
  - It is used to specify the service.
  - It is also called the hostname.
  - It uses for grouping the services.
    - www -> web services
    - drive -> file storage services
    - maps -> map services
    - ...
- google
  - It is the domain name.
  - It is the second-level domain.
  - It is also called SLD.
  - It is the name of the website and it is unique.
- com
  - It is the **top-level domain**.
  - It is also called TLD.
  - It uses for grouping the domain names.
    - com -> commercial
    - org -> organization
    - ...


### Search A Domain Name

Org. DNS > Root DNS > TLD DNS

www.google.com

1. The system will ask the local DNS server. (Org. DNS)
2. If the local DNS server doesn't know the domain name, it will ask the global DNS server. (Root DNS)
3. Root DNS server call the .com DNS server. (TLD DNS)
4. .com DNS server call the Google DNS server.
5. Google DNS server return the ip address to the .com DNS server.
6. .com DNS server return the ip address to the Root DNS server.
5. Root DNS server return the ip address to the local DNS server.
6. Local DNS server will cache the ip address for later and return the ip address to the system.


## Search Domain Names With Subdomain Names

mycompany.com

nfs, web, mail, ...

Domain dns server:

```txt
192.168.1.10  nfs.mycompany.com
192.168.1.11  db.mycompany.com
192.168.1.12  mail.mycompany.com
192.168.1.13  sql.mycompany.com
192.168.1.14  pay.mycompany.com
```

But we want to use just subdomain names when we search.

```bash
ping nfs
# unknown host nfs
```

Let's change Local DNS server:

```txt
vim /etc/resolv.conf

# nameserver 192.168.1.100 (Organization DNS server's ip address)
# search mycompany.com (This line means that the system will use this a suffix to the domain names.)
or
# search mycompany.com prod.mycompany.com (I can add more lines) (It will control for alls.)
```

Now, we can use just subdomain names.

```bash
ping nfs
# PING nfs.mycompany.com (...): 56 data bytes
```

## Record Types
Record types are used to store the different types of information in the DNS server.

- A Record
  - It is used to store the ip address of the domain name.
  - It is used to resolve the domain name to the ip address.
  - It is the most common record type.
- CNAME Record
  - It is used to store the alias of the domain name.
  - It is used to resolve the domain name to another domain name.
  - It is used to create the subdomain names.
- AAAA Record
  - It is used to store the ipv6 address of the domain name.
  - It is used to resolve the domain name to the ipv6 address.

| Record Type | Domain Name    | IP Address                              |
|-------------|----------------|-----------------------------------------|
| A           | google.com     | 192.168.1.1                             |
| CNAME       | www.google.com | goto.google, goto.search                |
| AAAA        | google.com     | 2001:0db8:85a3:0000:0000:8a2e:0370:7334 |

---

## Tools
### nslookup
nslookup is a command-line tool that is used to query the DNS server.
nslookup doesn't use the /etc/hosts file. It uses the DNS server.

```bash
# nslookup command is used to query the DNS server.
nslookup google.com

# Server:     8.8.8.8
# Address:    8.8.8.8#53

# Non-authoritative answer:
# Name:   google.com
# Address: .... (ip address)
```

### dig
dig is a command-line tool that is used to query the DNS server.
dig uses the /etc/hosts file. It uses the DNS server.

```bash
# dig command is used to query the DNS server.
dig google.com

# ;; ANSWER SECTION:
# google.com.     300 IN  A .... (ip address)
```