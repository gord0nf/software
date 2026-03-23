#!/bin/bash

config_dir=$1
utils=$2

. "$utils"

flavors=()
if is_windows; then
  if ! command_exists powershell; then
    echo "uh, you're on Windows and don't have powershell. that ain't right..."
    exit 1
  fi
  flavors+=("powershell")
fi
if command_exists pwsh; then
  flavors+=("pwsh")
fi
if ((${#flavors[@]} == 0)); then
  echo 'no powershell or pwsh installation found. go install em...'
  exit 1
fi

for powershell in "${flavors[@]}"; do
  profile=$(convert_path_if_needed --unix "$(eval "$powershell -Command 'Write-Host \$PROFILE'")")
  if ! [[ -f "$profile" ]]; then
    echo "PS profile file doesn't exist: $profile"
    exit 1
  fi

  echo "[powershell] making sure '$profile' sources config"
  echo ". '$(convert_path_if_needed --windows "$config_dir/PowerShell_profile.ps1")'" >>"$profile"
done
