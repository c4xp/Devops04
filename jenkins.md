---
currentMenu: automatic deployment
layout: default
title: Devops04
subTitle: Automatic Deployment
---

# Automatic Deployment using Jenkins

Jenkins is a powerful application that allows continuous integration and continuous delivery of projects, regardless of the platform you are working on.

The freestyle build job is a highly flexible and easy-to-use option. You can use it for any type of project; it is easy to set up, and many of its options appear in other build jobs

![New Freestyle Job](https://raw.githubusercontent.com/c4xp/Devops01/master/assets/jenkins-new.png)

## Job Details

Under Source Code Management, Enter your repository URL. Current test repository located at `git@github.com:c4xp/Devops04.git`

![Jenkins SCM](https://raw.githubusercontent.com/c4xp/Devops01/master/assets/jenkins-scm.png)

## Build Environment

Now that you have provided all the details, it’s time to build the docker image
We will use a simple environment variable for our major Version number.

![Build Environment](https://raw.githubusercontent.com/c4xp/Devops01/master/assets/jenkins-buildenv.png)

And then we will use it in our Build and Push steps

![Build Steps](https://raw.githubusercontent.com/c4xp/Devops01/master/assets/jenkins-buildsteps.png)

## Finishing the Upload to the Container Registry

```
#!/bin/bash
cd ${WORKSPACE}/kube
cat 06.deployment.yml
kubectl config use-context local
kubectl config set-context local --namespace=myapp-namespace
echo "Starting Kubernetes deployment"
#kubectl apply -f 06.deployment.yml
```

![Questions](https://raw.githubusercontent.com/c4xp/Devops01/master/assets/questions.png)

[Bonus→](bonus.md)