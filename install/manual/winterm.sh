#!/bin/bash

force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=winterm
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "winterm is for windows (os=$os)"
command_exists wt || fatal 'no wt installation found'
log 'already installed'
