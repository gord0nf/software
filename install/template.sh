#!/bin/bash

# This is a template for a generic setup script that can be run by /setup.sh.
# /setup.sh expects usage like `_.sh <config_dir> <install_dir> [--force]`

install_dir=$1
force=false
if [[ "$2" == '--force' ]]; then
  force=true
fi

THING=template
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

log 'this is an empty template'
