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
  local ext=
  case "$(get_os)" in
  windows)
    os=win
    ext=zip
    ;;
  mac)
    os=darwin
    ext=tar.gz
    ;;
  linux)
    os=linux
    ext=tar.xz
    ;;
  esac
  case "$(get_arch)" in
  amd/x64) arch=x64 ;;
  arm) arch=arm64 ;;
  x32)
    echo "[nodejs] arch not supported" >&2
    return 1
    ;;
  esac

  echo "https://nodejs.org/dist/$version/node-$version-$os-$arch.$ext"
}

if ! $force && command_exists node; then
  echo '[nodejs] already installed'
else
  echo '[nodejs] getting version'
  version=$(get_latest_github_tag 'nodejs/node')
  url=$(get_download_url "$version")

  echo '[nodejs] installing'
  atomic_download_and_extract "$url" "$install_dir" '' $force || {
    echo '[nodejs] install failed'
    exit 1
  }

  register nodejs "$version" "$install_dir"
fi
