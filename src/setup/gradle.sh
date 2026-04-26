#!/bin/bash

install_dir=$2
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

THING=gradle
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

CURRENT_VERSION_API='https://services.gradle.org/versions/current'

get_latest_version() {
  curl "$CURRENT_VERSION_API" |
    sed -E '/"version"\s*:\s*"([0-9]+\.[0-9]+\.[0-9]+)"/!d' |
    sed -E 's/.*"version"\s*:\s*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/'
}

if ! $force && command_exists gradle; then
  log 'already installed'
elif ! command_exists java; then
  fatal 'java is a gradle prereq and no installation found. go get it...'
else
  log 'finding latest version from gradle api'
  version=$(get_latest_version)
  if [ $? -ne 0 ] || [[ -z "$version" ]]; then
    fatal 'could not get latest version'
  fi

  log 'installing'
  url="https://services.gradle.org/distributions/gradle-$version-bin.zip"
  atomic_download_and_extract "$url" "$install_dir" '' $force || fatal 'install failed'
  register gradle "$version" "$install_dir/bin"
fi
