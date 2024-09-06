# Authentication

## Accounts
- In kubernetes, we have 2 type for accounts;
- User accounts
  - For humans
- Service accounts
  - For internal services (pods etc.)

---

When we execute `kubectl` or `curl http://kube-server:port`, these commands will go to api-server. Api-server;
- Authenticates the request
- Executes the request

---

We have 4 ways to authenticate:
- Static Password File (Not recommended) (Basic Auth) (Deprecated)
- Static Token File
- Certificate based authentication
- External authentication provider


# Static Password File
- We can create a file that contains username and password. We can use csv or htpasswd format.

```csv
password123,user1,u0001,group1 -> username: user1, password: password123, uid: u0001, group: group1
password123,user2,u0002,group1
password123,user3,u0003,group2
password123,user4,u0004,group3
```

- After that, we will change api-server yaml file or service file to use this file.

```yaml
...
spec:
  containers:
  - command:
    - kube-apiserver
    - --basic-auth-file=/etc/kubernetes/users.csv
...
```

```bash
vim kube-apiserver.service

# Add this line
# --basic-auth-file=/etc/kubernetes/users.csv
```

- After that, we will restart the api-server.


We can authenticate with this command:
```bash
# -k: insecure -> because we don't have a valid certificate
# -v: verbose -> to see the response
# -u: username and password -> user1:password123
curl -k -v -u user1:password123 https://master-node-ip:6443/api/v1/pods
```


# Static Token File

- We can create a file that contains token and username.

```csv
Kvfdgfddsfsdrew,user1,u0001,group1 -> token: Kvfdgfddsfsd, username: user1, uid: u0001, group: group1
Kvfdgfddsfsdttr,user2,u0002,group1
Kvfdgfddsgfhytd,user3,u0003,group2
Kvfdgfddsfsghjd,user4,u0004,group3
```

- After that, we will change api-server yaml file or service file to use this file.

```yaml
...
spec:
  containers:
  - command:
    - kube-apiserver
    - --token-auth-file=/etc/kubernetes/users.csv
...
```

```bash
vim kube-apiserver.service

# Add this line
# --token-auth-file=/etc/kubernetes/users.csv
```

- After that, we will restart the api-server.

- We can authenticate with this command:

```bash
curl -k -v https://master-node-ip:6443/api/v1/pods --header "Authorization: Bearer Kvfdgfddsfsdrew"
```
