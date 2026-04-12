#!/bin/bash

config_dir=$1

UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

flavors=()
if [[ $(get_os) == 'windows' ]]; then
  if ! command_exists powershell; then
    echo "[powershell] uh, you're on Windows and don't have powershell. that ain't right..." >&2
    exit 1
  fi
  flavors+=("powershell")
fi
if command_exists pwsh; then
  flavors+=("pwsh")
fi
if ((${#flavors[@]} == 0)); then
  echo '[powershell] no powershell or pwsh installation found. go install one...' >&2
  exit 1
fi

for powershell in "${flavors[@]}"; do

  # Initial setup

  printf '[powershell] running initial setup for '
  case $powershell in
  powershell)
    echo 'Windows PowerShell'
    powershell "$config_dir/Setup-WindowsPowershell.ps1"
    ;;
  esac

  # Profile

  profile=$(convert_path_if_needed --unix "$(eval "$powershell -NoProfile -Command 'Write-Host \$PROFILE'")")
  if ! [[ -f "$profile" ]]; then
    echo "[powershell] PS profile file doesn't exist: $profile" >&2
    exit 1
  fi

  echo "[powershell] making sure '$profile' sources config"
  sed -i '/#@gord0nf\/software/d' "$profile" &>/dev/null # clean all lines with special comment
  echo ". '$(convert_path_if_needed --windows "$config_dir/PowerShell_profile.ps1")' #@gord0nf/software" >>"$profile"

done
