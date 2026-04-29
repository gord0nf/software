#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

THING=git
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $force && ! command_exists git && fatal 'not installed'

log 'including config in global .gitconfig'
git config set --global include.path "$CONFIG/gitconfig"
