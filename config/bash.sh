#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

THING=bash
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $force && ! command_exists bash && fatal 'not installed'

# set ~/.bashrc to source $config_dir/bashrc.sh
log 'making sure ~/.bashrc sources config'
sed -i '/#@gord0nf\/software/d' ~/.bashrc &>/dev/null # clean all lines with special comment
echo ". '$CONFIG/bashrc.sh' #@gord0nf/software" >>~/.bashrc
