export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="common"
ZSH_DISABLE_COMPFIX=true

export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
plugins=(
    git
    zsh-nvm
    Zsh-syntax-highlighting
)

export EDITOR="nvim"
export VISUAL="nvim"

source $ZSH/oh-my-zsh.sh
DISABLE_AUTO_TITLE=true
precmd() { echo -en "\033]0;$(basename `pwd`)\a" } # title bar prompt

# Aliases
alias vi="nvim"
alias vim="nvim"
