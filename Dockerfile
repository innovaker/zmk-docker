FROM debian:stable-20210511-slim AS common

CMD ["/bin/bash"]

ENV DEBIAN_FRONTEND=noninteractive

ARG ZEPHYR_VERSION
ENV ZEPHYR_VERSION=${ZEPHYR_VERSION}
RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  ccache \
  file \
  gcc \
  gcc-multilib \
  git \
  gperf \
  make \
  ninja-build \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  && echo deb http://deb.debian.org/debian buster-backports main >> /etc/apt/sources.list \
  && apt-get -y update \
  && apt-get -y -t buster-backports install --no-install-recommends \
  cmake \
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

RUN \
  apt-get -y update \
  && apt-get -y -t buster-backports install --no-install-recommends \
  curl \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get -y update \
  && apt-get -y install --no-install-recommends \
  clang-format \
  g++-multilib \
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
  wget \
  xz-utils \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-build-test.txt \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-run-test.txt \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG PYTHON_VERSION=3.8.10
RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  build-essential \
  libbz2-dev \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libnss3-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  zlib1g-dev \
  && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
  && tar xvf Python-${PYTHON_VERSION}.tgz \
  && cd Python-${PYTHON_VERSION} \
  && ./configure --enable-optimizations --enable-shared \
  && make -j $(nproc) \
  && make altinstall \
  && cp libpython3.8.so* /usr/lib \
  && chmod -v 755 /usr/lib/libpython3.8.so* \
  && cd .. \
  && rm -Rf Python-${PYTHON_VERSION} \
  && rm Python-${PYTHON_VERSION}.tgz \
  && apt-get remove -y --purge \
  build-essential \
  libbz2-dev \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libnss3-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=

#------------------------------------------------------------------------------

FROM common AS build

ARG ARCHITECTURE
ARG ZEPHYR_SDK_VERSION
ARG ZEPHYR_SDK_SETUP_FILENAME=zephyr-toolchain-${ARCHITECTURE}-${ZEPHYR_SDK_VERSION}-x86_64-linux-setup.run
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