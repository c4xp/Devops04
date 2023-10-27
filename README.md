# Devops04 - Jenkins and Kubernetes

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fc4xp%2FDevops04)](https://hits.seeyoufarm.com)
[![DockerStars](https://img.shields.io/docker/stars/c4xp/myapp.svg?style=flat)](https://img.shields.io/docker/stars/c4xp/myapp)

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

![Synology-diskstation](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/diskstation-ds220j.png)

Installing Docker onto a Synology NAS is the normal click click click sort of workflow.

![Docker-pkg](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/docker-pkg.png)

### Step 1: Prepare Synology

[Synology HDD compatibility](https://www.synology.com/en-global/compatibility)
[How to Install XPEnology](https://www.youtube.com/watch?v=2oEdr5ecXNY)
[Tinycore Redpill](https://github.com/pocopico/tinycore-redpill)

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

![Synology-docker](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/synology-docker.png)

After that I can call my Jenkins server with the IP of the diskstation and the assigned port from “Step 2”. 

![Jenkins-login](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-login.png)

Enter the password that we captured from the file at /var/jenkins_home/secrets/initialAdminPassword after installing Jenkins.

![Jenkins-initial](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-initial.png)

## Plugins

I recommend just installing the recommended plugins first up. You can always add or remove plugins later.

![Jenkins-plugins](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/jenkins-plugins.png)

Some plugins to install:
- ✓ [Git parameter](https://plugins.jenkins.io/git-parameter)
- ✓ [AnsiColor](https://plugins.jenkins.io/ansicolor)
- ✓ [Build with Parameters](https://plugins.jenkins.io/build-with-parameters)
- ✓ [Github](https://plugins.jenkins.io/github)
- ✓ [Kubernetes Credentials](https://plugins.jenkins.io/kubernetes-credentials)
- ✓ [Environment Script](https://plugins.jenkins.io/environment-script/)
- ✓ [CloudBees Docker Build and Publish](https://plugins.jenkins.io/docker-build-publish/)

Some plugins to remove (if not needed):
- ✕ [SSH Build Agents](https://plugins.jenkins.io/ssh-slaves/)
- ✕ [SSH server](https://plugins.jenkins.io/sshd/) + (Mina SSHD API :: Core, Mina SSHD API :: Common)

## Docker engine inside Jenkins container

Enter the container

```
docker exec -it jenkins /bin/bash
```

Get the random admin password generated

```
cat /var/jenkins_home/secrets/initialAdminPassword
```

How to install Docker engine inside Jenkins Debian container

```
apt-get update
apt-get install ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

service docker start
docker run hello-world
```

Some investigations inside the container
```
docker run busybox ping -c 1 192.203.230.10
docker run busybox nslookup google.com

```

![Questions](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/questions.png)

[Git→](gitutil.md)
