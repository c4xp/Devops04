---
currentMenu: manualdeploy
layout: default
title: Devops04
subTitle: Manual Deploy
---

# Manual Deploy

![Manual Deploy](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/manual-deploy.png)

## Clone the project locally

We assume that the [Prerequisites](https://gist.github.com/c4xp/fba7a3f83193d23553ce37aac2588c6d) are already met

```
cd /workspace
git clone https://github.com/c4xp/Devops04
cd Devops04
```

And then we can start building our container

## Building the image

Building the image can be as simple as `docker-compose build` but we can also specify the tag
inside the docker-compose.yml file `image: myapp:v1.0`

```
docker-compose build
```

And then we bring up the container (Hint: `docker-compose up -d` sends it to the background)

```
docker-compose up
```

And now when we visit https://localhost/

```
curl http://localhost
```

We should see `Hello World`

Some useful commands:

```
docker exec -it myapp /bin/sh
export
echo "Ctrl + D = exit"
```

## Pushing the image to our Registry

```
docker images
docker images <myapp>
docker tag <a0b1c2d3f4> <my-user>/myapp:latest
docker push <my-user>/myapp:latest
```

## Kubectl and Local cluster initialization

![Enable Local Kubernetes](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/enable-k8s.png)

Checking the Enable Kubernetes box and then pressing Apply & Restart triggers the installation of a single-node Kubernetes cluster. This is all a developer needs to do.

Let's make sure that we have a `docker-desktop` cluster available in out config file

```
type C:\Users\$ENV:USERNAME\.kube\config
```

And that we have the kubectl client

```
kubectl version --client
```

## Imperative vs Declarative

`Imperative programming` is a paradigm that describes computation in terms of statements that describe How To change the system state (programming commands or mathematical assertions).

```
kubectl config view
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <my-cluster>
kubectl config set-context --current --namespace=<my-namespace>
```

Get commands with basic output

```
kubectl get nodes
kubectl get services
kubectl get pods --all-namespaces
kubectl get pods -o wide
kubectl get deployment <my-deployment>
kubectl get pods
kubectl get pod <my-pod> -o yaml
```

## Declarative and Infrastructure as Code

`Declarative programming` is a programming paradigm that expresses the logic of a computation (What do) without describing its control flow (How do).

We use Declarative programming when we want Repeatability, Consistency,Code Review and Documentation.

Let's use the file `tutorial.yml`

```
---
apiVersion: v1
kind: Service
spec:
  ...
  type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
spec:
  ...
  template:
    ...
    spec:
      containers:
      - image: monachus/rancher-demo:latest
      ...
```

and deploy it to our local cluster

```
kubectl apply -f tutorial.yml
kubectl get svc
```

and then we can delete everything

```
kubectl delete -f tutorial.yml
```

![Questions](https://raw.githubusercontent.com/c4xp/Devops01/master/assets/questions.png)

[Kubernetes Overview→](kubernetes.md)