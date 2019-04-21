FROM ubuntu:19.04

RUN apt-get update && apt-get install -y debhelper devscripts python3-pip python3-venv rsync

VOLUME /repository
WORKDIR /repository

COPY ubuntu/disco ubuntu/disco
COPY ubuntu/publish-ppa.sh ubuntu/

COPY ubuntu/out/docker-tmp/gnupg /root/.gnupg
