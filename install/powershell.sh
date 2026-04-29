#!/bin/bash

THING=powershell
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

flavors=()
if [[ $(get_os) == 'windows' ]]; then
  command_exists powershell || fatal "uh, you're on Windows and don't have powershell. that ain't right..."
  flavors+=("powershell")
fi
command_exists pwsh && flavors+=("pwsh")
((${#flavors[@]})) || fatal 'no powershell or pwsh installation found. go install one...'

log 'already installed'

for powershell in "${flavors[@]}"; do
  case $powershell in
  powershell)
    log 'running initial setup for Windows PowerShell'
    powershell -NoProfile -Command "$(dirname "${BASH_SOURCE[0]}")/Setup-Powershell.ps1"
    ;;
  # TODO pwsh)
  esac
done
