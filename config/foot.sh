#!/bin/bash

FORCE="${FORCE:-false}"
THING=foot
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists foot && fatal 'not installed'

foot_dir=${XDG_CONFIG_HOME:-$HOME/.config}/foot
log "creating directory link from '$foot_dir' to config"
make_directory_link "$CONFIG" "$foot_dir"

# extra configuration -----------------------------------------------------------------------------

extended_foot="$HOME/.foot.ini" # og foot.ini looks for this
echo >"$extended_foot"

# theme
if [[ -v ymlconf_config_foot_theme ]]; then
  if [[ -f "$CONFIG/themes/$ymlconf_config_foot_theme.ini" ]]; then
    log "applying theme '$ymlconf_config_foot_theme'"
    echo "include=$CONFIG/themes/$ymlconf_config_foot_theme.ini" >>"$extended_foot"
  else
    warn "invalid theme '$ymlconf_config_foot_theme'"
  fi
fi

# font
if [[ -v FONT || -v FONT_SIZE ]]; then
  font=${FONT:-monospace}
  size=${FONT_SIZE:+:size=$FONT_SIZE}
  log "applying font $font$size"
  echo "font=$font:style=Regular$size" >>"$extended_foot"
  echo "font-bold=$font:style=Bold$size" >>"$extended_foot"
  echo "font-italic=$font:style=Italic$size" >>"$extended_foot"
fi

# opacity
if [[ -v ymlconf_config_foot_opacity ]]; then
  log "applying opacity '$ymlconf_config_foot_opacity'"
  echo -e "[colors]\nalpha=$ymlconf_config_foot_opacity" >>"$extended_foot"
fi
