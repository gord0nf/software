profiledir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source "$profiledir/utils.sh"
source "$profiledir/aliases.sh"

export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export LANG="en_US.UTF-8"

export SOFTWARE="$(realpath "$profiledir/../../../")" # @gord0nf/software specific

### Path ------------------------------------------------------------------------------------------

if [[ -f "$SOFTWARE/software.csv" ]]; then
  skip_headers=1
  while IFS=, read -r name version paths; do
    if ((skip_headers)); then
      ((skip_headers--))
    else
      paths=${paths//|/ }
      for path in "${paths[@]}"; do
        export PATH="$PATH:$(convert_path_if_needed --unix "$path")"
      done
    fi
  done <"$SOFTWARE/software.csv"
fi

### Cool command prompt ---------------------------------------------------------------------------

if command_exists oh-my-posh; then
  for conf in custom half-life takuya; do
    conf="$SOFTWARE/src/config/ohmyposh/$conf.omp.json"
    if [[ -f "$conf" ]]; then
      eval "$(oh-my-posh init bash --config "$conf")"
      break
    fi
  done
fi
