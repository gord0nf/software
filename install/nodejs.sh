#!/bin/bash

install_dir=$1
force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=nodejs
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

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
  x32) fatal 'arch not supported' ;;
  esac

  echo "https://nodejs.org/dist/$version/node-$version-$os-$arch.$ext"
}

if ! $force && command_exists node; then
  log 'already installed'
else
  log 'getting version'
  version=$(get_latest_github_tag 'nodejs/node')
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' $force || fatal 'install failed'
  register nodejs "$version" "$install_dir"
fi
