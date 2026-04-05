#!/bin/bash

install_dir=$2
utils=$3
register=$4

. "$utils"

MAJOR_VERSION=26

get_download_url() {
  local url="https://download.oracle.com/java/$MAJOR_VERSION/latest/"
  local os=$(get_os)
  local arch=$(get_arch)

  if [[ $os == 'windows' ]]; then
    if [[ $arch != 'amd/x64' ]]; then
      echo "[java] Oracle JDK doesn't support your cpu"
      return 1
    fi
    url+="jdk-${MAJOR_VERSION}_windows-x64_bin.zip"
  elif [[ $os == 'mac' ]]; then
    if [[ $arch == 'arm' ]]; then
      url+="jdk-${MAJOR_VERSION}_macos-aarch64_bin.tar.gz"
    else
      url+="jdk-${MAJOR_VERSION}_macos-x64_bin.tar.gz"
    fi
  elif [[ $os == 'linux' ]]; then
    if [[ $arch == 'arm' ]]; then
      url+="jdk-${MAJOR_VERSION}_linux-aarch64_bin.tar.gz"
    else
      url+="jdk-${MAJOR_VERSION}_linux-x64_bin.tar.gz"
    fi
  fi

  echo "$url"
}

if command_exists java; then
  echo "[java] already installed"
else
  if [[ -d "$install_dir" ]]; then
    old_install_dir="${install_dir}_old"
    mv "$install_dir" "$old_install_dir"
  fi

  echo "[java] installing Oracle JDK"
  download_and_extract "$(get_download_url)" "$install_dir" && {
    if [[ -v old_install_dir ]]; then
      rm -fr "$old_install_dir"
    fi

    bash "$register" java "$MAJOR_VERSION" "$install_dir/jdk-$MAJOR_VERSION/bin"
  } || {
    echo '[java] Oracle JDK install failed'
    if [[ -v old_install_dir ]]; then
      mv "$old_install_dir" "$install_dir"
    fi
    exit 1
  }
fi
