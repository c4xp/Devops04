---
currentMenu: automatic deployment
layout: default
title: Devops04
subTitle: Automatic Deployment
---

# Automatic Deployment using Jenkins

Jenkins is a powerful application that allows continuous integration and continuous delivery of projects, regardless of the platform you are working on.

The freestyle build job is a highly flexible and easy-to-use option. You can use it for any type of project; it is easy to set up, and many of its options appear in other build jobs

![New Freestyle Job](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-new.png)

## Job Details

Under Source Code Management, Enter your repository URL. Current test repository located at `git@github.com:c4xp/Devops04.git`

![Jenkins SCM](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-scm.png)

## Build Environment

Now that you have provided all the details, it’s time to build the docker image
We will use a simple environment variable for our major Version number.

![Build Environment](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-buildenv.png)

And then we will use it in our Build and Push steps

![Build Steps](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-buildsteps.png)

## Finishing the Upload to the Container Registry

We need to modify the version being downloaded from DockerHub to what the Jenkins Job just made

```
#!/bin/bash
cd ${WORKSPACE}/kube
sed -i -e "s~.*image: c4xp\/myapp:.*~        image\: c4xp/myapp\:${VERSION}.${BUILD_NUMBER}~" 06.deployment.yml
#cat 06.deployment.yml
kubectl config use-context <ourcluster>
kubectl config set-context <ourcluster> --namespace=myapp-namespace
echo "Starting Kubernetes deployment"
#kubectl apply -f 06.deployment.yml
```

## A new type of Ingress

A new volume claim in our live cluster

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  # wsl --distribution docker-desktop
  name: myapp-pvc
spec:
  # if we do not specify a volume, one will be created automatically
  #volumeName: myapp-volume
  storageClassName: nfs-client
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

Of course our live cluster is different than our Docker-Desktop instance

```
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: myapp-namespace
  labels:
    app: myapp-tutorial
spec:
  type: ClusterIP
  ports:
  - name: myapp-port
    port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: myapp-tutorial
    tier: app
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: myapp-namespace
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: myapp.10.20.30.1.sslip.io
    http:
      paths:
      - backend:
          serviceName: myapp-service
          servicePort: 80
        path: /
  tls:
  - hosts:
    - myapp.10.20.30.1.sslip.io
    # openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout myapp-cert-tls.key -out myapp-cert-tls.crt -subj "/CN=sslip.io" -addext "subjectAltName=DNS:sslip.io"
    # kubectl create secret tls myapp-cert-tls --key myapp-cert-tls.key --cert myapp-cert-tls.crt
    secretName: myapp-cert-tls
```

Be mindful of the Warning:
```
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
```

**That's why changing kubernetes version has an impact.**

Let's not forget we need a TLS secret myapp-cert-tls to store our website certificate

```
notepad++ C:\Users\$ENV:USERNAME\.kube\config
kubectl config use-context <ourcluster>
kubectl config set-context <ourcluster> --namespace=myapp-namespace
```

And we upload the certificate

```
kubectl create secret tls myapp-cert-tls --key myapp-cert-tls.key --cert myapp-cert-tls.crt
```

![Questions](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/questions.png)

[Bonus→](bonus.md)