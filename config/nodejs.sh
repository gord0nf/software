#!/bin/bash

FORCE="${FORCE:-false}"
THING=nodejs
SOFTWARE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/.."
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && {
  ! command_exists node || ! command_exists npm
} && fatal 'not installed'

# set npm prefix
npm_prefix="$HOME/.npm-global"
log "setting npm prefix to $npm_prefix"
mkdir -p "$npm_prefix"
npm config set prefix "$npm_prefix"
add_global_path "$npm_prefix/bin" --force

# set default prettier
[[ -v PRETTIERD_DEFAULT_CONFIG ]] || set_global_env PRETTIERD_DEFAULT_CONFIG \
  "$(realpath "$SOFTWARE/.prettierrc")"
