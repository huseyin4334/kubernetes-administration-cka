# Network Policy
- Network policies are used to control the traffic flow between pods in a Kubernetes cluster.
- In default, when we create a pod, it can communicate with all other pods in the cluster without any restrictions. (With IPs, pod names, services, etc.)
- It can also take request from all ports.
- Network policy is a box. We will tell the network policy what can come in and what can go out.

---

We have 2 directions for the network policy:
- Ingress: Ingress is the incoming traffic to the pod.
- Egress: Egress is the outgoing traffic from the pod.

We will decide whether a request is incoming or outgoing depending on the pod to which we apply the network policy.

---

First rule;
We have a db and a web pod. We want to allow the web pod to access the db pod from port 3306. 
But we don't want the db pod to access the web pod.

Second Rule;
Our db shouldn't be accessible by other web apps in the other namespaces.

Third Rule;
Db will send the backup data to the external backup server. We want to allow the db pod to access the backup server.

Let's create the network policy for this:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-network-policy
spec:
    podSelector: # This is the pod that we want to apply the network policy.
        matchLabels:
        app: db
    policyTypes:
    - Ingress # We want to apply the network policy for the incoming traffic.
    - Egress # We want to apply the network policy for the outgoing traffic.
    ingress:
    - from: # Every from field is a rule. And they will be applied like an OR operation.
      - podSelector: # pod selector and namespace selector works like an AND operation. But if we add the namespace selector separately, it works like an OR operation.
          matchLabels:
            app: web
        namespaceSelector:
          matchLabels:
            name: my-namespace
      - ipBlock: # This block works like an OR operation with the pod selector and namespace selector.
          cidr: 10.456.0.0/16 # We can use the cidr field for the IP addresses.
          except: # We can use the except field for the exceptions.
        ports: # This is the port that we want to allow the incoming traffic for the given ip addresses.
        - protocol: TCP
          port: 3307
      ports: # This is the port that we want to allow the incoming traffic for the given pods.
        - protocol: TCP
          port: 3306
    
    egress:
    - to:
      - ipBlock:
          cidr: 192.168.0.0/16
      ports:
      - protocol: TCP
        port: 80
```

## Lab Answer
Db will get request from two different pod definition from the different ports.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-network-policy
spec:
    podSelector:
        matchLabels:
        app: db
    policyTypes:
    - Egress    
    egress:
    - to:
      - podSelector:
          matchLabels:
            app: backup
        ports:
        - protocol: TCP
          port: 3306
    - to:
      - podSelector:
          matchLabels:
            app: web
        ports:
        - protocol: TCP
          port: 3307
```