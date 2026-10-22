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
alias excalidraw="docker run --rm -it --name excalidraw -p 5000:80 excalidraw/excalidraw:latest"
alias langfuse="docker compose -f /Users/thomas.taylor/Development/github/langfuse/langfuse/docker-compose.yml pull && docker compose -f /Users/thomas.taylor/Development/github/langfuse/langfuse/docker-compose.yml up --remove-orphans"
alias beup="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/disc-backend/docker-compose.yml -f /Users/thomas.taylor/Development/github/verifiable-team/disc-backend/docker-compose.setup.yml --project-name vfi-platform up -d"
alias bedown="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/disc-backend/docker-compose.yml --project-name vfi-platform down"
alias bedb="rainfrog -M true --url mysql://root:1234@localhost:4406"
alias feup="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/disc-frontend/docker-compose.yml --project-name vfi-frontend up -d"
alias fedown="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/disc-frontend/docker-compose.yml --project-name vfi-frontend down"
alias sup="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/platform-scrapers/docker-compose.yml --project-name vfi-scrapers up -d"
alias sdown="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/platform-scrapers/docker-compose.yml --project-name vfi-scrapers down"
alias mup="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/platform-mux/docker-compose.local.yml --project-name vfi-platform-mux up -d"
alias mdown="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/platform-mux/docker-compose.local.yml --project-name vfi-platform-mux down"
alias rbup="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/platform-report-builder/docker-compose.yml --project-name vfi-report-builder up -d"
alias rbdown="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/platform-report-builder/docker-compose.yml --project-name vfi-report-builder down"
alias lup="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/disc-lambdas/docker-compose.yml --project-name vfi-lambdas up -d"
alias ldown="docker compose -f /Users/thomas.taylor/Development/github/verifiable-team/disc-lambdas/docker-compose.yml --project-name vfi-lambdas down"
alias vfiup="beup && feup && mup && rbup && lup"
alias vfidown="fedown && mdown && rbdown && ldown && bedown"
alias aidir="cd ~/Development/local/ai"
alias kill1password='killall "1Password" 2>/dev/null; killall "1Password 7" 2>/dev/null; security list-keychains | tr -d \'"\' | grep Users | xargs -n 1 security unlock-keychain; open -a "1Password"'

fish_add_path $HOME/.scripts

# uv
fish_add_path "/Users/thomas.taylor/.local/bin"
fish_add_path /opt/homebrew/opt/libpq/bin
