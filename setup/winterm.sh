#!/bin/bash

config_dir=$1
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

os=$(get_os)
if [[ "$os" != 'windows' ]]; then
  echo "[winterm] winterm is for windows (os=$os)" >&2
  exit 1
elif ! command_exists wt; then
  echo '[winterm] no wt installation found' >&2
  exit 1
fi

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
if [[ "$settings_dir" == '' ]]; then
  echo '[winterm] could not find wt settings dir' >&2
  exit 1
fi

echo "[winterm] creating directory link from '$settings_dir' to config"
make_directory_link "$config_dir" "$settings_dir" $force
