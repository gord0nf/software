#!/bin/bash

config_dir=$1
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

THING=winterm
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "winterm is for windows (os=$os)"
command_exists wt || fatal 'no wt installation found'

settings_locations=(
  "$LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe"
  "$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe"
  "$LOCALAPPDATA/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe"
  "$HOME/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe"
)
settings_dir=
for loc in "${settings_locations[@]}"; do
  if [[ -d "$loc" ]]; then
    settings_dir="$loc/LocalState"
    break
  fi
done
[[ -z "$settings_dir" ]] && fatal 'could not find wt settings dir'

log "creating directory link from '$settings_dir' to config"
make_directory_link "$config_dir" "$settings_dir" $force
