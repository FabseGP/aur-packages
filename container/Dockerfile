FROM docker.io/library/archlinux:base-devel-20260503.0.523481

RUN pacman-key --init

RUN pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
  pacman-key --lsign-key 3056513887B78AEB && \
  pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

RUN echo "" >> /etc/pacman.conf && \
    echo "[chaotic-aur]" >> /etc/pacman.conf && \
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

RUN pacman -Syu --needed --noconfirm pacman-contrib namcap ccache wget \
  git archlinux-keyring nodejs curl base-devel wild zstd cmake go \
  pnpm rustup ninja paru clang llvm-libs --overwrite '*' && \
  useradd -m -u 1001 builder && \
  echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN sed -i 's/^LDFLAGS="\([^"]*\)"/LDFLAGS="\1 -fuse-ld=wild"/' /etc/makepkg.conf && \
  sed -i '/^\[options\]/,/^\[/ s/^\(CheckSpace\)/\1\nDisableSandbox/' /etc/pacman.conf

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh 

WORKDIR /home/runner

USER builder

USER root

RUN sed -i 's/!ccache/ccache/' /etc/makepkg.conf && \
    echo 'export PATH="/usr/lib/ccache:$PATH"' >> /home/builder/.bashrc

WORKDIR /home/runner

USER builder

RUN ccache --set-config=max_size=5G --set-config=compression=true
