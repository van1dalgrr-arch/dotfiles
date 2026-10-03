# ============================================================
#                         ZSH CONFIG
#                  macOS • Go • Git • Dev
# ============================================================

# ────────────────────────────────────────────────────────────
# PATH
# ────────────────────────────────────────────────────────────

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"

# ────────────────────────────────────────────────────────────
# OH MY ZSH
# ────────────────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
    git
)

source "$ZSH/oh-my-zsh.sh"

# ────────────────────────────────────────────────────────────
# STARSHIP
# ────────────────────────────────────────────────────────────

eval "$(starship init zsh)"

# ────────────────────────────────────────────────────────────
# FZF
# ────────────────────────────────────────────────────────────

source <(fzf --zsh)

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"

# Catppuccin Mocha
export FZF_DEFAULT_OPTS=" \
--height=40% --layout=reverse --border=rounded --info=inline \
--color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a,border:#6c7086,label:#cdd6f4"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {}'"

# ────────────────────────────────────────────────────────────
# ZOXIDE
# ────────────────────────────────────────────────────────────

eval "$(zoxide init zsh)"

# ────────────────────────────────────────────────────────────
# MODERN CLI
# ────────────────────────────────────────────────────────────

export EZA_CONFIG_DIR="$HOME/.config/eza"
alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --group-directories-first --git"
alias la="eza -a --icons --group-directories-first"
alias lt="eza --tree --level=2 --icons"

export BAT_THEME="Catppuccin Mocha"
alias cat="bat"
alias top="btop"

# ────────────────────────────────────────────────────────────
# NAVIGATION
# ────────────────────────────────────────────────────────────

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias c="clear"
alias q="exit"

# ────────────────────────────────────────────────────────────
# GO
# ────────────────────────────────────────────────────────────

alias gor="go run ."
alias gob="go build ."
alias got="go test ./..."
alias gotv="go test -v ./..."
alias gof="gofmt -w ."
alias gom="go mod tidy"

# ────────────────────────────────────────────────────────────
# GIT
# ────────────────────────────────────────────────────────────

alias gs="git status"
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gcl="git clone"

alias lg="git log --oneline --graph --decorate --all"
alias gg="lazygit"
alias gd="git diff"
alias gds="git diff --staged"

# ────────────────────────────────────────────────────────────
# DOCKER
# ────────────────────────────────────────────────────────────

alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias dex="docker exec -it"

# ────────────────────────────────────────────────────────────
# SYSTEM
# ────────────────────────────────────────────────────────────

alias ff="fastfetch"
alias neofetch="fastfetch"
alias ports="lsof -i -P | grep LISTEN"

# ────────────────────────────────────────────────────────────
# SAFETY
# ────────────────────────────────────────────────────────────

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# ────────────────────────────────────────────────────────────
# HISTORY
# ────────────────────────────────────────────────────────────

HISTFILE="$HOME/.zsh_history"

HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# ────────────────────────────────────────────────────────────
# COMPLETION
# ────────────────────────────────────────────────────────────

# compinit уже вызывает oh-my-zsh, здесь только стиль
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ────────────────────────────────────────────────────────────
# OPTIONS
# ────────────────────────────────────────────────────────────

setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS

# ────────────────────────────────────────────────────────────
# PLUGINS (syntax-highlighting — строго последним)
# ────────────────────────────────────────────────────────────

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Catppuccin Mocha для подсветки
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#89dceb'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#94e2d5'
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#f38ba8'

# ============================================================
#                         END
# ============================================================
alias dcup='docker compose --env-file .env -f deploy/docker-compose.yml up --build'
