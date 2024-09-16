FROM ubuntu:20.04
RUN apt-get update && apt-get install -y tzdata ca-certificates
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG USER_NAME=user
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y sudo -o Dpkg::Options::="--force-confold" && \
    groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME}:123456" | chpasswd && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

RUN echo "deb [trusted=yes] https://apt.fury.io/versionfox/ /" | sudo tee /etc/apt/sources.list.d/versionfox.list && \
    sudo apt-get update && \
    sudo apt-get install -y vfox

RUN echo "" >> ~/.bashrc && \
    echo 'eval "$(vfox activate bash)"' >> ~/.bashrc

RUN vfox add nodejs
