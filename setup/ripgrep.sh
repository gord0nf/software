#!/bin/bash

install_dir=$2
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS"
  exit 1
fi

get_download_url() {
  local version=$1

  local os=
  local arch=
  local comp=
  local ext=
  case "$(get_os)" in
  windows)
    os=pc-windows
    comp=-msvc
    ext=zip
    ;;
  mac)
    os=apple-darwin
    ext=tar.gz
    ;;
  linux)
    os=unknown-linux
    comp=-gnu
    ext=tar.gz
    ;;
  esac
  case "$(get_arch)" in
  amd/x64)
    arch=x86_64
    if [[ "$os" == 'unknown-linux' ]]; then
      comp=-musl
    fi
    ;;
  arm) arch=aarch64 ;; # armv7 also available, but im lazy
  x32) arch=i686 ;;
  esac

  echo "https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep-$version-$arch-$os$comp.$ext"
}

if ! $force && command_exists rg; then
  echo '[ripgrep] already installed'
else
  if [[ -d "$install_dir" ]]; then
    old_install_dir="${install_dir}_old"
    mv "$install_dir" "$old_install_dir"
  fi

  echo '[ripgrep] getting version'
  version=$(get_latest_github_tag 'BurntSushi/ripgrep')
  url=$(get_download_url "$version")

  echo '[ripgrep] installing'
  download_and_extract "$url" "$install_dir" || {
    echo '[ripgrep] install failed'
    if [[ -v old_install_dir ]]; then
      mv "$old_install_dir" "$install_dir"
    fi
    exit 1
  }

  if [[ -v old_install_dir ]]; then
    rm -fr "$old_install_dir"
  fi

  register ripgrep "$version" "$install_dir"
fi
