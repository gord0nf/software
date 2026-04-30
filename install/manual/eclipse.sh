#!/bin/bash

# unfinished

install_dir=$1
force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=eclipse
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

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
  mac) fatal "macos hasn't been implemented in script yet" ;;
  esac
  case "$(get_arch)" in
  amd/x64) arch=x86_64 ;;
  amd) arch=aarch64 ;;
  *) fatal 'arch not supported' ;;
  esac

  echo "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/$version/R/eclipse-java-$version-R-$os-$arch.$ext"
}

if ! $force && command_exists eclipse; then
  log 'already installed'
else
  log 'getting version'
  version=$(get_version) || fatal 'failed to get version'

  log 'installing'
  url=$(get_download_url "$version")
  atomic_download_and_extract "$url" "$install_dir" '' $force || fatal 'install failed'
  register eclipse "$version" "$install_dir"
fi
