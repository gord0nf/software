#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=ripgrep
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

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
  arm*) arch=aarch64 ;; # armv7 also available, but im lazy
  x32) arch=i686 ;;
  esac

  echo "https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep-$version-$arch-$os$comp.$ext"
}

binary="$install_dir/rg"

if ! $FORCE && command_exists rg; then
  log 'already installed'
elif ! $FORCE && check_executable "$binary"; then
  log 'already installed, just not registered'
  log 'registering'
  register "$binary"
else
  log 'getting version'
  version=$(get_latest_github_tag 'BurntSushi/ripgrep')
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' || fatal 'install failed'
  register "$binary"
fi
