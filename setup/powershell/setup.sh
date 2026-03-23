#!/bin/bash

config_dir=$1

# utils

command_exists() {
  local command=$1
  if command -v $command &>/dev/null; then
    return 0
  fi
  return 1
}
convert_unix_path() {
  local path=$1
  local switch='--windows'
  if [[ $2 == '--to' ]]; then arg='--unix'; fi

  if command_exists wslpath; then
    echo "$(wslpath $switch "$path")"
  elif command_exists cygpath; then
    echo "$(cygpath $switch "$path")"
  else
    echo "$path"
  fi
}

# logic

flavors=()
if grep -qEi "(Microsoft|WSL|MSYS)" /proc/version &>/dev/null; then
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
  profile=$(convert_unix_path "$(eval "$powershell -Command 'Write-Host \$PROFILE'")" --to)
  if ! [[ -f "$profile" ]]; then
    echo "PS profile file doesn't exist: $profile"
    exit 1
  fi

  echo "[powershell] making sure '$profile' sources config"
  echo ". '$(convert_unix_path "$config_dir/PowerShell_profile.ps1")'" >>"$profile"
done
