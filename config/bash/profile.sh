profiledir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
. "$profiledir/utils.sh"

export CLICOLOR=1
export LANG="en_US.UTF-8"

alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

alias ls="ls --color=auto"
alias ll="ls -alh"

# @gord0nf/software specific
export SOFTWARE="$(realpath "$profiledir/../../")"

### Cool command prompt -----------------------------------
if command_exists oh-my-posh; then
  eval "$(oh-my-posh init bash --config 'half-life')"
fi
