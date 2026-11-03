# The build container: Debian 13 for the host's own architecture, with the cross compiler for 32-bit
# ARM. No emulation.
FROM debian:trixie-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-arm-linux-gnueabihf libc6-dev-armhf-cross gcc libc6-dev make bc bison flex \
    libssl-dev libelf-dev libncurses-dev dwarves python3 git ca-certificates kmod cpio \
    xz-utils lz4 zstd device-tree-compiler rsync file curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /work
