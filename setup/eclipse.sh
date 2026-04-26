#!/bin/bash

config_dir=$1
install_dir=$2
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

get_version() {
  curl 'https://www.eclipse.org/downloads/packages/release' |
    grep -P '/downloads/packages/release/\d{4}-\d{2}/r' |
    head -n 1 |
    sed -r 's/^.*\/downloads\/packages\/release\/([0-9]{4}-[0-9]{2})\/r.*$/\1/'
}

get_download_url() {
  local version=$1
  local os=
  local arch=
  local ext=
  case "$(get_os)" in
  windows)
    os=win32
    ext=zip
    ;;
  linux)
    os=linux-gtk
    ext=tar.gz
    ;;
  mac)
    echo "[eclipse] macos hasn't been implemented in script yet" >&2
    exit 1
    ;;
  esac
  case "$(get_arch)" in
  amd/x64) arch=x86_64 ;;
  amd) arch=aarch64 ;;
  *)
    echo '[eclipse] arch not supported' >&2
    exit 1
    ;;
  esac

  echo "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/$version/R/eclipse-java-$version-R-$os-$arch.$ext"
}

if ! $force && command_exists eclipse; then
  echo '[eclipse] already installed'
else
  echo '[eclipse] getting version'
  version=$(get_version) || {
    echo '[eclipse] failed to get version' >&2
    exit 1
  }

  echo '[eclipse] installing'
  url=$(get_download_url "$version")
  echo "$url"
  exit
  atomic_download_and_extract "$url" "$install_dir" '' $force || {
    echo '[eclipse] install failed' >&2
    exit 1
  }

  register eclipse "$version" "$install_dir"
fi
