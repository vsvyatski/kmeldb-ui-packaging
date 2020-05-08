FROM ubuntu:20.04

ARG USER_ID
ARG GROUP_ID

ARG USER_NAME=builder
ARG GROUP_NAME=builder

RUN apt-get update && apt-get install -y debhelper devscripts python3-pip python3-venv rsync

RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} && useradd -l -u ${USER_ID} -g ${GROUP_ID} -d /home/${USER_NAME} -m ${USER_NAME}

USER ${USER_NAME}

RUN mkdir -p /home/${USER_NAME}/kmeldb-ui-packaging
WORKDIR /home/${USER_NAME}/kmeldb-ui-packaging

# parameters for --chown are not supported yet (Docker 18.09.5), I can't use variables
COPY --chown=builder:builder ubuntu/focal ubuntu/focal
COPY --chown=builder:builder ubuntu/publish-ppa.sh ubuntu/

COPY --chown=builder:builder ubuntu/out/docker-tmp/gnupg /home/${USER_NAME}/.gnupg
RUN chmod 700 /home/${USER_NAME}/.gnupg
