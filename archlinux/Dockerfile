FROM archlinux/base

ARG USER_ID
ARG GROUP_ID

ARG USER_NAME=builder
ARG GROUP_NAME=builder

RUN pacman -Syu --noconfirm && pacman-db-upgrade && pacman -S --noconfirm rsync grep python binutils python-pyqt5 fakeroot gawk file python-wheel

RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} && useradd -l -u ${USER_ID} -g ${GROUP_ID} -d /home/${USER_NAME} -m ${USER_NAME}

USER ${USER_NAME}

RUN mkdir -p /home/${USER_NAME}/kmeldb-ui-packaging
WORKDIR /home/${USER_NAME}/kmeldb-ui-packaging

# parameters for --chown are not supported yet (Docker 18.09.5), I can't use variables
COPY --chown=builder:builder install-actions.sh ./
COPY --chown=builder:builder PKGBUILD ./
COPY --chown=builder:builder build.sh ./
