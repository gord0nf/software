#!/bin/bash

# This is a template for a generic setup script that can be run by /setup.sh.
# /setup.sh expects usage like `_.sh <config_dir> <install_dir> [--force]`

config_dir=$1
install_dir=$2
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

THING=template
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

log 'this is an empty template'
