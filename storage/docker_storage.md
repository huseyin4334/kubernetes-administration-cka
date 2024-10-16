# Docker Storage Management
When we setup docker in the host machine, docker create directory `/var/lib/docker` to store all the images, containers, volumes, and networks. 
This directory is called docker root directory. Docker root directory is the default storage location for all the docker objects.
- aufs
- containers
- image
- volumes
- ...

## Layered Architecture
Docker uses a layered architecture to store the images. 

```dockerfile
FROM ubuntu:18.04
RUN apt-get update && apt-get install -y apache2
RUN pip install flask flask-mysql

copy . /opt/source-code
entrypoint FLASK_APP=/opt/source-code/app.py flask run
```

```bash
docker build -t myapp .
```

When we build an image, docker creates a layer for each instruction in the Dockerfile.

- Layer 1: ubuntu:18.04 ----> 120MB
- Layer 2: apt-get update && apt-get install -y apache2 ---> 306MB
- Layer 3: pip install flask flask-mysql ---> 10MB
- Layer 4: copy . /opt/source-code ---> 10MB
- Layer 5: entrypoint FLASK_APP=/opt/source-code/app.py flask run ---> 0B

Every layer is read-only layer. Because of that, docker just store the changes in the new layer to previous layer.
For example, layer 4 executed in layer of the layer 3 (but not effected layer 3). And it saved the changes in the layer 4. Because of that this layer don't have cumulative size of the previous layers.

```dockerfile
FROM ubuntu:18.04
RUN apt-get update && apt-get install -y apache2
RUN pip install flask flask-mysql

copy ./app2.py /opt/source-code
entrypoint FLASK_APP=/opt/source-code/app.py flask run
```

```bash
docker build -t myapp2 .
```

- Layer 1: ubuntu:18.04 ----> 0MB
- Layer 2: apt-get update && apt-get install -y apache2 ---> 0MB
- Layer 3: pip install flask flask-mysql ---> 0MB
- Layer 4: copy . /opt/source-code ---> 229B
- Layer 5: entrypoint FLASK_APP=/opt/source-code/app.py flask run ---> 0MB

Docker controlled every previous layer in the current layer. Layer 1,2,3 layers already worked for the another image. So docker can get the layer from the cache.
But layer 4 different didn't work before. So docker create a new layer for this instruction.
Layer 5 also didn't work before. Then it will be new layer too.


---

Our said all image layers are read-only. And Names are IMAGE LAYERS.

```bash
docker run -it myapp
```

When we run the container, docker create a new layer for the container. This layer is called CONTAINER LAYER. This layer is read-write layer.
When the container is running, all the changes are saved in this layer. Image layer is read-only and shared between the other containers.
When I change anything in the container that came from image layers, docker will create a copy file in the container layer. And it will be used in the container when the container is running.

---

## Volumes
Then we changed something, but they will be gone when the container is stopped. Because container layer is read-write layer. And it will be deleted when the container is stopped.

When we create a volume docker save the data in the `/var/lib/docker/volumes` directory.

We have some ways to create a volume.
- Bind Mounts
  - docker run -v /host/path:/container/path
    - It will be stored in the `/host/path`
- Named Volumes
  - docker run -v myvolume:/container/path
  - It will be stored in the `/var/lib/docker/volumes/myvolume`
- Anonymous Volumes
  - docker run -v /container/path
  - It will be stored in the `/var/lib/docker/volumes/` directory. 
  - And it will be deleted when the container is stopped.
  - Because it doesn't have a name.
- Mount flag
  - docker run --mount type=bind,source=/host/path,target=/container/path
  - docker run --mount type=volume,source=myvolume,target=/container/path
  - This way recommended by the docker. Because it is more readable.


## Storage Drivers
Docker uses storage drivers to manage the storage. Storage drivers are responsible for managing the storage of the images, containers, and volumes.
These drivers manage all discussed above.

[Storage Drivers](https://docs.docker.com/engine/storage/drivers/)


## Volume Drivers
Volume drivers are responsible for managing the volumes. Docker has some built-in volume drivers.
Default is Local volume driver. But we can use other volume drivers like Azure File Storage, Convoy, Flocker, etc.
We can set the volume driver when we create a volume.

```bash
docker volume create --name myvolume 
--volume-driver rexray/ebs
--mount type=volume,source=myvolume,target=/container/path
```

# Container Storage Interface (CSI)
We spoke about CRI (Container Runtime Interface) before. It is a standard interface for container runtimes.
We will spoke about CNI (Container Network Interface) later. It is a standard interface for container networking.
Then we can understand that kubernetes has a standard interface for manage some things.

Container Storage Interface (CSI) is a standard interface for container storage. It is a standard interface for container orchestration systems to manage the storage of the containers.

It's communicating with RPC (Remote Procedure Call) between the container orchestration system and the storage driver.









