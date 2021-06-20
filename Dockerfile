FROM ubuntu:focal-20210609 AS common

CMD ["/bin/bash"]

ENV DEBIAN_FRONTEND=noninteractive

ARG ZEPHYR_VERSION
ENV ZEPHYR_VERSION=${ZEPHYR_VERSION}
ARG TARGETARCH
RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  $(${TARGETARCH} = "amd64" && "gcc-multilib" || "") \
  ccache \
  cmake \
  file \
  gcc \
  git \
  gperf \
  make \
  ninja-build \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-base.txt \
  && apt-get remove -y --purge \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------

FROM common AS dev-generic

ENV LC_ALL=C
ENV PAGER=less

ARG TARGETARCH
RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  curl \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get -y update \
  && apt-get -y install --no-install-recommends \
  $(${TARGETARCH} = "amd64" && "g++-multilib" || "") \
  clang-format \
  gdb \
  gpg \
  gpg-agent \
  less \
  libsdl2-dev \
  locales \
  nano \
  nodejs \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-tk \
  python3-wheel \
  socat \
  ssh \
  tio \
  wget \
  xz-utils \
  && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
  && . $HOME/.cargo/env \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-build-test.txt \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-run-test.txt \
  && rustup self uninstall -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG ZEPHYR_SDK_VERSION
ENV ZEPHYR_SDK_VERSION=${ZEPHYR_SDK_VERSION}

ENV DEBIAN_FRONTEND=

#------------------------------------------------------------------------------

FROM common AS build

ARG ARCHITECTURE
ARG ZEPHYR_SDK_VERSION
ARG MACHINE
ARG ZEPHYR_SDK_SETUP_FILENAME=zephyr-toolchain-${ARCHITECTURE}-${ZEPHYR_SDK_VERSION}-${MACHINE}-linux-setup.run
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}
RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  bzip2 \
  wget \
  xz-utils \
  && wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${ZEPHYR_SDK_SETUP_FILENAME}" \
  && sh ${ZEPHYR_SDK_SETUP_FILENAME} --quiet -- -d ${ZEPHYR_SDK_INSTALL_DIR} \
  && rm ${ZEPHYR_SDK_SETUP_FILENAME} \
  && apt-get remove -y --purge \
  bzip2 \
  wget \
  xz-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------

FROM dev-generic AS dev

COPY --from=build ${ZEPHYR_SDK_INSTALL_DIR} ${ZEPHYR_SDK_INSTALL_DIR}