#!/bin/bash

config_dir=$1
utils=$3

. "$utils"

if ! command_exists git; then
  echo 'no git installation. go *git* it... (#dadjokes)'
  exit 1
fi

echo "[git] including config in global gitconfig"
git config set --global include.path "$config_dir/gitconfig"
