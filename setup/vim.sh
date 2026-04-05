#!/bin/bash

config_dir=$1
utils=$3

. "$utils"

if ! command_exists vim; then
  echo 'no vim installation. go get it...'
  exit 1
fi

# set ~/.vimrc to source $config_dir/init.vim
echo "[vim] making sure ~/.vimrc sources config"
sed -i '/"@gord0nf\/software/d' ~/.vimrc &>/dev/null # clean all lines with special comment
vimrc=$(convert_path_if_needed --mixed "$config_dir/init.vim")
echo "source $vimrc | \"@gord0nf/software" >>~/.vimrc
