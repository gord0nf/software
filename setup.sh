#!/bin/bash

# A `thing` is a software tool or some other, well, thing. Each thing should have a setup script
# at `src/setup/{THING}.sh`, and any config stuff in `src/config/{THING}/` (optional). The setup script
# sets the thing up and links anything in `src/config/{THING}`. Each setup script has independent usage
# like `{THING}.sh <config_dir> <install_dir> [--force]`

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
HELP='usage: setup.sh [--force|-f] [--all|-a] ...(things or setup scripts)'
PREFIX="[\033[3msoftware\033[0m]"

is_script() {
  [[ -f "$1" ]] && IFS= LC_ALL=C read -rN2 shebang <"$1" && [ "$shebang" = '#!' ]
}

has_element() {
  local -n arr=$1
  local el=$2
  [[ " ${arr[*]} " =~ [[:space:]]${el}[[:space:]] ]]
}

force=
things=()
other_scripts=()

while (($# > 0)); do
  case "$1" in
  --help | -h)
    echo "$HELP"
    exit
    ;;
  --force | -f)
    force='--force'
    shift
    ;;
  --all | -a)
    for f in "$SOFTWARE_ROOT/src/setup/"*.sh; do
      thing=$(basename -s '.sh' "$f")
      if ! has_element things "$thing"; then
        things+=("$thing")
      fi
    done
    shift
    ;;
  -*)
    echo "$HELP" >&2
    exit 1
    ;;
  *)
    if is_script "$1" && ! has_element other_scripts "$1"; then
      other_scripts+=("$1")
    elif [[ -f "$SOFTWARE_ROOT/src/setup/$1.sh" ]] && ! has_element things "$1"; then
      things+=("$1")
    else
      printf "$PREFIX \033[31m'$1' isn't a thing or a script\033[0m\n" >&2
      printf "$PREFIX \033[33mskipping '$1'\033[0m\n"
    fi
    shift
    ;;
  esac
done

if ! [[ -d "$SOFTWARE_ROOT/installed" ]]; then
  mkdir "$SOFTWARE_ROOT/installed"
fi

for thing in "${things[@]}"; do
  thing_setup_script="$SOFTWARE_ROOT/src/setup/$thing.sh"
  thing_config="$SOFTWARE_ROOT/src/config/$thing"
  thing_install="$SOFTWARE_ROOT/installed/$thing"

  if bash "$thing_setup_script" "$thing_config" "$thing_install" $force; then
    printf "$PREFIX \e[32m'$thing' setup success\e[0m\n\n"
  else
    printf "$PREFIX \e[31m'$thing' setup failed\e[0m\n\n"
  fi
done

for script in "${other_scripts[@]}"; do
  if bash "$script" '' '' $force; then
    printf "$PREFIX \e[32m$script success\e[0m\n\n"
  else
    printf "$PREFIX \e[31m$thing failed\e[0m\n\n"
  fi
done
