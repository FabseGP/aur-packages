#!/usr/bin/env bash
set -euo pipefail

# Set path
ACTION="${1:-}"
PKGNAME="${2:-}"
CCACHE_DIR_ARG="${3:-}"

WORKPATH="$GITHUB_WORKSPACE/$PKGNAME"

echo "::group::Copying files from $GITHUB_WORKSPACE to $HOME/gh-action"
# Set path permision
cd "$HOME"
mkdir gh-action
cd gh-action
cp -rfv "$GITHUB_WORKSPACE"/.git ./
cp -fv "$WORKPATH"/* .
echo "::endgroup::"

echo "::group::Updating checksums on PKGBUILD"
updpkgsums
git diff PKGBUILD
echo "::endgroup::"

echo "::group::Generating new .SRCINFO based on PKGBUILD"
makepkg --printsrcinfo >.SRCINFO
git diff .SRCINFO
echo "::endgroup::"

echo "::group::Refreshing pacman"
sudo pacman -Syy
echo "::endgroup::"

if [[ "$ACTION" == "validate" ]]; then
  if [[ -n "${CCACHE_DIR_ARG:-}" ]]; then
    CCACHE_PATH="$GITHUB_WORKSPACE/${CCACHE_DIR_ARG}"
    mkdir -p "$CCACHE_PATH"
    export CCACHE_DIR="$CCACHE_PATH"
    echo "CCACHE_DIR set to: $CCACHE_DIR" >&2
  fi

  echo "::group::Running makepkg"
  makepkg --syncdeps --noconfirm --needed
  echo "::endgroup::"

  echo "::group::Linting with namcap"
  namcap PKGBUILD
  echo "::endgroup::"

else
  echo "::group::Copying files from $HOME/gh-action to $WORKPATH"
  sudo cp -fv PKGBUILD "$WORKPATH"/PKGBUILD
  sudo cp -fv .SRCINFO "$WORKPATH"/.SRCINFO
  echo "::endgroup::"
fi
