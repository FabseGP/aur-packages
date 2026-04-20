#!/usr/bin/env bash
set -euo pipefail

echo "::group::Updating"
sudo pacman -Syu --noconfirm
echo "::endgroup::"

# Set path
WORKPATH=$GITHUB_WORKSPACE/$INPUT_PKGNAME
HOME=/home/builder
echo "::group::Copying files from $WORKPATH to $HOME/gh-action"
# Set path permision
cd $HOME
mkdir gh-action
cd gh-action
cp -rfv "$GITHUB_WORKSPACE"/.git ./
cp -fv "$WORKPATH"/* .
echo "::endgroup::"

echo "::group::Updating archlinux-keyring"
sudo pacman -S --noconfirm archlinux-keyring
echo "::endgroup::"

if [[ -n "${INPUT_CCACHE_DIR:-}" ]]; then
  CCACHE_DIR="/home/builder/.ccache"
  mkdir -p "$CCACHE_DIR"
  export CCACHE_DIR
fi

echo "::group::Updating checksums on PKGBUILD"
updpkgsums
git diff PKGBUILD
echo "::endgroup::"

echo "::group::Generating new .SRCINFO based on PKGBUILD"
makepkg --printsrcinfo >.SRCINFO
git diff .SRCINFO
echo "::endgroup::"

if [[ "$INPUT_ACTION" == "validate" ]]; then
  echo "::group::Installing depends using paru"
  source PKGBUILD
  paru -Syu --removemake --needed --noconfirm "${depends[@]}" "${makedepends[@]}"
  echo "::endgroup::"

  echo "::group::Running makepkg"
  makepkg
  echo "::endgroup::"

else
  echo "::group::Copying files from $HOME/gh-action to $WORKPATH"
  sudo cp -fv PKGBUILD "$WORKPATH"/PKGBUILD
  sudo cp -fv .SRCINFO "$WORKPATH"/.SRCINFO
  echo "::endgroup::"
fi
