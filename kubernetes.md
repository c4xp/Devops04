---
currentMenu: kubernetes
layout: default
title: Devops04
subTitle: Kubernetes Overview
---

# Kubernetes Overview

## Namespaces

In Kubernetes, namespaces provides a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces. 

```
kubectl create namespace my-namespace
kubectl get namespace # or ns
```

## Ingress vs LoadBalancer vs NodePort

In Kubernetes, an Ingress is an object that allows access to your Kubernetes services from outside the Kubernetes cluster.
These options all do the same thing. They let you expose a service to external network requests.

| Type | LoadBalancer | Notes |
| :--- | --- | :--: |
| NodePort | ![NodePort](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/nodeport.png) | Kubernetes will allocate a specific port on each Node to that service, and any request to your cluster on that port gets forwarded to the service. |
| LoadBalancer | ![LoadBalancer](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/loadbalancer.png) | There needs to be some external load balancer functionality in the cluster, typically implemented by a cloud provider. |
| Ingress | ![Ingress](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/ingress.png) | Ingress is a completely independent resource to your service. You declare, create and destroy it separately to your services. This makes it decoupled and isolated from the services you want to expose. It also helps you to consolidate routing rules into one place. |

<!---
https://qiita.com/yosshi_/items/2db0a0e66a16711bfe5f
-->

## Service

## Deployment
nodes
pods
service

## ConfigMaps

## Secrets

## Persistent Volumes and Claims

```
kubectl get storageclass # or sc
kubectl describe storageclass <my-storage>
```