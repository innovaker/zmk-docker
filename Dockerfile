FROM fedora:34 AS common

CMD ["/bin/bash"]

ENV DEBIAN_FRONTEND=noninteractive

ARG ZEPHYR_VERSION
ENV ZEPHYR_VERSION=${ZEPHYR_VERSION}
RUN \
  dnf upgrade -y \
  && dnf group install -y \
  "Development Tools" \
  "C Development Tools and Libraries" \
  && dnf install -y \
  SDL2-devel \
  ccache \
  cmake \
  file \
  git \
  glibc-devel.i686 \
  gperf \
  libstdc++-devel.i686 \
  ninja-build \
  python3-pip \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-base.txt \
  && dnf remove -y \
  python3-pip \
  && dnf clean all \
  && rm -rf /var/cache/dnf

#------------------------------------------------------------------------------

FROM common AS dev-generic

ENV LC_ALL=C
ENV PAGER=less

RUN \
  dnf install -y \
  clang-tools-extra \
  gdb \
  gpg \
  less \
  nano \
  nodejs \
  openssh-clients \
  python38 \
  python3-pip \
  python3-tkinter \  
  socat \
  tio \
  wget \
  xz \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-build-test.txt \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-run-test.txt \
  && dnf clean all \
  && rm -rf /var/cache/dnf

ARG ZEPHYR_SDK_VERSION
ENV ZEPHYR_SDK_VERSION=${ZEPHYR_SDK_VERSION}

ENV DEBIAN_FRONTEND=

#------------------------------------------------------------------------------

FROM common AS build

ARG ARCHITECTURE
ARG ZEPHYR_SDK_VERSION
ARG ZEPHYR_SDK_SETUP_FILENAME=zephyr-toolchain-${ARCHITECTURE}-${ZEPHYR_SDK_VERSION}-x86_64-linux-setup.run
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}
RUN \
  dnf install -y \
  wget \
  xz \
  && wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${ZEPHYR_SDK_SETUP_FILENAME}" \
  && sh ${ZEPHYR_SDK_SETUP_FILENAME} --quiet -- -d ${ZEPHYR_SDK_INSTALL_DIR} \
  && rm ${ZEPHYR_SDK_SETUP_FILENAME} \
  && dnf remove -y \
  wget \
  xz \
  && dnf clean all \
  && rm -rf /var/cache/dnf

#------------------------------------------------------------------------------

FROM dev-generic AS dev

COPY --from=build ${ZEPHYR_SDK_INSTALL_DIR} ${ZEPHYR_SDK_INSTALL_DIR}