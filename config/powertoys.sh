#!/bin/bash

THING=powertoys
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "powertoys is for windows (os=$os)"
command_exists powershell || fatal " ur on windows and don't have powershell... that ain't right"

log 'loading backup DSC'
powershell -NoProfile "$CONFIG/Load-DSCBackup.ps1" "$CONFIG/backup.json"
