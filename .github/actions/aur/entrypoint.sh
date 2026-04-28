#!/usr/bin/env bash
set -euo pipefail

# Set path
WORKPATH=$GITHUB_WORKSPACE/$INPUT_PKGNAME
HOME=/home/builder

echo "::group::Copying files from $WORKPATH to $HOME/gh-action"
# Set path permision
cd $HOME
mkdir gh-action
cd gh-action
rsync -av --exclude='.git' "$WORKPATH"/ ./
echo "::endgroup::"

echo "::group::Updating checksums on PKGBUILD"
updpkgsums
git diff PKGBUILD
echo "::endgroup::"

echo "::group::Generating new .SRCINFO based on PKGBUILD"
makepkg --printsrcinfo >.SRCINFO
git diff .SRCINFO
echo "::endgroup::"

if [[ "$INPUT_ACTION" == "validate" ]]; then
  if [[ -n "${INPUT_CCACHE_DIR:-}" ]]; then
    CCACHE_PATH="$GITHUB_WORKSPACE/${INPUT_CCACHE_DIR}"
    mkdir -p "$CCACHE_PATH"
    export CCACHE_DIR="$CCACHE_PATH"
    echo "CCACHE_DIR set to: $CCACHE_DIR" >&2
  fi

  echo "::group::Running makepkg"
  makepkg --syncdeps --noconfirm --needed
  echo "::endgroup::"

  echo "::group::Linting with namcap"
  namcap PKGBUILD
  namcap ./*.pkg.tar.zst 2>/dev/null || true
  echo "::endgroup::"

else
  echo "::group::Copying files from $HOME/gh-action to $WORKPATH"
  sudo cp -fv PKGBUILD "$WORKPATH"/PKGBUILD
  sudo cp -fv .SRCINFO "$WORKPATH"/.SRCINFO
  echo "::endgroup::"
fi
