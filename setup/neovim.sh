#!/bin/bash

config_dir=$1
utils=$2

. "$utils"

default_nvim_dirs=(
  "$HOME/.config/nvim"
  "$HOME/AppData/Local/nvim"
)

# create link from default nvim dir(s) to config
for nvim_dir in "${default_nvim_dirs[@]}"; do
  if [[ -d "$(dirname "$nvim_dir")" ]]; then
    echo "[neovim] creating directory link from '$nvim_dir' to config"
    if ! is_windows; then
      ln -s "$config_dir" "$nvim_dir"
    else
      link=$(convert_path_if_needed --windows "$nvim_dir")
      actual=$(convert_path_if_needed --windows "$config_dir")
      command="cmd /C'mklink /j ""$link"" ""$actual""'"
      printf 'mklink: '
      eval "$command"
    fi
  fi
done
