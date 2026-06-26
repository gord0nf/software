#!/bin/bash

FORCE="${FORCE:-false}"
THING=neovim
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists nvim && fatal 'not installed'

default_nvim_dirs=(
  "$HOME/.config/nvim"
  "$HOME/AppData/Local/nvim"
)

# create link from default nvim dir(s) to config
for nvim_dir in "${default_nvim_dirs[@]}"; do
  if [[ -d "$(dirname "$nvim_dir")" ]]; then
    log "creating directory link from '$nvim_dir' to config"
    make_directory_link "$CONFIG" "$nvim_dir"
  fi
done

# set default prettier
[[ -v PRETTIERD_DEFAULT_CONFIG ]] || set_global_env PRETTIERD_DEFAULT_CONFIG \
  "$CONFIG/.prettierrc"

# extra configuration -----------------------------------------------------------------------------
# by creating a ~/.nvim.lua script that returns `settings` for config to import (looks for $NVIM_SETTINGS)

log 'writing settings object to ~/.nvim.lua'
settings="$HOME/.nvim.lua"
set_global_env NVIM_SETTINGS "$settings"
echo "settings = {}" >"$settings"

[[ "$ymlconf_config_neovim_flash" == true ]] && {
  log 'applying flash to settings'
  echo "settings.flash = true" >>"$settings"
}
[[ "$ymlconf_config_neovim_tmux" == false ]] && {
  log 'applying tmux to settings'
  echo "settings.tmux = false" >>"$settings"
}
[[ "$ymlconf_config_neovim_floatingTerminal" == true ]] && {
  log 'applying floating terminal to settings'
  echo "settings.floating_terminal = true" >>"$settings"
}
[[ -v ymlconf_config_neovim_theme ]] && {
  log 'applying theme to settings'
  echo "settings.theme = '$ymlconf_config_neovim_theme'" >>"$settings"
}

langs=
for key in $(yaml_array_keys ymlconf_config_neovim_langs_); do
  langs+="'${!key}',"
done
if ! [[ -z "$langs" ]]; then
  log 'applying langs to settings'
  echo "settings.langs = { ${langs%?} }" >>"$settings"
fi

echo "return settings" >>"$settings"
