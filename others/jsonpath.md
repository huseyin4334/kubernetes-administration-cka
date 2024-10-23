# Kubernetes JsonPath Usage
- [JsonPath](https://kubernetes.io/docs/reference/kubectl/jsonpath/) is a query language for JSON objects. It is mainly used to filter and format the output of kubectl commands.

- JsonPath is a way to extract data from a JSON object. It is similar to XPath for XML documents.

Normally, every kubectl command get a json object from the api server and then format it to a human-readable format. 
JsonPath is used to format the output of kubectl commands.

For usage, we should get the json object for output of a kubectl command. 
```bash
kubectl get pods -o json

# get pod names from the json object
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
```

So for usage of the jsonpath, we should know the structure of the json object.


We can get multiple objects in single command.

```bash
kubectl get pods -o jsonpath='{.items[*].metadata.name} {"\n"} {.items[*].status.phase}'

# pod01   pod02
# Running Running


kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# pod01   Running
# pod02   Running


kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# NAME   STATUS
# pod01  Running
# pod02  Running


kubectl get pods --sort-by=.metadata.creationTimestamp -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# NAME   STATUS
# pod01  Running
# pod02  Running

kubectl get pv --sort-by=.spec.capacity.storage -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage > /opt/outputs/pv-and-capacity-sorted.txt


kubectl config view --kubeconfig=my-kube-config -o jsonpath="{.contexts[?(@.context.user=='aws-user')].name}" > /opt/outputs/aws-context-name
```

---

```bash
alias k=kubectl
complete -F __start_kubectl k
```

