#!/bin/bash

install_dir=$1
force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=java
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

MAJOR_VERSION=25

get_download_url() {
  local url="https://download.oracle.com/java/$MAJOR_VERSION/latest/"
  local arch=$(get_arch)

  case "$(get_os)" in
  windows)
    [[ $arch == 'amd/x64' ]] || fatal "Oracle JDK doesn't support your cpu"
    url+="jdk-${MAJOR_VERSION}_windows-x64_bin.zip"
    ;;
  mac)
    if [[ $arch == 'arm' ]]; then
      url+="jdk-${MAJOR_VERSION}_macos-aarch64_bin.tar.gz"
    else
      url+="jdk-${MAJOR_VERSION}_macos-x64_bin.tar.gz"
    fi
    ;;
  linux)
    if [[ $arch == 'arm' ]]; then
      url+="jdk-${MAJOR_VERSION}_linux-aarch64_bin.tar.gz"
    else
      url+="jdk-${MAJOR_VERSION}_linux-x64_bin.tar.gz"
    fi
    ;;
  esac

  echo "$url"
}

if ! $force && command_exists java; then
  log 'already installed'
else
  log 'installing Oracle JDK'
  atomic_download_and_extract "$(get_download_url)" "$install_dir" '' $force ||
    fatal 'Oracle JDK install failed'
  register java "$MAJOR_VERSION" "$install_dir/bin"
fi
