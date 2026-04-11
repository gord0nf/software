#!/bin/bash

config_dir=$1
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
  local url='https://github.com/neovim/neovim/releases/latest/download/'
  local os=$(get_os)
  local arch=$(get_arch)

  if [[ $os == 'windows' ]]; then
    if [[ $arch == 'arm' ]]; then
      url+='nvim-win-arm64.zip'
    else
      url+='nvim-win64.zip'
    fi
  elif [[ $os == 'mac' ]]; then
    if [[ $arch == 'arm' ]]; then
      url+='nvim-macos-arm64.tar.gz'
    else
      url+='nvim-macos-x86_64.tar.gz'
    fi
  elif [[ $os == 'linux' ]]; then
    if [[ $arch == 'arm' ]]; then
      url+='nvim-linux-arm64.tar.gz'
    else
      url+='nvim-linux-x86_64.tar.gz'
    fi
  fi

  echo "$url"
}

configure() {
  local default_nvim_dirs=(
    "$HOME/.config/nvim"
    "$HOME/AppData/Local/nvim"
  )

  # create link from default nvim dir(s) to config
  for nvim_dir in "${default_nvim_dirs[@]}"; do
    if [[ -d "$(dirname "$nvim_dir")" ]]; then
      echo "[neovim] creating directory link from '$nvim_dir' to config"
      make_directory_link "$config_dir" "$nvim_dir"
    fi
  done
}

if ! $force && command_exists nvim; then 
  echo "[neovim] already installed"
else
  if [[ -d "$install_dir" ]]; then
    old_install_dir="${install_dir}_old"
    mv "$install_dir" "$old_install_dir"
  fi

  echo "[neovim] installing"
  download_and_extract "$(get_download_url)" "$install_dir" && {
    if [[ -v old_install_dir ]]; then
      rm -fr "$old_install_dir"
    fi

    register neovim "" "$install_dir/bin" # TODO: too lazy to get version
  } || {
    echo '[neovim] install failed'
    if [[ -v old_install_dir ]]; then
      mv "$old_install_dir" "$install_dir"
    fi
    exit 1
  }
fi

configure
