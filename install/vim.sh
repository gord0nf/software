#!/bin/bash

THING=vim
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

command_exists vim || fatal 'no vim installation. go get it...'
log 'already installed'
