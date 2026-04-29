#!/bin/bash

THING=bash
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

if ! command_exists bash; then
  err "no bash installation found. but you're supposed to be running this with bash..."
  [[ $(get_os) == "windows" ]] &&
    log 'the quickest solution for Windows is to install Git, which installs Git Bash'
  exit 1
fi

log 'already installed'
