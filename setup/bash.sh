#!/bin/bash

config_dir=$1

# well, you're supposedly running this with bash... so that should be setup already.

# set ~/basrc to source $config_dir/profile.sh
echo "[bash] making sure ~/.bashrc sources config"
sed -i '/#@gord0nf\/software/d' ~/.bashrc &>/dev/null # clean all lines with special comment
echo ". '$config_dir/profile.sh' #@gord0nf/software" >>~/.bashrc
