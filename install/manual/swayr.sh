#!/bin/bash

FORCE="${FORCE:-false}"

THING=swayr
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

if ! $FORCE && command_exists swayr; then
  log 'already installed'
elif ! $FORCE && ! command_exists cargo; then
  fatal 'requires cargo and not installed (go install rust)'
else
  log 'installing from cargo'
  cargo install swayr # TODO: cargo update util as recommended in docs
fi
