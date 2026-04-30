#!/bin/bash

install_dir=$1
force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=golang
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_version() {
  curl --ssl-revoke-best-effort 'https://go.dev/VERSION?m=text' |
    grep -P '^go\d+\.\d+\.\d+$'
}

get_download_url() {
  local version=$1
  local os=
  local arch=
  local ext=
  case "$(get_os)" in
  windows)
    os=windows
    ext=zip
    ;;
  mac)
    os=darwin
    ext=tar.gz
    ;;
  linux)
    os=linux
    ext=tar.gz
    ;;
  esac
  case "$(get_arch)" in
  amd/x64) arch=amd64 ;;
  arm*) arch=arm64 ;;
  x32) arch=386 ;;
  esac

  echo "https://go.dev/dl/$version.$os-$arch.$ext"
}

if ! $force && command_exists go; then
  log 'already installed'
else
  log 'getting version'
  version=$(get_version)
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' $force || fatal 'install failed'
  register go "$version" "$install_dir/bin"
fi
