# syntax=docker/dockerfile:1



ARG MASSA_VERSION="MAIN.2.4"
ARG MASSA_BUILD="/massa"
ARG MASSA_HOME="/home/massa"

ARG MASSA_UID=5000
ARG MASSA_USER=massa
ARG MASSA_GID=5000
ARG MASSA_GROUP=massa

ARG RUST_VERSION="1.83.0-bookworm"
ARG UBUNTU_VERSION="24.04"



FROM rust:${RUST_VERSION} AS builder

ARG  MASSA_VERSION
ARG  MASSA_BUILD

RUN  --mount=type=cache,target=~/.cache \
       apt-get update && \
       apt-get -y install \
         pkg-config \
         curl \
         git \
         build-essential \
         libssl-dev \
         libclang-dev cmake \
       && apt-get clean \
       && rm -rf /var/lib/apt/lists/*

RUN  git clone https://github.com/massalabs/massa.git ${MASSA_BUILD}

WORKDIR ${MASSA_BUILD}

RUN  git checkout ${MASSA_VERSION}
RUN  RUST_BACKTRACE=full cargo build --release



FROM ubuntu:${UBUNTU_VERSION} AS massa

ARG  MASSA_VERSION
ARG  MASSA_BUILD
ARG  MASSA_HOME

ARG  MASSA_UID
ARG  MASSA_USER
ARG  MASSA_GID
ARG  MASSA_GROUP

LABEL maintainer="github.com/dex2code"
LABEL description="MASSA Node"
LABEL version="${MASSA_VERSION}"

RUN  --mount=type=cache,target=~/.cache \
       apt-get update && \
       apt-get -y install \
         nano \
         less \
         lsof \
       && apt-get clean \
       && rm -rf /var/lib/apt/lists/*

RUN  groupadd -g ${MASSA_GID} ${MASSA_GROUP} && \
     useradd -d ${MASSA_HOME} -g ${MASSA_GROUP} -m -s /sbin/nologin -u ${MASSA_UID} ${MASSA_USER}

USER    ${MASSA_USER}
WORKDIR ${MASSA_HOME}

RUN  mkdir -p \
       ${MASSA_HOME}/massa-node \
       ${MASSA_HOME}/massa-node/storage \
       ${MASSA_HOME}/massa-node/dump \
       ${MASSA_HOME}/massa-node/config/staking_wallets \
       ${MASSA_HOME}/massa-client \
       ${MASSA_HOME}/massa-client/wallets

VOLUME  ${MASSA_HOME}/massa-node/storage
VOLUME  ${MASSA_HOME}/massa-node/dump
VOLUME  ${MASSA_HOME}/massa-node/config/staking_wallets
VOLUME  ${MASSA_HOME}/massa-client/wallets
            
COPY  --from=builder \
      --chown=${MASSA_UID}:${MASSA_GID} \
      ${MASSA_BUILD}/massa-node/ ${MASSA_HOME}/massa-node/

COPY  --from=builder \
      --chown=${MASSA_UID}:${MASSA_GID} \
      ${MASSA_BUILD}/massa-client/ ${MASSA_HOME}/massa-client/

COPY  --from=builder \
      --chown=${MASSA_UID}:${MASSA_GID} \
      --chmod=755 \
      ${MASSA_BUILD}/target/release/massa-node ${MASSA_HOME}/massa-node/

COPY  --from=builder \
      --chown=${MASSA_UID}:${MASSA_GID} \
      --chmod=755 \
      ${MASSA_BUILD}/target/release/massa-client ${MASSA_HOME}/massa-client/

COPY  --chown=${MASSA_UID}:${MASSA_GID} \
      --chmod=644 \
      stuff/config.toml ${MASSA_HOME}/massa-node/config/

COPY  --chown=${MASSA_UID}:${MASSA_GID} \
      --chmod=755 \
      stuff/massa-start.sh ${MASSA_HOME}/massa-node/

COPY  --chown=${MASSA_UID}:${MASSA_GID} \
      --chmod=755 \
      stuff/massa-client.sh ${MASSA_HOME}/massa-node/

COPY  --chown=${MASSA_UID}:${MASSA_GID} \
      --chmod=755 \
      stuff/massa-healthcheck.sh ${MASSA_HOME}/massa-node/

COPY  --chown=${MASSA_UID}:${MASSA_GID} \
      --chmod=600 \
      stuff/massa-pass.txt ${MASSA_HOME}/massa-node/

EXPOSE  31244/tcp
EXPOSE  31245/tcp
EXPOSE  31248/tcp
EXPOSE  33035/tcp
EXPOSE  33037/tcp

WORKDIR     ${MASSA_HOME}/massa-node
ENV         PATH="$PATH:${MASSA_HOME}/massa-node:${MASSA_HOME}/massa-client"
HEALTHCHECK --start-period=60s \
            --interval=15s \
            --retries=4 \
            CMD [ "massa-healthcheck.sh" ]

CMD ["massa-start.sh"]
