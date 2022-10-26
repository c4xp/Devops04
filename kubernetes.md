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

## Kubernetes Service Types Overview

In Kubernetes, an Ingress is an object that allows access to your Kubernetes services from outside the Kubernetes cluster.
These options all do the same thing. They let you expose a service to external network requests.

| Type | LoadBalancer | Notes |
| :--- | --- | :--: |
| ClusterIP | ![ClusterIP](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/clusterip.png) | Can only be reached from within the Kubernetes cluster. |
| NodePort | ![NodePort](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/nodeport.png) | Kubernetes will allocate a specific port on each Node to that service, and any request to your cluster on that port gets forwarded to the service. |
| LoadBalancer | ![LoadBalancer](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/loadbalancer.png) | There needs to be some external load balancer functionality in the cluster, typically implemented by a cloud provider. |
| Ingress | ![Ingress](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/ingress.png) | Ingress is a completely independent resource to your service. You declare, create and destroy it separately to your services. This makes it decoupled and isolated from the services you want to expose. It also helps you to consolidate routing rules into one place. |

<!---
https://qiita.com/yosshi_/items/2db0a0e66a16711bfe5f
-->

### 1. ClusterIP

![ClusterIP](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/clusterip.png)

ClusterIP is the default and most common service type.
Kubernetes will assign a cluster-internal IP address to ClusterIP service. This makes the service only reachable within the cluster.

#### **USE CASE**
Inter service communication within the cluster.

Example
```
apiVersion: v1
kind: Service
metadata:
  name: my-backend-service
  namespace: default
  labels:
    app: tutorial
spec:
  # Optional field (default)
  type: ClusterIP
  # within service cluster ip range
  clusterIP: 10.10.0.1
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
```

### 2. NodePort

![NodePort](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/nodeport.png)

NodePort service is an extension of ClusterIP service.
It exposes the service outside of the cluster by adding a cluster-wide port on top of ClusterIP.

#### **USE CASE**
When you want to enable external connectivity to your service.
Freedom to set up your own load balancing solution.

Example
```
apiVersion: v1
kind: Service
metadata:
  name: my-database
  namespace: default
  labels:
    app: tutorial
spec:
  type: NodePort
  ports:
    # Inside the cluster, what port does the service expose?
    - port: 3306
      protocol: TCP
      # Which external port will be available on the node?
      nodePort: 30336
      # Optional: Which targetPort do pods selected by this service expose?
  selector:
    app: tutorial
    tier: database
```

### 3. LoadBalancer

![LoadBalancer](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/loadbalancer.png)

LoadBalancer service is an extension of NodePort service. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.

#### **USE CASE**
When you are using a cloud provider to host your Kubernetes cluster.

Example
```
apiVersion: v1
kind: Service
metadata:
  name: my-frontend-service
  namespace: default
spec:
  type: LoadBalancer
  clusterIP: 10.0.171.123
  loadBalancerIP: 123.123.123.123
  selector:
    app: tutorial
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
```

### 4. Ingress

![Ingress](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/ingress.png)

Ingress is not actually a Service type, but it acts as the entry point for your cluster. It lets you consolidate your routing rules into a single resource as it can expose multiple services under the same IP address.

Example
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: default
  labels:
    app: tutorial
spec:
  ports:
    - port: 80
  selector:
    app: tutorial
    tier: app
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: mktcom-ingress
  namespace: default
spec:
  rules:
    - host: www.pentalog.com
      http:
        paths:
        - backend:
            serviceName: mktcom-service
            servicePort: 80
          path: /
    - host: pentalog.com
      http:
        paths:
        - backend:
            serviceName: mktcom-service
            servicePort: 80
          path: /
  tls:
  - hosts:
    - www.pentalog.com
    secretName: pentalogcom
```

## Deployment



## ConfigMaps

## Secrets

## Persistent Volumes and Claims

```
kubectl get storageclass # or sc
kubectl describe storageclass <my-storage>
```