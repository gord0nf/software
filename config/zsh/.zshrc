export ZSH_CONFIG=${0:A:h}
export PROFILE="$ZSH_CONFIG/.zshrc"
export SOFTWARE="$(realpath "$ZSH_CONFIG/../../")" # @gord0nf/software specific

command_exists() {
  command -v "$1" &>/dev/null
}

workon() {
  ~/.config/scripts/tmux-$1
}

# env vars ----------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# zinit -------------------------------------------------------------------------------------------

# installation
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
command_exists fzf && zinit light Aloxaf/fzf-tab

zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# zsh settings ------------------------------------------------------------------------------------

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# bindings
bindkey -e # emacs
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '^H' backward-kill-word

# edit command line
autoload -U edit-command-line
vim-command-line () {
  local VISUAL=vim
  edit-command-line
}
zle -N vim-command-line
bindkey '^xe' vim-command-line
bindkey '^x^e' vim-command-line

# navigation
setopt autocd

# autocomplete (case-insensitive)
autoload -U compinit; compinit 
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# fzf ---------------------------------------------------------------------------------------------

if command_exists fzf; then
  source <(fzf --zsh)

  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
  zstyle ':completion:*:descriptions' format '[%d]'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
  zstyle ':completion:*' menu no
  # preview directory's content with eza when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
  # To make fzf-tab follow FZF_DEFAULT_OPTS.
  # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  # switch group using `<` and `>`
  zstyle ':fzf-tab:*' switch-group '<' '>'
fi

# oh-my-posh --------------------------------------------------------------------------------------

if command_exists oh-my-posh; then
  conf="$SOFTWARE/config/ohmyposh/${OMP_THEME:-half-life}.omp.json"
  [[ -f "$conf" ]] && eval "$(oh-my-posh init zsh --config "$conf")"
fi

# aliases -----------------------------------------------------------------------------------------

# Basic cmd line utils
alias -r ll='ls -alh --color=auto'
alias -r la='ls -A --color=auto'
alias -r l='ll -CF'
alias -r ls='ls --color=auto'

# Pretty print PATH
path() { echo "${PATH//:/$'\n'}"; }

# Git shortcuts
alias -r gl='git lg'
alias -r gbl='branch -a'
alias -r gs='git status'
alias -r ga='git add'
alias -r gc='git commit'
alias -r gagc='git add . && git commit'
alias -r gps='git push'
alias -r gpl='git pull'
alias -r grb='git rebase'
alias -r grc='git rebase --continue'
alias -r gd='git diff'
alias -r gco='git checkout'

# Common software shortcuts
alias -r nv='nvim'
alias -r py='python'
alias -r ps='ps aux'
alias -r top='htop'
alias -r server='python -m http.server 8000'
alias -r uploadserver='python -m uploadserver 8000'
alias -r ports='netstat -tuln'

# linux cmds that require sudo
alias -r apt='sudo apt'
alias -r systemctl='sudo systemctl'
alias -r light='sudo light'
