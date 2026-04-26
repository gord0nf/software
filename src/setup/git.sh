#!/bin/bash

config_dir=$1

THING=git
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

command_exists git || fatal 'no git installation. go *git* it...'

log 'including config in global gitconfig'
git config set --global include.path "$config_dir/gitconfig"
