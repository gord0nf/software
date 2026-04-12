#!/bin/bash

config_dir=$1
install_dir=$2
force=
if [[ "$3" == '--force' ]]; then
  force='-Force'
fi

UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS"
  exit 1
fi

os=$(get_os)
if [[ "$os" != 'windows' ]]; then
  echo "[powertoys] powertoys is for windows (os=$os)"
  exit 1
elif ! command_exists powershell; then
  echo "[powertoys] ur on windows and don't have powershell... that ain't right"
  exit 1
fi

if [[ "$install_dir" != '' ]]; then
  echo "[powertoys] warning: cannot change powertoys install location"
fi

powershell "$config_dir/Install-PowerToys.ps1" "$force"
if (($? == 0)); then
  echo "[powertoys] loading backup DSC"
  powershell "$config_dir/Load-DSCBackup.ps1" "$config_dir/backup.json"
fi
