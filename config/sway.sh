#!/bin/bash

FORCE="${FORCE:-false}"
THING=sway
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

[[ $(get_os) != 'windows' ]] || fatal "sway is for linux (os=windows)"
! $FORCE && ! command_exists sway && fatal 'not installed'

[[ $EUID -eq 0 ]] && sway_dir=/etc/sway || sway_dir=${XDG_CONFIG_HOME:-$HOME/.config}/sway
log "creating directory link from '$sway_dir' to config"
make_directory_link "$CONFIG" "$sway_dir"

# swaylock
swaylock_dir="${XDG_CONFIG_HOME:-$HOME/.config}/swaylock"
log "creating directory link from '$swaylock_dir' to swaylock config"
make_directory_link "$CONFIG/../swaylock" "$swaylock_dir"

# gtk dark mode
set_global_env GTK_THEME 'Adwaita:dark'

# env var config ----------------------------------------------------------------------------------

[[ -v ymlconf_config_sway_flavor ]] &&
  set_global_env SWAY_FLAVOR "$ymlconf_config_sway_flavor" ||
  set_global_env SWAY_FLAVOR -unset

[[ -v ymlconf_config_sway_menu ]] &&
  set_global_env SWAYMENU "$ymlconf_config_sway_menu" ||
  set_global_env SWAYMENU -unset

[[ -v ymlconf_config_sway_bar ]] &&
  set_global_env SWAYBAR "$ymlconf_config_sway_bar" ||
  set_global_env SWAYBAR -unset

# start behavior configuration --------------------------------------------------------------------
# ymlconf_config_sway_startBehavior should be login|prompt|manual

apply_start_behavior() {
  log "applying start behavior to $1"
  sed -i '/#@gord0nf\/software/d' "$1" &>/dev/null # clean all lines with special comment
  case "$ymlconf_config_sway_startBehavior" in
  login | prompt)
    echo -e "\nSWAY_START=$ymlconf_config_sway_startBehavior '$CONFIG/scripts/profile.sh' #@gord0nf/software" \
      >>"$1"
    ;;
  esac
}

# NOTE: it is important that ~/.bashrc is sourced in shell profile files, because it defines some env
# vars for sway.

# make sure profile file for login shell exists
loginshell=$(basename "$(getent passwd "$(whoami)" | cut -d: -f7)")
case "$loginshell" in
bash)
  if ! [[ -f ~/.profile || -f ~/.bash_profile ]]; then
    log 'creating minimal ~/.profile, since login shell is bash'
    echo '[ -n "$BASH_VERSION" ] && [ -f ~/.bashrc ] && . ~/.bashrc' >~/.profile
  fi
  ;;
zsh)
  if ! [[ -f ~/.zprofile ]]; then
    log 'creating minimal ~/.zprofile, since login shell is zsh'
    echo '[ -f ~/.zshrc ] && . ~/.zshrc' >~/.zprofile
  fi
  ;;
esac

# apply to profiles
profiles=(~/.profile ~/.bash_profile ~/.zprofile)
for p in "${profiles[@]}"; do
  if [[ -f "$p" ]]; then
    apply_start_behavior "$p"
    grep -qE '\.bashrc|\.zshrc' "$p" ||
      warn "it doesn't look like '$p' is sourcing .bashrc or .zshrc, which could be problematic"
  fi
done
