#!/bin/bash

FORCE="${FORCE:-false}"
THING=rust
# CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && {
  ! command_exists rustc || ! command_exists cargo
} && fatal 'not installed'

add_global_path "$HOME/.cargo/bin"
