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
    fzf-tab
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
# FZF-TAB (Tab → меню с превью) / ATUIN (Ctrl+R → история)
# ────────────────────────────────────────────────────────────

zstyle ':fzf-tab:*' fzf-flags --height=50% --border=rounded
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:(cat|bat|nvim|code):*' fzf-preview 'bat --color=always --line-range=:100 $realpath 2>/dev/null || eza -1 --icons --color=always $realpath'

eval "$(atuin init zsh --disable-up-arrow)"

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
alias gol="golangci-lint run ./..."
alias gotc="go test -cover ./..."
alias gorun="air"   # hot-reload (air init — создать .air.toml)
alias gdbg="dlv debug ."

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
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias dprune="docker system prune -f"
alias lzd="lazydocker"

# ────────────────────────────────────────────────────────────
# KUBERNETES
# ────────────────────────────────────────────────────────────

alias k="kubectl"
source <(kubectl completion zsh)

# ────────────────────────────────────────────────────────────
# PYTHON (uv)
# ────────────────────────────────────────────────────────────

alias py="python3"
alias venv="uv venv && source .venv/bin/activate"

# ────────────────────────────────────────────────────────────
# DIRENV (.envrc в папке проекта)
# ────────────────────────────────────────────────────────────

eval "$(direnv hook zsh)"

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

# ────────────────────────────────────────────────────────────
# ФУНКЦИИ
# ────────────────────────────────────────────────────────────

# yazi: при выходе остаёмся в папке, где закрыли
y() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
    yazi "$@" --cwd-file="$tmp"
    cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd -- "$cwd"
    rm -f -- "$tmp"
}

# p — выбрать проект из ~/dev через fzf и перейти в него (p kino — сразу с фильтром)
export DEV="$HOME/dev"
alias dev='cd $DEV'
p() {
    local d=$(fd --type d --max-depth 1 --exclude sandbox . "$DEV" | sed "s|$DEV/||;s|/$||" | \
        fzf --query="$1" --select-1 --header="проекты" --preview "eza -1 --icons --color=always $DEV/{}; echo; git -C $DEV/{} log --oneline -5 2>/dev/null")
    [ -n "$d" ] && cd "$DEV/$d"
}

mkcd() { mkdir -p "$1" && cd "$1"; }

# killport 8080 — убить процесс на порту
killport() { lsof -ti tcp:"$1" | xargs kill -9 2>/dev/null && echo "порт $1 свободен" || echo "на порту $1 ничего нет"; }

# dsh — зайти в контейнер, выбрав его через fzf
dsh() {
    local c=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' | fzf --header="контейнер" | cut -f1)
    [ -n "$c" ] && docker exec -it "$c" sh -c '[ -x /bin/bash ] && exec bash || exec sh'
}

# dlogs — логи контейнера через fzf
dlogs() {
    local c=$(docker ps --format '{{.Names}}' | fzf --header="логи")
    [ -n "$c" ] && docker logs -f --tail 200 "$c"
}

# gonew myapi — новый проект на Gin с air и git
gonew() {
    [ -z "$1" ] && { echo "usage: gonew <name>"; return 1; }
    cd "$DEV" || return
    mkdir -p "$1" && cd "$1" || return
    go mod init "$1" && go get github.com/gin-gonic/gin
    mkdir -p cmd/api internal
    command cat > cmd/api/main.go <<'GO'
package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "pong"})
	})
	r.Run(":8080")
}
GO
    air init >/dev/null && sed -i '' 's|cmd = "go build -o ./tmp/main ."|cmd = "go build -o ./tmp/main ./cmd/api"|' .air.toml
    printf "tmp/\nbin/\n.env\n" > .gitignore
    go mod tidy && git init -q && echo "готово: запусти air → http://localhost:8080/ping"
}

# ============================================================
#                         END
# ============================================================
alias dcup='docker compose --env-file .env -f deploy/docker-compose.yml up --build'
