#!/bin/bash

config_dir=$1

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

if ! command_exists bash; then
  echo "no bash installation found. but you're supposed to be running this with bash..."
  if [[ $(get_os) == "windows" ]]; then
    echo 'the quickest solution for Windows is to install Git, which installs Git Bash'
  fi
  exit 1
fi

# set ~/basrc to source $config_dir/profile.sh
echo "[bash] making sure ~/.bashrc sources config"
sed -i '/#@gord0nf\/software/d' ~/.bashrc &>/dev/null # clean all lines with special comment
echo ". '$config_dir/profile.sh' #@gord0nf/software" >>~/.bashrc
