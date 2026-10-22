# Use the terminal palette for shell and prompt colors.
source ~/.config/fish/conf.d/zz-terminal-colors.fish

set -g hydro_symbol_prompt "➜"
set -g fish_prompt_pwd_dir_length 0
set -g hydro_color_prompt normal
set -g hydro_color_pwd brgreen
set -g hydro_color_git brmagenta
set -g fish_greeting

set -gx EDITOR nvim
set -gx VISUAL nvim

alias vi="nvim"
alias vim="nvim"
alias cat="bat"

fish_add_path $HOME/.scripts
