#!/bin/bash

# A `thing` is a software tool or some other, well, thing. Each thing should have a setup script
# at `setup/${THING}.sh`, and any config stuff in `config/${THING}/` (optional). The setup script
# sets the thing up and links anything in `config/${THING}`. Each setup script has independent usage
# like `${THING}.sh <config_dir> <install_dir> [--force]`

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if (($# < 1)); then
  echo 'usage: setup.sh [--force|-f] [--all] ...things'
  exit 1
fi

force=
if [[ "$1" == '--force' || "$1" == '-f' ]]; then
  force='--force'
  shift
fi

if [[ "$1" == '--all' ]]; then
  things=()
  for f in $SOFTWARE_ROOT/setup/*.sh; do
    things+=("$(basename -s '.sh' "$f")")
  done
else
  things=($@)
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
  eval "$thing_setup_script" "$thing_config" "$thing_install" $force
  if (($? == 0)); then
    printf "[software] \e[32m'$thing' setup success\e[0m\n\n"
  else
    printf "[software] \e[31m'$thing' setup failed\e[0m\n\n"
  fi
done
