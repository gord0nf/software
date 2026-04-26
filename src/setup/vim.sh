#!/bin/bash

config_dir=$1

THING=vim
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

command_exists vim || fatal 'no vim installation. go get it...'

# set ~/.vimrc to source $config_dir/init.vim
log 'making sure ~/.vimrc sources config'
sed -i '/"@gord0nf\/software/d' ~/.vimrc &>/dev/null # clean all lines with special comment
vimrc=$(convert_path_if_needed --mixed "$config_dir/init.vim")
echo "source $vimrc | \"@gord0nf/software" >>~/.vimrc
