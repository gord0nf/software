#!/bin/bash

THING=git
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

command_exists git || fatal 'no git installation. go *git* it...'
log 'already installed'
