# Basic cmd line utils
alias ll='ls -alh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# File operations
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'

# Pretty print PATH
path() { echo "${PATH//:/$'\n'}"; }

# Common software shortcuts
alias nv='nvim'
alias py='python'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git lg'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# System information shortcuts
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='htop'

# Other dev utils
alias serve='python -m http.server 8000'
alias uploadserve='python -m uploadserver 8000'
alias ports='netstat -tuln'
alias myip='curl -s ifconfig.me && echo'
