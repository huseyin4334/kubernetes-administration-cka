# Imperative vs Declarative Programming
- **Imperative Programming** is a programming paradigm that uses statements that change a program's state. In imperative programming, the focus is on describing how a program operates.
- **Declarative Programming** is a programming paradigm that expresses the logic of a computation without describing its control flow. In declarative programming, the focus is on describing what a program should accomplish.

## Imperative Usage In Kubernetes
- **Imperative Usage** is a way to interact with Kubernetes by providing a sequence of commands to perform a task. It is a direct way to interact with the Kubernetes API.
- For example, to create a deployment imperatively, you can use the following command:
```bash
  kubectl create deployment my-deployment --image=nginx
  kubectl run my-deployment --image=nginx
  kubectl expose deployment my-deployment --port=80 --type=NodePort
  kubectl set image deployment my-deployment nginx=nginx:1.19
  kubectl replace --force -f deployment.yaml
  kubectl delete deployment my-deployment
  kubectl replace -f deployment.yaml  
```

- When we create a deploy, if we run the same command again, we will get error.



## Declarative Usage In Kubernetes
- **Declarative Usage** is a way to interact with Kubernetes by providing a configuration file that describes the desired state of the system. It is a more abstract way to interact with the Kubernetes API.
- For example, to create a deployment declaratively, you can use the following command:
```bash
  kubectl apply -f deployment.yaml
```
- We did create, update, and delete operations declaratively using the same file and command. We don't specify how to do it.

## Conclusion
> We can use --dry-run=client for the get yaml file.
> https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands


## Apply Command
- The `kubectl apply` command is used to apply a configuration to a resource by filename or stdin. This command is used to create and update resources in a declarative way.
- Kubernetes store all objects with a live object configuration.
- When we execute it;
  - Kubernetes add the last applied configuration to live object configuration.
  - This object type is json.
  - When we run the apply command, it compares the last applied configuration with new given configuration.
  - If there is a difference, it updates the live object configuration and last applied configuration.

- For example, to live object configuration;

``` yaml
apiVersion: apps/v1
kind: Pod
metadata:
  name: my-pod
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"my-pod","namespace":"default"},"spec":{"containers":[{"image":"nginx","name":"my-container"}]}}
spec:
    containers:
    - name: my-container
    image: nginx
status:
  lasProbeTime: null
  state: "True"
  type: "Initialized"
```
