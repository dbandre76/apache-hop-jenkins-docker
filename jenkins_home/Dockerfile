FROM jenkins/jenkins:jdk17

USER root
RUN apt-get update -y && \
    apt-get install docker.io -y
RUN rm -rf /var/lib/apt/lists/*

#COPY Jenkinsfile jenkins_home/jenkins/

RUN usermod -aG docker jenkins

