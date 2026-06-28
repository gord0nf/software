#!/bin/bash
# based on https://docs.docker.com/engine/install/debian/

FORCE="${FORCE:-false}"
THING=docker
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

is_debian || fatal 'apt install script only supports debian right now'

apt_package_exists() {
  dpkg-query -W -f='${Status}' "$1" &>/dev/null
}

add_apt_repo() {
  [[ $EUID -eq 0 ]] || {
    warn 'requires sudo to install apt repo'
    sudo=sudo
  }

  log 'adding official gpg key'
  $sudo install -m 0755 -d /etc/apt/keyrings
  $sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  $sudo chmod a+r /etc/apt/keyrings/docker.asc

  log 'adding repo to apt sources'
  $sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
}

log 'removing potentially conflicting docker installations'
${APT:-apt} remove $(
  dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1
)

apt_package_exists docker-ce || {
  log 'installing apt repo'
  add_apt_repo
  ${APT:-apt} update
}

log 'installing docker engine'
${APT:-apt} install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log 'note: docker should be enabled through systemd now...'
