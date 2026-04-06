#!/bin/bash

config_dir=$1

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

default_nvim_dirs=(
  "$HOME/.config/nvim"
  "$HOME/AppData/Local/nvim"
)

# create link from default nvim dir(s) to config
for nvim_dir in "${default_nvim_dirs[@]}"; do
  if [[ -d "$(dirname "$nvim_dir")" ]]; then
    echo "[neovim] creating directory link from '$nvim_dir' to config"
    make_directory_link "$config_dir" "$nvim_dir"
  fi
done
