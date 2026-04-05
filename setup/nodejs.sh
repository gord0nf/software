#!/bin/bash

install_dir=$2
utils=$3
register=$4

get_version() {}
get_download_url() {}

if command_exists node; then
  echo '[nodejs] already installed'
else
  version=$(get_version)
  url="$(get_download_url "$version")" 
  
  if [[ -d "$install_dir/nodejs" ]]; then
    old_install_dir="${install_dir}_old"
    mv "$install_dir" "$old_install_dir"
  fi

  echo "[nodejs] installing NodeJS"
  download_and_extract "$url" $install_dir" && {
    if [[ -v old_install_dir ]]; then
      rm -fr "$old_install_dir"
    fi

    bash "$register" nodejs "$version" "$install_dir/possiblepath"
  } || {
    echo '[nodejs] NodeJS install failed'
    if [[ -v old_install_dir ]]; then
      mv "$old_install_dir" "$install_dir"
    fi
    exit 1
  }
fi
