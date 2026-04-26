#!/bin/bash

config_dir=$1

THING=bash
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

if ! command_exists bash; then
  err "no bash installation found. but you're supposed to be running this with bash..."
  if [[ $(get_os) == "windows" ]]; then
    log 'the quickest solution for Windows is to install Git, which installs Git Bash'
  fi
  exit 1
fi

# set ~/basrc to source $config_dir/bashrc.sh
log 'making sure ~/.bashrc sources config'
sed -i '/#@gord0nf\/software/d' ~/.bashrc &>/dev/null # clean all lines with special comment
echo ". '$config_dir/bashrc.sh' #@gord0nf/software" >>~/.bashrc
