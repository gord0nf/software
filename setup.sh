#!/bin/bash

# A `thing` is a software tool or some other, well, thing. Each thing should have a setup script
# at `setup/${THING}.sh`, and any config stuff in `config/${THING}/` (optional). The setup script
# sets the thing up and links anything in `config/${THING}`.

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
UTILS_SCRIPT="$SOFTWARE_ROOT/utils.sh"
REGISTER_SCRIPT="$SOFTWARE_ROOT/register.sh"

if (($# < 1)); then
  echo 'usage: setup.sh [--all] ...things'
  exit 1
fi

things=($@)

if [[ "${things[0]}" == '--all' ]]; then
  things=()
  for f in $SOFTWARE_ROOT/setup/*.sh; do
    things+=("$(basename -s '.sh' "$f")")
  done
fi

if ! [[ -d "$SOFTWARE_ROOT/installed" ]]; then
  mkdir "$SOFTWARE_ROOT/installed"
fi

for thing in "${things[@]}"; do
  thing_setup_script="$SOFTWARE_ROOT/setup/$thing.sh"
  thing_config="$SOFTWARE_ROOT/config/$thing"
  thing_install="$SOFTWARE_ROOT/installed/$thing"

  if ! [[ -f "$thing_setup_script" ]]; then
    echo "[software] no setup script for '$thing' (would be at '$thing_setup_script')"
    echo "[software] skipping '$thing'"
    continue
  fi

  echo "[software] running setup for '$thing'"
  eval "$thing_setup_script" "$thing_config" "$thing_install" "$UTILS_SCRIPT" "$REGISTER_SCRIPT"
  if (($? == 0)); then
    printf "[software] \e[32m'$thing' setup success\e[0m\n\n"
  else
    printf "[software] \e[31m'$thing' setup failed\e[0m\n\n"
  fi
done
