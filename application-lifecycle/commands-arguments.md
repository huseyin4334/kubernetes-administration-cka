# Commands
- For example, we run an ubuntu container and run a command in it:

```bash
docker run ubuntu
```

- We will see the container is exited. Because the command is executed and the container is exited.

- Containers are designed to run commands and exit. Because of that, a container can live if it has a process that is running.

---

CMD and ENTRYPOINT are used to run a command when the container is started.
- CMD is used to run a command when the container is started.
- ENTRYPOINT is used to run a command when the container is started. But we can override the ENTRYPOINT command with the CMD command.

---

In the images, if we don't have CMD command, image works CMD ["bash"] command by default. 
This command is try to find a bash shell and run it. 
If we don't have a bash shell in the image, the container will be exited.

But we can override the CMD command with the docker run command.

```bash
# wait 5 seconds and exit
docker run ubuntu sleep 5
```


## CMD
- CMD is used to run a command when the container is started.
- CMD can write in 3 different ways:
  - CMD ["executable","param1","param2"] (exec form)
  - CMD command param1 param2 (shell form)
  - CMD ["param1","param2"] (entrypoint form)
  - docker run <image> <command> <param1> <param2> (override form)

## ENTRYPOINT
- ENTRYPOINT is used to run a command when the container is started.
- ENTRYPOINT is used for the just set parameters from the command line.
- ENTRYPOINT can write in 2 different ways:
  - ENTRYPOINT ["executable"] (exec form)
  - docker run <image> <param1> <param2> (override form)
- But don't forget, if we don't give a parameter, we will get a missing parameter error.

---

```dockerfile
FROM ubuntu
ENTRYPOINT ["sleep"]
```

```bash
docker built -t myimage .
docker run myimage 5

# This will get a missing parameter error
docker run myimage
```

---

```dockerfile
FROM ubuntu
ENTRYPOINT ["sleep"]
CMD ["5"]
```

```bash
docker built -t myimage .
docker run myimage 25

# This will run the sleep 5 command
docker run myimage
```


# Arguments
- We can set arguments in yaml files for the containers.
- We have some definitions for the arguments in yaml files:
  - args: ["param1","param2"] (entrypoint form)
  - command: ["executable","param1","param2"] (exec form)
  - command:
    - executable
    - param1
    - param2 (shell form)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      command: ["sleep"] # This is the ENTRYPOINT command
      args: ["5"] # This is the CMD command
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      command: ["sleep","5"] # This is the ENTRYPOINT command
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: ubuntu
      command:
      - sleep # This is the ENTRYPOINT command
      - "5" # This is the CMD command
```

# Example
```dockerfile
FROM ubuntu

ENTRYPOINT ["sleep"]
CMD ["5"]
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
      image: myimage
      command:
        - sleep
        - "10"
```

```bash
kubectl replace --force -f pod.yaml
```

---

```bash
kubectl run ubuntu --image=ubuntu --command -- sleep 5
```