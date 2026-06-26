#!/bin/bash

FORCE="${FORCE:-false}"
THING=brave
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

apt_package_exists() {
  dpkg-query -W -f='${Status}' "$1" &>/dev/null
}

add_apt_sources() {
  [[ $EUID -eq 0 ]] && curl='curl' || {
    warn 'requires sudo to install apt source'
    curl='sudo curl'
  }

  $curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  $curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
}

apt_package_exists brave-browser || {
  log 'installing apt sources'
  add_apt_sources
  ${APT:-apt} update
}

log 'installing brave-browser'
${APT:-apt} install -y brave-browser
