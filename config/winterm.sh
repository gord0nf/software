#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

THING=winterm
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "winterm is for windows (os=$os)"
! $force && ! command_exists wt && fatal 'not installed'

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
make_directory_link "$CONFIG" "$settings_dir" $force
