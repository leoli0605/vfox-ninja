#!/bin/bash

# ==================================================
# If you want to use docker without sudo,
# please run the following commands in the terminal.
# ==================================================
# sudo usermod -aG docker $(whoami)
# newgrp docker

IMAGE_NAME="vfox"
USER_NAME=$(whoami)
USER_UID=$(id -u "${USER_NAME}")
USER_GID=$(id -g "${USER_NAME}")
PLUGIN_NAME="ninja" # Please change the plugin name.
ENTRY_PATH=/home/"${USER_NAME}"/.version-fox/plugin/${PLUGIN_NAME}

# docker rmi ${IMAGE_NAME} -f # If you want to rebuild the image, please uncomment this line.

if [ -z "$(docker images -q ${IMAGE_NAME})" ]; then
    docker build --no-cache \
        --build-arg USER_NAME="${USER_NAME}" \
        --build-arg USER_UID="${USER_UID}" \
        --build-arg USER_GID="${USER_GID}" \
        -t ${IMAGE_NAME} .
fi

docker run -it --rm \
    -v "$(pwd)":${ENTRY_PATH} \
    -w ${ENTRY_PATH} \
    ${IMAGE_NAME} /bin/bash
