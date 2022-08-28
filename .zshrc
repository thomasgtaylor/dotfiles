export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="common"
ZSH_DISABLE_COMPFIX=true

plugins=(
    git
    zsh-syntax-highlighting
)

export EDITOR="nvim"
export VISUAL="nvim"

source $ZSH/oh-my-zsh.sh
DISABLE_AUTO_TITLE=true
precmd() { echo -en "\033]0;$(basename `pwd`)\a" } # title bar prompt

# Aliases
alias vi="nvim"
alias vim="nvim"
alias cat="bat"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:$HOME/scripts
