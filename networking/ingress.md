# Ingress
Ingress is a Kubernetes resource that allows you to redirect HTTP and HTTPS traffic from the outside of the cluster to the services inside the cluster. 
It is a layer 7 load balancer that can be used to expose multiple services using a single IP address.

For example, you have website `example.com` and you want to expose two services `wear` and `watch` using the same domain name.
And you want to redirect the traffic to `wear` service when the request is for `example.com/wear` or `wear.example.com` and to `watch` service when the request is for `example.com/watch` or `watch.example.com`.

Let's do it without ingress first.

Deploys:
- wear
- watch
Services:
- wear-service (NodePort) (port 38080)
- watch-service (NodePort) (port 38081)

When you want to access to the `wear` service, you need to use `http://<node-ip>:38080` and for the `watch` service, you need to use `http://<node-ip>:38081`.

But the user can not remember ip addresses of the nodes. So we need to use a proxy server to redirect the traffic to the correct service.
Proxy service means that you need to deploy a new service that listens to the requests and redirects them to the correct service.

But this is for on-premise.

When we are in GCP `wear-service` will be load balancer. And GCP will create a gcp load balancer for us like a proxy server.

And the customer will send request to the `http:example.com/wear` and the request will be redirected to the `wear-service` by the GCP load balancer or proxy server.

---

But when our organization grows, we will have more load balancers. This is not a good solution for bill. Because every load balancer will get a new ip and payment.

So we need to use a single load balancer for all services. We need to redirect the system internally.

This is the Ingress.

---

Also, Ingress can be used for SSL termination. You can use SSL certificates for your domain name and Ingress will handle the SSL termination for you.

---

We have a 2 section;
- Deploy a proxy solution for control traffic (Nginx, HAProxy, Traefik, etc.)
  - Ingress Controller
- Configure Ingress


## Ingress Controller
Ingress Controller is a pod that listens the ingress definitions and redirects the traffic to the correct service.
This deploys have a service. When we send a request to the `example.com/wear`, this request will get by ingress controller service.
This request go to ingress controller pod and ingress controller will control the ingress definitions and redirect the request to the correct service.

Let's do it for Nginx.

Let's create a configmap for the Nginx configuration.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: nginx-configuration
data:
    proxy-connect-timeout: "10"
    proxy-read-timeout: "120"
    proxy-send-timeout: "120"
    client-max-body-size: "10m"
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx-ingress-controller
spec:
    replicas: 1
    selector:
        matchLabels:
            name: nginx-ingress
    template:
        metadata:
            labels:
                name: nginx-ingress
        spec:
          containers:
            - name: nginx-container
              image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
              args:
                - /nginx-ingress-controller # /nginx-ingress-controller is used for the running the nginx-ingress-controller
                - --configmap=$(POD_NAMESPACE)/nginx-configuration # nginx-configuration file is a configmap that is used for the configuration of the nginx
              env:
                - name: POD_NAME # POD_NAME will be 
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.name
                - name: POD_NAMESPACE
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.namespace
              ports:
                - name: http
                  containerPort: 80
                - name: https
                  containerPort: 443
```

Nginx and configuration are ready. Now we need to create a service for the Nginx.

```yaml
apiVersion: v1
kind: Service
metadata:
    name: nginx-ingress-service
spec:
    selector:
        name: nginx-ingress # it will select the nginx-ingress pods
    ports:
        - name: http
          port: 80
          targetPort: 80
        - name: https
          port: 443
          targetPort: 443
    type: NodePort
```

Let's create a service account for the controller.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
    name: nginx-ingress-serviceaccount

--- # ClusterRole, Roles, RoleBindings
```

---

We created the Nginx Ingress Controller, Service, and ServiceAccount. Now we need to create an Ingress resource.


## Configure Ingress
We have 2 way for define the Ingress resource.
**Subdomain** and **Path based**.

We have 2 pattern for it by version of Kubernetes.

### Subdomain

In the new versions of Kubernetes; (v1.20+)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
  rules:
    - http:
        paths:
          - path: /wear
            backend:
              service:
                name: wear-service
                port:
                  number: 80
            pathType: Prefix # Prefix or Exact (Prefix example.com/wear, Exact example.com/wear/)
          - path: /watch
            backend:
              service:
                name: watch-service
                port:
                  number: 80
            pathType: Prefix
```

In the old versions of Kubernetes; (v1.19-)

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
    rules:
        - http:
            paths:
              - path: /wear
                backend:
                  serviceName: wear-service
                  servicePort: 80
              - path: /watch
                backend:
                  serviceName: watch-service
                  servicePort: 80
```


### Path based

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
  rules:
    - host: wear.example.com
      http:
        paths:
          - backend:
              service:
                name: wear-service
                port:
                  number: 80
            pathType: Prefix
    - host: watch.example.com
      http:
        paths:
          - backend:
              service:
                name: watch-service
                port:
                  number: 80
            pathType: Prefix
```

### SSL Termination
SSL termination is the process of decrypting the encrypted data before passing it to the application server.
In the Ingress, you can use the `tls` field for SSL termination.


```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
  rules:
    - host: wear.example.com
      http:
        paths:
        - backend:
            service:
              name: wear-service
              port:
                number: 80
          pathType: Prefix
  tls:
    - hosts:
        - wear.example.com
      secretName: wear-tls-secret
```


### Access To The Services In Local Cluster
If you want to access the services in the local cluster, you need to add the following line to the `/etc/hosts` file.

```bash
<node-ip> wear.example.com
<node-ip> watch.example.com
```

```bash
curl wear.example.com
curl watch.example.com
```


# Lab

Default path definition for the Ingress.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      name: nginx-ingress
  template:
    metadata:
      labels:
        name: nginx-ingress
    spec:
      containers:
        - name: nginx-container
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
          args:
            - /nginx-ingress-controller
            - --configmap=$(POD_NAMESPACE)/nginx-configuration
            - --default-http-backend-service=$(POD_NAMESPACE)/default-http-backend
```


Ingress definition works have to be in the same namespace with the services.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
  namespace: app-space
spec:
    rules:
      - http:
          paths:
          - backend:
              service:
                name: wear-service
                port:
                  number: 80
            pathType: Prefix
```

We can look at line in the vim like `:<set number>`.



















