# How is Working Docker Network
Docker is isolated system in host machine. It works in host directly. (Not in network namespace)

We can run a container with 3 different network mode. (Host ip is `192.168.1.10`, ethernet interface is `eth0`)
- docker run --network none nginx
  - In this way container does not connect any network
  - Because of this, container can not reachable from outside.
- docker run --network host nginx
  - In this way container uses host network.
  - Container can reachable from outside with host ip.
  - Container can not use same port with other any container.
- docker run nginx
  - In this way container uses bridge network. (default network mode)
  - Docker have a default network interface host machine. It is called docker0. It is a bridge interface.
    - Docker creates it with `ip link add name docker0 type bridge` command.
    - After create bridge interface, it will assign an ip address to this interface with `ip addr add 172.17.0.1/24 dev docker0` command.
    - When we execute `ip link` command, we can see this interface. But it is not up.
    - But when we execute `ip addr` command we can see this interface with ip address. (`172.17.0.1/24` (it's internal ip address in host machine))
    - When we execute `ip netns` command, we will see a network namespaces. We will see a network namespace for each container.
    - For this example, let's assume we see a network namespace with id `b3165c10a92b`.
      - It's created by docker. It's a network namespace for container.
    - When we execute `docker inspect 942d70e585b2` command, we will see a network namespace id. (It's `b3165c10a92b....` in SandboxID field)
      - 942d70e585b2 is container id.
    - But how this network namespace connected to bridge interface?
      - Docker creates a veth pair. One end of the veth pair is in the container and the other end is in the host machine.
      - When we execute `ip link` command, we will see a veth pair. (It's name is `vethb3165c10a92b@if7`)
      - This is the connected network interface to the bridge interface in host machine.
      - For see the other part of the veth we should execute `ip -n b3165c10a92b.... link` command.
        - We will see a network interface with name `eth0@if8` in the network namespace.
        - This is the connected network interface to the container.
      - When we execute `ip -n b3165c10a92b.... addr` command, we will see the ip address of the container. (`172.17.0.3/16`)
      - Then, container take a ip address from the bridge interface.
    - Container opened a port with `80` in this example. (We can see this with `docker ps` command)
      - When we execute `curl http://172.17.0.3:80` command inside the docker host, we can see the nginx welcome page.
      - But we are not on it. We are in the host machine.
    - But how will be reachable this port from outside?
      - `docker run -p 8080:80 nginx`
      - We did reachable the port `80` from outside with port `8080`.
      - docker execute `iptables -t nat -A DOCKER -j DNAT --dport 8080 --to-destination 172.17.0.3:80` command.
        - Docker add this rule for itself.
        - When any packet come to port `8080`, it will redirect to port `80` in the container.
      - `iptables -t nat -A PREROUTING -j DNAT --dport 8080 --to-destination 80` command.
        - Docker add this rule for host machine.
        - When any packet come to port `8080`, it will redirect to port `80` in the container.
      - We can see the rule with `iptables -nvL -t nat` command.
        - target     prot opt source               destination         
          DNAT       tcp  --  anywhere             anywhere             tcp dpt:8080 to:172.17.0.3.80