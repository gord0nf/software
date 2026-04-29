#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

THING=vim
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $force && ! command_exists vim && fatal 'not installed'

# set ~/.vimrc to source $config_dir/init.vim
log 'making sure ~/.vimrc sources config'
sed -i '/"@gord0nf\/software/d' ~/.vimrc &>/dev/null # clean all lines with special comment
vimrc=$(convert_path_if_needed --mixed "$CONFIG/init.vim")
echo "source $vimrc | \"@gord0nf/software" >>~/.vimrc
