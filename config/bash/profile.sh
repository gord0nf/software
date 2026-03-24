export CLICOLOR=1
export LANG="en_US.UTF-8"

alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

alias ls="ls --color=auto"
alias ll="ls -alh"

### Cool command prompt ###
if command -v oh-my-posh &>/dev/null; then
  eval "$(oh-my-posh init bash --config 'half-life')"
fi
