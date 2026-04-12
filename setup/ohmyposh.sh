#!/bin/bash

config_dir=$1
install_dir=$2
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

if ! $force && command_exists oh-my-posh; then
  echo '[ohmyposh] already installed'
else
  if [[ -d "$install_dir" ]]; then
    old_install_dir="${install_dir}_old"
    mv "$install_dir" "$old_install_dir"
  fi

  echo '[ohmyposh] running install script'

  if [[ $(get_os) == 'windows' ]]; then
    if ! command_exists powershell; then
      echo '[ohmyposh] no powershell and ur on windows? that aint right' >&2
      exit 1
    fi
    powershell "$config_dir/Install-OMP.ps1" -InstallDir "$(convert_path_if_needed --windows "$install_dir")"
  else
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$install_dir"
  fi

  if (($? == 0)); then
    if [[ -v old_install_dir ]]; then
      rm -fr "$old_install_dir"
    fi
    register ohmyposh '' "$install_dir" # Empty version 'cause it's not really that important
  else
    if [[ -v old_install_dir ]]; then
      mv "$old_install_dir" "$install_dir"
    fi
    exit 1
  fi
fi
