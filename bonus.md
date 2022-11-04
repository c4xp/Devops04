---
currentMenu: bonus
layout: default
title: Devops04
subTitle: Bonus Section
---

# Recap

![LoadBalancer](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/loadbalancer.png)

we've worked with the basic building blocks of stateless apps on Kubernetes: Deployments, ReplicaSets, Pods, Services. There are alternatives to Deployments (not all apps support rolling updates): StatefulSets, DaemonSets, Jobs, CronJobs, etc. ConfigMaps and Secrets are useful to store application configuration. Also, we’ve only used Deployments in the most basic manner. In production, you should set CPU and memory requests and limits, and you may be interested in autoscaling, among other things.

# Rancher Orchestrator

Rancher is a Kubernetes management tool to deploy and run clusters anywhere and on any provider.

Rancher can provision Kubernetes from a hosted provider, provision compute nodes and then install Kubernetes onto them, or import existing Kubernetes clusters running anywhere.

![Rancher](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/rancher.png)

![Questions](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/questions.png)

[Back](manual.md)