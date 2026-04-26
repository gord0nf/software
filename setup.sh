#!/bin/bash

# A `thing` is a software tool or some other, well, thing. Each thing should have a setup script
# at `src/setup/{THING}.sh`, and any config stuff in `src/config/{THING}/` (optional). The setup script
# sets the thing up and links anything in `src/config/{THING}`. Each setup script has independent usage
# like `{THING}.sh <config_dir> <install_dir> [--force]`

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
HELP='usage: setup.sh [--force|-f] [--all|-a] ...(things or setup scripts)'

# logging
THING=software
PREFIX_FORMAT='%s:'
. "$SOFTWARE_ROOT/src/log.sh"

is_script() {
  [[ -f "$1" ]] && IFS= LC_ALL=C read -rN2 shebang <"$1" && [ "$shebang" = '#!' ]
}

has_element() {
  local -n arr=$1
  local el=$2
  [[ " ${arr[*]} " =~ [[:space:]]${el}[[:space:]] ]]
}

add_thing() {
  if [[ -f "$SOFTWARE_ROOT/src/setup/$1.sh" ]]; then
    ! has_element things "$1" && things+=("$1")
  else
    return 1
  fi
  return 0
}

get_preset_path() {
  if [[ -f "$1" ]]; then
    echo "$1"
  elif [[ -f "$SOFTWARE_ROOT/presets/$1" ]]; then
    echo "$SOFTWARE_ROOT/presets/$1"
  else
    return 1
  fi
}

load_preset() {
  local preset_path=$1
  local line_no=0

  while IFS=$'\r\n' read -r line; do
    ((line_no++))
    if [[ "$line" =~ extends:(.+) ]]; then
      local extended=$(get_preset_path "${BASH_REMATCH[1]}") && load_preset "$extended" ||
        warn "couldn't load line $line_no for $preset_path"
    else
      add_thing "$line" || warn "couldn't load line $line_no for $preset_path"
    fi
  done <"$preset_path"
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
    if is_script "$1"; then
      ! has_element other_scripts "$1" && other_scripts+=("$1")
    elif preset_path=$(get_preset_path "$1"); then
      load_preset "$preset_path"
    else
      add_thing "$1" || {
        warn "'$1' isn't a thing, preset, or script. skipping..."
        echo # style
      }
    fi
    shift
    ;;
  esac
done

if ! [[ -d "$SOFTWARE_ROOT/installed" ]]; then
  mkdir "$SOFTWARE_ROOT/installed"
fi

for thing in "${things[@]}"; do
  thing_script="$SOFTWARE_ROOT/src/setup/$thing.sh"
  thing_config="$SOFTWARE_ROOT/src/config/$thing"
  thing_install="$SOFTWARE_ROOT/installed/$thing"

  log "thing: $thing"
  bash "$thing_script" "$thing_config" "$thing_install" $force
  log_result "'$thing' setup"
  echo # style
done

for script in "${other_scripts[@]}"; do
  log "script: $script"
  bash "$script" '' '' $force
  log_result "$script"
  echo # style
done
