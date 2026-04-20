FROM docker.io/library/archlinux:base-devel-20260412.0.513370

RUN pacman-key --init

RUN pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
  pacman-key --lsign-key 3056513887B78AEB && \
  pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

RUN echo "" >> /etc/pacman.conf && \
    echo "[chaotic-aur]" >> /etc/pacman.conf && \
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

RUN pacman -Syu --needed --noconfirm pacman-contrib namcap git sudo paru ccache archlinux-keyring && \
  useradd -m -u 1001 builder && \
  echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN sed -i 's/!ccache/ccache/' /etc/makepkg.conf && \
    echo 'export PATH="/usr/lib/ccache:$PATH"' >> /home/builder/.bashrc

RUN ccache --set-config=max_size=5G --set-config=compression=true

WORKDIR /home/builder

USER builder

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
