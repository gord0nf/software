#!/bin/bash

# A `thing` is a software tool or some other, well, thing. Each thing should have a setup script
# at `setup/${THING}.sh`, and any config stuff in `config/${THING}/` (optional). The setup script
# sets the thing up and links anything in `config/${THING}`.

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
UTILS_SCRIPT="$SOFTWARE_ROOT/utils.sh"
REGISTER_SCRIPT="$SOFTWARE_ROOT/register.sh"

if (($# != 1)); then
  echo 'usage: setup.sh <thing>'
  exit 1
fi

thing=$1
thing_setup_script="$SOFTWARE_ROOT/setup/$thing.sh"
thing_config="$SOFTWARE_ROOT/config/$thing"
thing_install="$SOFTWARE_ROOT/installed/$thing"

if ! [[ -f "$thing_setup_script" ]]; then
  echo "no setup script for '$thing' (would be at '$thing_setup_script')"
  exit 1
fi

if ! [[ -d "$SOFTWARE_ROOT/installed" ]]; then
  mkdir "$SOFTWARE_ROOT/installed"
fi

echo "[software] Running setup for '$thing'"
eval "$thing_setup_script" "$thing_config" "$thing_install" "$UTILS_SCRIPT" "$REGISTER_SCRIPT"
