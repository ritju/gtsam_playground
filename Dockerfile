FROM ubuntu:jammy AS base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update \
  && apt install --no-install-recommends -y \
    apt-transport-https \
    curl \
    gnupg2 \
    ca-certificates \
  && sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list \
  && sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list \
  && apt update \
  && apt install --no-install-recommends -y \
    sudo \
    git \
    build-essential \
    g++ \
    gdb \
    cmake \
    # Required by GTSAM
    libeigen3-dev \
    libmetis-dev \
    libboost-all-dev \
  && apt autoremove -y \
  && apt clean -y \
  && rm -rf /var/lib/apt/lists/*

FROM base AS build
# Build GTSAM
COPY ["thirdparty/gtsam", "/src/gtsam/"]
WORKDIR /src/gtsam/build
RUN cmake .. \
-DCMAKE_INSTALL_PREFIX=/install \
-DCMAKE_BUILD_TYPE=Release \
-DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF \
-DGTSAM_BUILD_TESTS=OFF \
-DGTSAM_WITH_TBB=OFF \
-DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF \
-DGTSAM_USE_SYSTEM_EIGEN=ON \
-DGTSAM_USE_SYSTEM_METIS=ON \
&& make -j$(nproc) \
&& make install

FROM base AS final
ARG USERNAME=gtsam
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY --from=build /install /usr/
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && adduser $USERNAME sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $USERNAME
ENV DEBIAN_FRONTEND=dialog