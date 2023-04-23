set -g hydro_symbol_prompt "➜"
set -g fish_prompt_pwd_dir_length 0
set -g hydro_color_prompt "E5C890"
set -g hydro_color_pwd "A6D189"
set -g hydro_color_git "F4B8E4"
set -g fish_greeting

set -gx EDITOR nvim
set -gx VISUAL nvim

alias vi="nvim"
alias vim="nvim"
alias cat="bat"

fish_add_path $HOME/.scripts
