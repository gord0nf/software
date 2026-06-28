#!/bin/bash

FORCE="${FORCE:-false}"
THING=bash
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists docker && fatal 'not installed'

# check if linux user wants to be added to docker group (default to no on $FORCE)
if ! $FORCE && [[ $(get_os) == linux ]] && ! id -nG | grep -qw docker && [[ $EUID -ne 0 ]]; then
  prompt_yn "want to be added to docker group (requires sudo and log in/out)? (y/n) [n]" && {
    getent group docker &>/dev/null || sudo groupadd docker
    sudo usermod -aG docker "$(whoami)"
    warn 'make sure to log in and out again!'
  }
fi
