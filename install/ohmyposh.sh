#!/bin/bash

install_dir=$1
force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=ohmyposh
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_download_url() {
  local os=$(get_os)
  local arch=$(get_arch)
  if [[ $os == mac ]]; then
    os=darwin
  fi
  case "$arch" in
  amd/x64) arch=amd64 ;;
  x32) fatal 'x32 arch not supported' ;;
  esac
  if is_android; then
    echo 'https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-android-arm'
    return 0
  fi

  echo "https://cdn.ohmyposh.dev/releases/latest/posh-$os-$arch$([ $os == windows ] && echo .exe)"
}

if ! $force && command_exists oh-my-posh; then
  log 'already installed'
else
  log 'downloading'
  url=$(get_download_url)
  tmp=$(download "$url") || fatal 'download failed'

  mkdir -p "$install_dir"
  mv "$tmp" "$install_dir/oh-my-posh"
  chmod +x "$install_dir/oh-my-posh"
  if [[ "$tmp" == *.exe ]]; then
    mv "$install_dir/oh-my-posh" "$install_dir/oh-my-posh.exe"
  fi
  rm -f "$tmp"

  register ohmyposh '' "$install_dir"
fi
