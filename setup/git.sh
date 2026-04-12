#!/bin/bash

config_dir=$1

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

if ! command_exists git; then
  echo 'no git installation. go *git* it... (#dadjokes)' >&2
  exit 1
fi

echo "[git] including config in global gitconfig"
git config set --global include.path "$config_dir/gitconfig"
