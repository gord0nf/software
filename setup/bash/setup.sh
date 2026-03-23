#!/bin/bash

config_dir=$1

# well, you're supposedly running this with bash... so that should be setup already.

# set ~/.basrc to source $config_dir/.bashrc
echo "[bash] making sure ~/.bashrc sources config"
echo ". '$config_dir/.bashrc'" >>~/.bashrc
