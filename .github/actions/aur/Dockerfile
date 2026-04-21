FROM docker.io/library/archlinux:base-devel-20260419.0.517065

RUN pacman-key --init

RUN pacman -Syu --needed --noconfirm pacman-contrib namcap git sudo ccache archlinux-keyring && \
  useradd -m -u 1001 builder && \
  echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN sed -i 's/!ccache/ccache/' /etc/makepkg.conf && \
    echo 'export PATH="/usr/lib/ccache:$PATH"' >> /home/builder/.bashrc

RUN ccache --set-config=max_size=5G --set-config=compression=true

WORKDIR /home/builder

USER builder

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
