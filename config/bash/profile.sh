export CLICOLOR=1
export LANG="en_US.UTF-8"

alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

alias ls="ls --color=auto"
alias ll="ls -alh"

### Cool command prompt ###
# credit: https://code.mendhak.com/simple-bash-prompt-for-developers-ps1-git/

function parse_git_dirty {
  [[ $(git status --porcelain 2>/dev/null) ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"
}

export PS1="\n\t \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
