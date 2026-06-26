#!/bin/bash

FORCE="${FORCE:-false}"
THING=tmux
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists tmux && fatal 'not installed'

# install/update tpm
tpm_dir=~/.tmux/plugins/tpm
[[ -d "$tpm_dir" ]] && {
  log 'updating tpm'
  git -C $tpm_dir pull
} || {
  log 'installing tpm'
  rm -fr $tpm_dir # TODO: maybe a check here (if not $FORCE)?
  git clone https://github.com/tmux-plugins/tpm $tpm_dir
}

# create link tmux_dir to config
tmux_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
log "creating directory link from '$tmux_dir' to config"
make_directory_link "$CONFIG" "$tmux_dir"

# make sure ~/.tmux.conf is the entry point that sources config
log 'making sure ~/.tmux.conf sources'
src_line="source-file $tmux_dir/tmux.conf"
grep -qxF "$src_line" ~/.tmux.conf &>/dev/null || echo "$src_line" >>~/.tmux.conf

# extra configuration -----------------------------------------------------------------------------

sed -i '/#@gord0nf\/software/d' ~/.tmux.conf &>/dev/null # clean all lines with special comment

if [[ -v ymlconf_config_tmux_theme ]]; then
  case "$ymlconf_config_tmux_theme" in
  github)
    log 'applying github theme'
    echo "set -g @plugin 'infamous55/tmux-github-theme' #@gord0nf/software" >>~/.tmux.conf
    echo "set -g @color_variation 'dark_high_contrast' #@gord0nf/software" >>~/.tmux.conf
    ;;
  vscode)
    log 'applying vscode theme'
    echo "set -g @plugin 'evanzhoudev/onedarkpro-tmux' #@gord0nf/software" >>~/.tmux.conf
    ;;
  *) warn 'invalid tmux theme' ;;
  esac
fi
