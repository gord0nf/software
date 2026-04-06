#!/bin/bash

config_dir=$1
install_dir=$2
utils=$3
register=$4
force=$5

. "$utils"

if ! $force && command_exists oh-my-posh; then
  echo '[ohmyposh] already installed'
else
  echo '[ohmyposh] running install script'
  if [[ $(get_os) == 'windows' ]]; then
    if ! command_exists powershell; then
      echo 'no powershell and ur on windows? that aint right'
      exit 1
    fi
    powershell "$config_dir/Install-OMP.ps1" -InstallDir "$(convert_path_if_needed --windows "$install_dir")"
  else
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$install_dir"
  fi

  bash "$register" 'ohmyposh' '' "$install_dir" # Empty version 'cause it's not really that important
fi
