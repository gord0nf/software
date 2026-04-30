#!/bin/bash

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
HELP='usage: setup.sh [--config-only|-c] [--force|-f] [--all|-a] ...(things or setup scripts or presets)'

# logging
THING=software
PREFIX_FORMAT='%s:'
. "$SOFTWARE_ROOT/log.sh"

# helper functions --------------------------------------------------------------------------------

is_script() {
  [[ -f "$1" ]] && IFS= LC_ALL=C read -rN2 shebang <"$1" && [ "$shebang" = '#!' ]
}

has_element() {
  local -n arr=$1
  local el=$2
  [[ " ${arr[*]} " =~ [[:space:]]${el}[[:space:]] ]]
}

set_manager() {
  if [[ -f "$SOFTWARE_ROOT/managers/$1.sh" ]]; then
    manager=$1
  else
    return 1
  fi
}

add_thing() {
  if [[ -f "$SOFTWARE_ROOT/install/$manager/$1.sh" ]]; then
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

# parse args --------------------------------------------------------------------------------------

manager=
install=true
force=
things=()
other_scripts=()

# initial pass to get manager
for ((i = 0; i < $#; i++)); do
  arg=${!i}
  case "$arg" in
  --manager | -m)
    ((i++))
    arg=${!i}
    [[ -z "$arg" ]] && fatal 'expected arg for --manager'
    set_manager "$arg" || fatal "invalid manager '$arg'"
    ;;
  esac
done

# if not specified, use first usable manager
if [[ -z "$manager" ]]; then
  for manager in $(ls "$SOFTWARE_ROOT/managers/"*.sh); do
    manager=$(
      source "$manager"
      manager_can_use &>/dev/null && echo "$manager"
    )
    [[ -z "$manager" ]] || {
      set_manager "$(basename -s .sh "$manager")"
      break
    }
  done
  [[ -z "$manager" ]] && fatal 'none of the managers can be used on your system'
  log "no manager specified, defaulting to $manager"
fi

while (($# > 0)); do
  case "$1" in
  --help | -h)
    echo "$HELP"
    exit
    ;;
  --manager | -m)
    shift
    shift
    ;;
  --config-only | -c)
    install=false
    shift
    ;;
  --force | -f)
    force='--force'
    shift
    ;;
  --all | -a)
    for f in "$SOFTWARE_ROOT/install/$manager/"*.sh; do
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

# run scripts -------------------------------------------------------------------------------------

source "$SOFTWARE_ROOT/managers/$manager.sh"
manager_can_use || fatal "cannot use $manager manager on your system"

for thing in "${things[@]}"; do
  [[ "$thing" != "${things[0]}" ]] && echo # separation line

  thing_install="$SOFTWARE_ROOT/install/$manager/$thing.sh"
  thing_config="$SOFTWARE_ROOT/config/$thing.sh"
  thing_install_dir="$SOFTWARE_ROOT/installed/$thing"

  if $install; then
    log "$thing: installing"
    bash "$thing_install" "$thing_install_dir" $force && log_result "$thing install" || {
      log_result "$thing install"
      continue
    }
  fi

  if [[ -e "$thing_config" ]]; then
    log "$thing: configuring"
    bash "$thing_config" $force
    log_result "$thing config"
  elif ! $install; then
    log "no config for $thing"
  fi
done

for script in "${other_scripts[@]}"; do
  log "script: $script"
  bash "$script" '' $force
  log_result "$script"
  echo # style
done
