#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=rmpc
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_download_url() {
  local version=$1

  local os= arch=
  case "$(get_os)" in
  mac) os=apple-darwin ;;
  linux) os=unknown-linux-gnu ;;
  *) fatal 'os not supported' ;;
  esac
  case "$(get_arch)" in
  amd/x64) arch=x86_64 ;;
  arm*) arch=aarch64 ;;
  *) fatal 'arch not supported' ;;
  esac

  echo "https://github.com/mierak/rmpc/releases/download/$version/rmpc-$version-$arch-$os.tar.gz"
}

binary="$install_dir/rmpc"

if ! $FORCE && command_exists rmpc; then
  log 'already installed'
elif ! $FORCE && check_executable "$binary"; then
  log 'already installed, just not registered'
  log 'registering'
  register "$binary"
else
  log 'getting version'
  version=$(get_latest_github_tag 'mierak/rmpc')
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' || fatal 'install failed'
  register "$binary"
fi
