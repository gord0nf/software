#!/bin/bash

install_dir=$1
force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=smerge
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_download_url() {
  os=$(get_os)
  arch=$(get_arch)
  local prefix=
  case "$os" in
  windows)
    [[ "$arch" == 'amd/x64' ]] || fatal 'nothing for your os and arch'
    prefix='x64\.zip'
    ;;
  mac) prefix='mac\.zip' ;;
  linux)
    if [[ "$arch" == 'arm' ]]; then
      prefix='arm64\.tar\.xz'
    else
      prefix='x64\.tar\.xz'
    fi
    ;;
  esac

  local urls=$(
    curl 'https://www.sublimemerge.com/download_thanks' |
      grep -E -o "\"https://download.sublimetext.com/sublime_merge_build_[0-9]{4}_$prefix\""
  ) || return 1
  local url=$(
    IFS=$'\n'
    urls=($urls)
    echo "${urls[0]}"
  )
  local regex='"(.+)"'
  if [[ "$url" =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    return 1
  fi
}

get_version() {
  local url=$1
  if [[ "$url" =~ sublime_merge_build_([0-9]{4})_ ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}

if ! $force && command_exists sublime_merge; then
  log 'already installed'
else
  log 'getting url'
  url=$(get_download_url) || fatal "couldn't get url"

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' $force || fatal 'install failed'
  register sublime_merge "$(get_version "$url")" "$install_dir"
fi
