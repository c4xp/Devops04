---
currentMenu: deployment
layout: default
title: Devops04
subTitle: Deployment
---

# Deployment

Let's recap a bit, before we make our own deployment.

We need to be in our local cluster:
```
kubectl config get-contexts
kubectl config use-context docker-desktop
kubectl get ns
echo 'if the namespace does not exist, create it'
kubectl create namespace myapp-namespace
```

A good practice is to always set your namespace (disaster prevention when altering something you did not want)
```
kubectl config set-context --current --namespace=myapp-namespace
```

Alternatively a one liner:
```
kubectl config set-context docker-desktop --namespace=myapp-namespace
```

# Creating a deployment

A Deployment provides declarative updates for Pods and ReplicaSets.

You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
  spec:
    containers:
      - name: my-k8s-app
        image: c4xp/myapp:latest
        ports:
          - containerPort: 8080
            protocol: TCP
```

```
echo 'show secrets held in secrets-store'
kubectl exec <podname> -- ls /mnt/secrets-store/
echo 'print the environment variables
kubectl exec <podname> -- export
echo 'or just enter in it'
kubectl exec -it <podname> -- /bin/sh
```

## Updating the image

```
kubectl set image deployment/myapp-deployment my-k8s-app=c4xp/myapp:v1.0
```

```
kubectl rollout status deployment/myapp-deployment
```

## Cleanup

Now you can clean up the resources you created in your cluster:

```
kubectl delete service mysql
kubectl delete deployment myapp-mysql-deployment
```

or just delete them all:

```
kubectl delete -f .\kube\
```

[Reference: Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

![Questions](https://raw.githubusercontent.com/c4xp/Devops01/master/assets/questions.png)

[Manual→](manual.md)