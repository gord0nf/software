#!/bin/bash

install_dir=$1
force=
if [[ "$2" == '--force' ]]; then
  force='-Force'
fi

THING=powertoys
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "powertoys is for windows (os=$os)"
command_exists powershell || fatal " ur on windows and don't have powershell... that ain't right"

if [[ "$install_dir" != '' ]]; then
  warn 'cannot change powertoys install location'
fi

powershell -NoProfile "$(dirname "${BASH_SOURCE[0]}")/Install-PowerToys.ps1" "$force"
