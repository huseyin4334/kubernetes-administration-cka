# Monitoring
- Kubernetes don't have built-in monitoring solution, but it provides the necessary tools to integrate with monitoring solutions.
- Monitoring is essential to ensure the health of the cluster and the applications running on it.
- Some of them:
  - Prometheus
  - Alertmanager
  - Thanos
  - Kube-state-metrics
  - Node-exporter
  - cAdvisor
  - Elastic Stack
  - Dynatrace
  - Datadog
  - Metric Server

---

Heapster is deprecated. It is replaced by the `metrics-server`. Metric server is lightweight and provides only CPU and memory usage.

Kubelet have api for metrics. Kubelet collects the metrics via cAdvisor and exposes them via the metrics API.
cAdvisor is an open-source container resource usage and performance analysis agent. It's responsible for collecting, aggregating, processing, and exporting information about running containers.
Metric server collects metrics from the Kubelet API and stores them in memory.

## Metrics Server Installation

```bash
git clone https://github.com/kubernetes-incubator/metrics-server.git

cd metrics-server

# This will install the metrics server in the `kube-system` namespace.
kubectl apply -f deploy/1.8+/
```

## Commands

```bash
kubectl top nodes

kubectl top pods
```


# Logging
- Logging is essential to understand what is happening in the cluster.

---

Kubernetes doesn't have built-in logging solution, but it provides the necessary tools to integrate with logging solutions.
Some of them:
  - Elasticsearch
  - Fluentd
  - Kibana
  - Loki
  - Grafana
  - Splunk
  - Sumo Logic
  - Datadog
  - LogDNA
  - Loggly
  - Stackdriver
  - Papertrail

---

Some commands:

```bash
kubectl logs <pod-name>

kubectl logs -f <pod-name> # Follow the logs

kubectl logs -f -l app=nginx # Follow the logs of all pods with the label app=nginx

kubectl logs -f -l app=nginx --tail=10 # Follow the logs of all pods with the label app=nginx and show only the last 10 lines

kubectl logs -f -l app=nginx --since=1h # Follow the logs of all pods with the label app=nginx and show only the logs since the last hour

kubectl logs deployment/nginx-deployment # Follow the logs of all pods in the deployment
```





