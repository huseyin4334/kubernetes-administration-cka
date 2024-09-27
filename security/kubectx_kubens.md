# Kubectx And Kubens
- Kubectx is a utility to manage and switch between kubectl contexts
- Kubens is a utility to manage and switch between kubectl namespaces

- Install Kubectx And Kubens
```bash
git clone https://https://github.com/ahmetb/kubectx /opt/kubectx

# sudo ln -s is used to create a symbolic link.
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx

sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

kubectx --help

# list the contexts
kubectx

# switch the context
kubectx <context-name>

# get back to the previous context
kubectx -

# Current context
kubectx -c

# list the namespaces
kubens

# switch the namespace
kubens <namespace-name>

# get back to the previous namespace
kubens -

# Current namespace
kubens -c
```