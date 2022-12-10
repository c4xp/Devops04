---
currentMenu: reset-cluster
layout: default
title: Devops04
subTitle: Reset Cluster
---

## How to reset cluster

On the node host machine.

First we stop all docker containers

```
docker stop $(docker ps -aq) && docker system prune -f && docker volume rm $(docker volume ls -q) && docker image rm $(docker image ls -q)
```

Then we unmount all volumes
```
if sudo mount | grep /var/lib/kubelet/pods; then sudo umount $(sudo mount | grep /var/lib/kubelet/pods | awk '{print $3}'); fi
```

And stop the services
```
systemctl stop kubelet docker
```

Remove any files remaining
```
rm -rf /etc/ceph /etc/cni /etc/kubernetes /opt/cni /opt/rke /run/secrets/kubernetes.io /run/calico /run/flannel /var/lib/docker/* /var/lib/calico /var/lib/etcd/* /var/lib/cni /var/lib/kubelet/* /var/lib/rancher/* /var/log/containers /var/log/pods /var/run/calico
```

We start docker back up
```
mkdir -p /var/lib/kubelet/pods
systemctl start kubelet docker
```
