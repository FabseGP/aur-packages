FROM docker.io/library/archlinux:base-devel-20260419.0.517065

RUN pacman-key --init

RUN pacman -Syu --needed --noconfirm pacman-contrib namcap ccache \
  git archlinux-keyring nodejs curl base-devel mold zstd cmake go \
  pnpm rustup ninja --overwrite '*' && \
  useradd -m -u 1001 builder && \
  echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN sed -i 's/!ccache/ccache/' /etc/makepkg.conf && \
    sed -i 's/^LDFLAGS="\([^"]*\)"/LDFLAGS="\1 -fuse-ld=mold"/' /etc/makepkg.conf && \
    echo 'export PATH="/usr/lib/ccache:$PATH"' >> /home/builder/.bashrc

RUN sed -i '/^\[options\]/,/^\[/ s/^\(CheckSpace\)/\1\nDisableSandbox/' /etc/pacman.conf

RUN ccache --set-config=max_size=5G --set-config=compression=true

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh 

WORKDIR /home/builder

USER builder
