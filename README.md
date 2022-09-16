# Devops04 - Jenkins and Kubernetes

## Introduction

[English](/README.md) | [Romana](/README-ro.md)

## What we cover

- Docker build
- Simple Kubectl Deploy
- Jenkins Deploy

## System Requirement

System Requirement to install this repository are as following：

| Conditions | Details | Notes |
| :--- | :---: | --- |
| Operating System | Windows Pro, CentOS7.x, Ubuntu20.04 | Docker Desktop [see-Devops01](https://github.com/c4xp/Devops01) |
| Cloud | Azure, Aws, Bare-metal, Rancher, VirtualBox | Kubernetes cluster |
| Machine Configuration | vCPU no less than 2 core, Memory no less than 4 GIB, Storage no less than 20 GB, Swap no less than 2GB |Bandwidth no less than 100M |

## Ecosystem

Core components of this repository: Jenkins, Docker, Rancher

## Installation on Synology

### Step 1: Prepare Synology

The first thing to do is to enable SSH login on Diskstation. To do this, go to the “Control Panel” > “Terminal”

![Synology-ssh](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/synology01-ssh.png)

After that you can log in via “SSH”, the specified port and the administrator password (Windows users take [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) or [XShell](https://www.netsarang.com/en/xshell/) or [mRemoteNG](https://mremoteng.org/)).

I log in via Terminal, winSCP or Putty and leave this console open for later.
Optionally you can login directly with Windows OpenSSH client: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui

```
The authenticity of host '[synology.local](0.0.0.0)' can't be established.
ECDSA key fingerprint is SHA256:1234567890abcdef1234567890abcdef1234567890a.
Are you sure you want to continue connecting (yes/no)? yes
user@synology.local's password: ********
user@synology.local:~$
```

### Step 2: Prepare Docker folder

I create a new directory called “jenkins” in the Docker directory, as well a a “docker-compose.yml” file.

```
mkdir -p /volume1/docker/jenkins/
cd /volume1/docker/jenkins
touch docker-compose.yml
mkdir -p data
```

Docker Compose file contains:
```
version: '2.0'
services:
  jenkins:
    restart: always
    image: jenkins/jenkins:lts
    privileged: true
    user: root
    ports:
      - 8081:8080
    container_name: jenkins
    volumes:
      - ./data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/local/bin/docker:/usr/local/bin/docker
```

### Step 3: Start

I can also make good use of the console in this step. I start the Jenkins server via Docker Compose. 

```
sudo docker-compose up -d
```

After that I can call my Jenkins server with the IP of the diskstation and the assigned port from “Step 2”. 

![Jenkins-login](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-login.png)

![Questions](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/questions.png)

[Git→](gitutil.md)