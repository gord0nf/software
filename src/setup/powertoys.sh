#!/bin/bash

config_dir=$1
install_dir=$2
force=
if [[ "$3" == '--force' ]]; then
  force='-Force'
fi

THING=powertoys
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS"
  exit 1
fi

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "powertoys is for windows (os=$os)"
command_exists powershell || fatal " ur on windows and don't have powershell... that ain't right"

if [[ "$install_dir" != '' ]]; then
  warn 'cannot change powertoys install location'
fi

powershell "$config_dir/Install-PowerToys.ps1" "$force"
if (($? == 0)); then
  log 'loading backup DSC'
  powershell "$config_dir/Load-DSCBackup.ps1" "$config_dir/backup.json"
fi
