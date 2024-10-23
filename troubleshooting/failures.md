# Application Failure
Check accessibility
```bash
curl http://<webservice_ip>:nodeport
```

Check the service matching the selectors.

Check the pod logs.
--previous gives the logs of the previous pod. (previous pod is the pod that was running before the current pod)

```bash
kubectl logs web -f --previous
```


# Control-plane Failure
Check the services
```bash
service kube-apiserver status
#...
```

Check the logs
```bash
kubectl logs kube-api-server-master -n kube-system
```

Also, you can use `journalctl`

```bash
sudo journalctl -u kube-apiserver
```


# Worker Node Failure
Check the node status
```bash
kubectl get nodes
```

Check the containerd status
```bash
sudo systemctl status containerd
```

Check the kubelet
```bash
sudo systemctl status kubelet
```

Start the kubelet
```bash
service kubelet start
```

Check the kubelet configuration
```bash
cat /var/lib/kubelet/config.yaml
```

Check the kubelet kubernetes connection configuration
```bash
cat /etc/kubernetes/kubelet.conf
```