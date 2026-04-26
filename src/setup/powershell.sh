#!/bin/bash

config_dir=$1

THING=powershell
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

flavors=()
if [[ $(get_os) == 'windows' ]]; then
  command_exists powershell || fatal "uh, you're on Windows and don't have powershell. that ain't right..."
  flavors+=("powershell")
fi
command_exists pwsh && flavors+=("pwsh")
((${#flavors[@]})) || fatal 'no powershell or pwsh installation found. go install one...'

for powershell in "${flavors[@]}"; do

  # Initial setup

  case $powershell in
  powershell)
    log 'running initial setup for Windows PowerShell'
    powershell -NoProfile "$config_dir/Setup-WindowsPowershell.ps1"
    ;;
  # TODO pwsh)
  esac

  # Profile

  profile=$(convert_path_if_needed --unix "$(eval "$powershell -NoProfile -Command 'Write-Host \$PROFILE'")")
  if ! [[ -f "$profile" ]]; then
    warn "PS profile file doesn't exist, so creating: $profile"
    mkdir -p "$(dirname "$profile")" && touch "$profile"
  fi

  log "making sure '$profile' sources config"
  sed -i '/#@gord0nf\/software/d' "$profile" &>/dev/null # clean all lines with special comment
  echo ". '$(convert_path_if_needed --windows "$config_dir/PowerShell_profile.ps1")' #@gord0nf/software" >>"$profile"

done
