#!/bin/bash

# A `thing` is a software tool or some other, well, thing. Each thing should have a directory in
# `setup/`, and optionally in `config/`. `setup/${THING}/setup.sh` is the entry point that will be
# called to setup that thing. `config/${THING}` contains any config stuff for that thing that will
# be linked by the thing's setup script.

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
UTILS_SCRIPT="$SOFTWARE_ROOT/setup/utils.sh"

if (($# != 1)); then
  echo 'usage: setup.sh <thing>'
  exit 1
fi

thing=$1
thing_setup_script="$SOFTWARE_ROOT/setup/$thing/setup.sh"
thing_config="$SOFTWARE_ROOT/config/$thing"

if ! [[ -f "$thing_setup_script" ]]; then
  echo "no setup script for '$thing' (would be at '$thing_setup_script')"
  exit 1
fi

echo "[software] Running setup for '$thing'"
eval "$thing_setup_script" "$thing_config" "$UTILS_SCRIPT"
