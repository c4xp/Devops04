# https://tomgregory.com/running-docker-in-docker-on-windows/
FROM jenkins/jenkins:lts
USER root
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl && \
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && \
    apt-get install -y kubectl apt-utils && \
    curl -sSL https://get.docker.com/ | sh

USER jenkins
RUN mkdir -p ~/.kube
COPY --chown=jenkins:jenkins C:\Users\$ENV:USERNAME\.kube\config /var/jenkins_home/.kube/config
# docker exec jenkins docker ps
# docker exec -u 0 -it jenkins /bin/bash