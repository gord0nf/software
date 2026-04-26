profiledir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
. "$profiledir/utils.sh"

export CLICOLOR=1
export LANG="en_US.UTF-8"

export SOFTWARE="$(realpath "$profiledir/../../")" # @gord0nf/software specific

### Path ------------------------------------------------------------------------------------------

if [[ -f "$SOFTWARE/software.csv" ]]; then
  skip_headers=1
  while IFS=, read -r name version paths; do
    if ((skip_headers)); then
      ((skip_headers--))
    else
      IFS='|' read -ra paths <<<"$paths"
      for path in "${paths[@]}"; do
        export PATH="$PATH:$(convert_path_if_needed --unix "$path")"
      done
    fi
  done <"$SOFTWARE/software.csv"
fi

### Aliases ---------------------------------------------------------------------------------------

alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

alias ls="ls --color=auto"
alias ll="ls -alh"
alias l="ll"

prettypath() { echo "${PATH//:/$'\n'}"; }

### Cool command prompt ---------------------------------------------------------------------------

if command_exists oh-my-posh; then
  eval "$(oh-my-posh init bash --config 'half-life')"
fi

### If in git bash on windows, prefer unix tools --------------------------------------------------

# winpath_pattern='\/[a-zA-Z]\/[Ww]indows.*'
# export PATH=$(deprioritize_paths "$winpath_pattern" "$PATH")
