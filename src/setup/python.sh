#!/bin/bash

install_dir=$2
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

THING=python
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

export LC_ALL=en_US.UTF-8

MAJOR_VERSION=3

get_version() {
  local versions=$(curl -H "Content-Type: application/json; charset=utf-8" "https://www.python.org/api/v2/downloads/release/?format=json")
  local delimeter='},{'
  local version=$(
    echo "${versions//$delimeter/$'\n'}" |
      grep -P '"is_latest"\s*:\s*true' |
      grep -P "\"version\"\s*:\s*$MAJOR_VERSION"
  )
  local pattern='"name"[[:space:]]*:[[:space:]]*"Python ([0-9]+.[0-9]+.[0-9]+)"'
  if [[ "$version" =~ $pattern ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  return 1
}

get_download_url() {
  local version=$1
  local url="https://www.python.org/ftp/python/$version/python-3.14.4"
  local arch="$(get_arch)"

  case "$(get_os)" in
  windows)
    if [[ "$arch" == 'arm' ]]; then
      echo "$url-arm64.zip"
    else
      echo "$url-amd64.zip"
    fi
    ;;
  linux)
    if [[ "$arch" == 'arm' ]]; then
      echo "$url-aarch64-linux-android.tar.gz"
    else
      echo "$url-x86_64-linux-android.tar.gz"
    fi
    ;;
  mac) fatal "the dev(s) haven't implemented mac for this yet" ;;
  esac
}

if ! $force && command_exists python && python --version; then
  log 'already installed'
else
  log 'getting current version'
  version=$(get_version) || fatal "couldn't get version number"

  log 'installing'
  url=$(get_download_url "$version")
  atomic_download_and_extract "$url" "$install_dir" '' $force || fatal 'install failed'
  register python "$version" "$install_dir"
fi
