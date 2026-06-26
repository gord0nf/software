#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=nodejs
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
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
  arm*) arch=arm64 ;;
  x32) fatal 'arch not supported' ;;
  esac

  echo "https://nodejs.org/dist/$version/node-$version-$os-$arch.$ext"
}

binaries=("$install_dir/node" "$install_dir/npm")
check_bins() {
  for bin in "${binaries[@]}"; do
    check_executable "$bin" || return 1
  done
}

if ! $FORCE && command_exists node; then
  log 'already installed'
elif ! $FORCE && check_bins; then
  log 'already installed, just not registered'
  log 'registering'
  register "${binaries[@]}"
else
  log 'getting version'
  version=$(get_latest_github_tag 'nodejs/node')
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' || fatal 'install failed'
  register "${binaries[@]}"
fi
