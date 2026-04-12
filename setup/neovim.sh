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

install_win32_make() {
  local install_dir=$1
  local url='https://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-bin.zip/download'
  local tmpdir=$(mktemp -d)

  download_and_extract "$url" "$tmpdir" zip || return 1
  mv "$tmpdir/bin"/* "$install_dir"
  rm -fr "$tmpdir"
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
      make_directory_link "$config_dir" "$nvim_dir" $force
    fi
  done
}

if ! $force && command_exists nvim; then
  echo "[neovim] already installed"
else
  echo "[neovim] installing"
  atomic_download_and_extract "$(get_download_url)" "$install_dir" '' $force || {
    echo '[neovim] install failed'
    exit 1
  }

  register neovim "" "$install_dir/bin" # TODO: too lazy to get version
fi

# since some neovim stuff needs make, so if on windows, get it
if [[ $(get_os) == "windows" ]] && ! command_exists make; then
  echo '[neovim] installing win32 make'
  install_win32_make "$install_dir/bin" ||
    echo "[neovim] win32 make install failed (it's not really required tho, it's just that some plugins need it)"
fi

configure
