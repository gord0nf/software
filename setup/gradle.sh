#!/bin/bash

install_dir=$2
utils=$3
register=$4

. "$utils"

CURRENT_VERSION_API='https://services.gradle.org/versions/current'

get_latest_version() {
  echo '[gradle] finding latest version from gradle api' >&2
  if ! curl "$CURRENT_VERSION_API" |
    sed -E '/"version"\s*:\s*"([0-9]+\.[0-9]+\.[0-9]+)"/!d' |
    sed -E 's/.*"version"\s*:\s*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/'; then
    exit 1
  fi
}

if command_exists gradle; then
  echo '[gradle] already installed'
elif ! command_exists java; then
  echo '[gradle] java is a gradle prereq and no installation found. go get it...'
  exit 1
else
  version=$(get_latest_version)
  if [[ -z $version ]]; then exit 1; fi
  url="https://services.gradle.org/distributions/gradle-$version-bin.zip"

  if [[ -d "$install_dir" ]]; then
    old_install_dir="${install_dir}_old"
    mv "$install_dir" "$old_install_dir"
  fi

  echo "[gradle] installing"
  download_and_extract "$url" "$install_dir" && {
    if [[ -v old_install_dir ]]; then
      rm -fr "$old_install_dir"
    fi

    bash "$register" gradle "$version" "$install_dir/gradle-$version/bin"
  } || {
    echo '[gradle] install failed'
    if [[ -v old_install_dir ]]; then
      mv "$old_install_dir" "$install_dir"
    fi
    exit 1
  }
fi
