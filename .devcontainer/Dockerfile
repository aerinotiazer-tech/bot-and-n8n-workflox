FROM mcr.microsoft.com/devcontainers/javascript-node:1-24-bookworm

USER root
ARG DEBIAN_FRONTEND=noninteractive
ARG BLENDER_VERSION=4.5.13
ARG BLENDER_SHA256=da4e69b06b75b9e642d106496c50e7e240218b411d2f6e18271c1d1d819cef91
ARG BLENDER_ARCHIVE=blender-4.5.13-linux-x64.tar.xz
ARG BLENDER_DIR=blender-4.5.13-linux-x64

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl ffmpeg git libegl1 libgl1 libsm6 libxi6 libxkbcommon0 \
    libxrender1 python3 python3-venv xz-utils build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl --fail --location "https://download.blender.org/release/Blender4.5/${BLENDER_ARCHIVE}" -o /tmp/blender.tar.xz; \
    echo "${BLENDER_SHA256}  /tmp/blender.tar.xz" | sha256sum -c -; \
    tar -xf /tmp/blender.tar.xz -C /opt; \
    ln -s "/opt/${BLENDER_DIR}/blender" /usr/local/bin/blender; \
    rm /tmp/blender.tar.xz

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh
RUN npm install --global opencode-ai

ENV BLENDER_HOME=/opt/${BLENDER_DIR}
ENV BLENDER_VERSION=${BLENDER_VERSION}
ENV PATH="${BLENDER_HOME}:${PATH}"

USER vscode
