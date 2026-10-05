# ============================================================
#                         ZSH CONFIG
#                  macOS • Go • Git • Dev
# ============================================================

# ────────────────────────────────────────────────────────────
# PATH
# ────────────────────────────────────────────────────────────

typeset -U path PATH                             # без повторов, даже если .zshrc читается дважды
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="$PATH:${GOPATH:-$HOME/go}/bin"   # без вызова `go env` — быстрее старт
export PATH="$HOME/dotfiles/bin:$PATH"           # dot — управление dotfiles

# ────────────────────────────────────────────────────────────
# OH MY ZSH
# ────────────────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
    git
    fzf-tab
)

if [[ -f $ZSH/oh-my-zsh.sh ]]; then
    source "$ZSH/oh-my-zsh.sh"
else
    # ещё не установлен (./install.sh) — хотя бы дополнение и хуки, чтобы остальное работало
    autoload -Uz compinit add-zsh-hook && compinit
    print -P "%F{yellow}нет oh-my-zsh → ~/dotfiles/install.sh%f"
fi

# ────────────────────────────────────────────────────────────
# ТЕМА (палитра T_*, theme — переключить)
# ────────────────────────────────────────────────────────────

source "$HOME/dotfiles/zsh/theme.zsh"

# ────────────────────────────────────────────────────────────
# ПРОМПТ: свой на чистом zsh (zsh/prompt.zsh). Вернуть starship:
# PROMPT_ENGINE=starship в ~/.zshenv
# ────────────────────────────────────────────────────────────

if [[ $PROMPT_ENGINE == starship ]] && (( $+commands[starship] )); then
    eval "$(starship init zsh)"
else
    source "$HOME/dotfiles/zsh/prompt.zsh"
fi

# ────────────────────────────────────────────────────────────
# FZF
# ────────────────────────────────────────────────────────────

(( $+commands[fzf] )) && source <(fzf --zsh)

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"

# цвета — из палитры темы
export FZF_DEFAULT_OPTS=" \
--height=40% --layout=reverse --border=rounded --info=inline \
--color=bg+:#${T_OVERLAY},bg:-1,spinner:#${T_ROSE},hl:#${T_LOVE} \
--color=fg:#${T_TEXT},header:#${T_LOVE},info:#${T_IRIS},pointer:#${T_ROSE} \
--color=marker:#${T_IRIS},fg+:#${T_TEXT},prompt:#${T_IRIS},hl+:#${T_LOVE} \
--color=selected-bg:#${T_HL_MED},border:#${T_MUTED},label:#${T_TEXT}"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {}'"

# ────────────────────────────────────────────────────────────
# ZOXIDE
# ────────────────────────────────────────────────────────────

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# ────────────────────────────────────────────────────────────
# FZF-TAB (Tab → меню с превью) / ATUIN (Ctrl+R → история)
# ────────────────────────────────────────────────────────────

zstyle ':fzf-tab:*' fzf-flags --height=50% --border=rounded
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:(cat|bat|nvim|code):*' fzf-preview 'bat --color=always --line-range=:100 $realpath 2>/dev/null || eza -1 --icons --color=always $realpath'

(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# ────────────────────────────────────────────────────────────
# MODERN CLI
# ────────────────────────────────────────────────────────────

alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --group-directories-first --git"
alias la="eza -a --icons --group-directories-first"
alias lt="eza --tree --level=2 --icons"

alias cat="bat"
alias top="btop"

# ────────────────────────────────────────────────────────────
# NAVIGATION
# ────────────────────────────────────────────────────────────

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias q="exit"

# ────────────────────────────────────────────────────────────
# GO
# ────────────────────────────────────────────────────────────

alias gor="go run ."
alias gob="go build ."
# тесты через gotestsum: строка на пакет, упавшие тесты — с выводом
alias got="gotestsum --format pkgname-and-test-fails --format-icons hivis -- ./..."
alias gotw="gotestsum --watch --watch-clear --format testname"   # перезапуск при сохранении
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
alias dcup='docker compose --env-file .env -f deploy/docker-compose.yml up --build'

# ────────────────────────────────────────────────────────────
# KUBERNETES
# ────────────────────────────────────────────────────────────

alias k="kubectl"
# Дополнение kubectl кэшируется и пересобирается только после обновления kubectl
_kc="$HOME/.cache/zsh/kubectl.zsh"
if (( $+commands[kubectl] )); then
    if [[ ! -s $_kc || $commands[kubectl] -nt $_kc ]]; then
        mkdir -p "${_kc:h}" && kubectl completion zsh >| "$_kc"
    fi
    source "$_kc"
fi
unset _kc

# ────────────────────────────────────────────────────────────
# PYTHON (uv)
# ────────────────────────────────────────────────────────────

alias py="python3"
alias venv="uv venv && source .venv/bin/activate"

# ────────────────────────────────────────────────────────────
# DIRENV (.envrc в папке проекта)
# ────────────────────────────────────────────────────────────

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# ────────────────────────────────────────────────────────────
# ВЕРСИИ: Go — из Homebrew, версию проекта задаёт go.mod (go/toolchain, Go скачает сам).
# mise не нужен; если поставить его для других языков — подхватится здесь.
# ────────────────────────────────────────────────────────────

(( $+commands[mise] )) && eval "$(mise activate zsh)"

# ────────────────────────────────────────────────────────────
# SYSTEM
# ────────────────────────────────────────────────────────────

alias ff="fastfetch"
alias neofetch="fastfetch"
alias ports="lsof -i -P | grep LISTEN"
# t — tmux-сессия main: подключиться, если есть, иначе создать (с телефона по SSH: t → claude)
alias t="tmux new -A -s main"

# awake on — Mac не засыпает даже с закрытой крышкой (чтобы работать с телефона по SSH)
# awake off — как обычно · awake — показать. Нужен пароль администратора (pmset).
# Осторожно: с закрытой крышкой не класть в рюкзак — греется и садит батарею.
awake() {
    case $1 in
        on)  sudo pmset -a disablesleep 1 && print -P "%F{#$T_FOAM}☕ не засыпает, даже с закрытой крышкой%f · выключить: awake off" ;;
        off) sudo pmset -a disablesleep 0 && print -P "%F{#$T_MUTED}💤 засыпает как обычно%f" ;;
        *)   if pmset -g | command grep -q 'SleepDisabled[[:space:]]*1'; then
                 print -P "%F{#$T_FOAM}☕ awake: включено%f — не спит с закрытой крышкой · awake off"
             else
                 print -P "%F{#$T_MUTED}💤 awake: выключено%f — с закрытой крышкой засыпает · awake on"
             fi ;;
    esac
}

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

HISTSIZE=100000
SAVEHIST=100000

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

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#${T_MUTED}"
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# подсветка ввода — цвета из палитры темы:
# команды — фиолетовые жирные, пути — синие, флаги — серые, строки — сиреневые,
# связки (| && ;) и перенаправления — розовые, несуществующая команда — подчёркнута
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]="fg=#${T_ROSE},bold"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#${T_ROSE},bold"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#${T_ROSE},bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=#${T_ROSE},bold"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=#${T_ROSE},bold"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=#${T_ROSE}"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=#${T_ROSE},italic"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=#${T_ROSE},bold"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=#${T_LOVE},underline"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=#${T_GOLD},italic"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=#${T_LOVE}"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=#${T_LOVE}"
ZSH_HIGHLIGHT_STYLES[path]="fg=#${T_FOAM}"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=#${T_FOAM}"
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=#${T_FOAM},bold"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=#${T_FOAM},bold"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=#${T_SUBTLE}"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=#${T_SUBTLE}"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=#${T_GOLD}"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=#${T_GOLD}"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=#${T_GOLD}"
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=#${T_FOAM}"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=#${T_FOAM}"
ZSH_HIGHLIGHT_STYLES[assign]="fg=#${T_SUBTLE}"
ZSH_HIGHLIGHT_STYLES[comment]="fg=#${T_MUTED},italic"
ZSH_HIGHLIGHT_STYLES[default]="fg=#${T_TEXT}"
ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=#${T_ROSE}"
ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=#${T_FOAM}"
ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=#${T_GOLD}"
ZSH_HIGHLIGHT_STYLES[bracket-error]="fg=#${T_LOVE},bold"
# опасные команды — красным фоном, чтобы глаз зацепился
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' "fg=#${T_BASE},bg=#${T_LOVE},bold")
ZSH_HIGHLIGHT_PATTERNS+=('git push --force*' "fg=#${T_BASE},bg=#${T_LOVE},bold")
ZSH_HIGHLIGHT_PATTERNS+=('docker system prune*' "fg=#${T_BASE},bg=#${T_LOVE},bold")

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

# pl — все проекты ~/dev одним экраном: стек, ветка, несохранённое, давность коммита
pl() {
    local r=$'\e[0m' dim="$(_c $T_MUTED)" txt="$(_c $T_TEXT)" foam="$(_c $T_FOAM)"
    local pine="$(_c $T_PINE)" gold="$(_c $T_GOLD)" love="$(_c $T_LOVE)" iris="$(_c $T_IRIS)"
    local now=$EPOCHSECONDS d name ts rows=()
    zmodload zsh/datetime
    for d in $DEV/*(/N); do
        name=${d:t}
        [[ $name == sandbox || $name == *.worktrees ]] && continue
        ts=$(git -C "$d" log -1 --format=%ct 2>/dev/null) || ts=0
        rows+=("${ts:-0}"$'\t'"$d")
    done
    print
    local row age stack branch st ab dirty
    for row in ${(On)rows}; do
        ts=${row%%$'\t'*}; d=${row#*$'\t'}; name=${d:t}
        # стек: Go и/или Docker
        local -a dock=($d/(Dockerfile|*compose*.y(a|)ml)(N))
        stack="  "; [[ -f $d/go.mod ]] && stack="$foam"$'\U000f07d3'" "
        (( $#dock )) && stack+="$pine"$'\U000f0868'" " || stack+="  "
        if [[ ! -d $d/.git ]]; then
            printf '  %s%s %s%-20s%s   %sбез git%s\n' "$stack" "$r" "$txt" "${name[1,20]}" "$r" "$dim" "$r"
            continue
        fi
        branch=$(git -C "$d" branch --show-current 2>/dev/null)
        dirty=$(git -C "$d" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        (( dirty )) && st="$gold!$dirty" || st="$foam✓"
        ab=$(git -C "$d" rev-list --left-right --count @{u}...HEAD 2>/dev/null | awk '{s=""; if($2) s=s"⇡"$2; if($1) s=s"⇣"$1; print s}')
        if (( ts )); then
            age=$(( (now - ts) / 3600 ))
            if   (( age < 24 ));  then age="${age}ч"
            elif (( age < 336 )); then age="$(( age / 24 ))д"
            else age="$(( age / 168 ))нед"; fi
        else age="пусто"; fi
        printf '  %s%s %s%-20s%s  %s %-12s%s %-4s%s %s%-6s%s %s%s%s\n' \
            "$stack" "$r" "$txt" "${name[1,20]}" "$r" "$iris" "${branch[1,12]}" "$r" "$st" "$r" \
            "$love" "$ab" "$r" "$dim" "$age" "$r"
    done
    print
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

# up — запустить проект одной командой: OrbStack (если спит) → зависимости из compose
# (сервисы без build: — postgres, redis…) → приложение с .env (air, иначе go run)
up() {
    local compose=( (compose|docker-compose).y(a|)ml(N) )
    if [ -n "$compose" ]; then
        if ! docker info >/dev/null 2>&1; then
            echo "󰡨 запускаю OrbStack…"; open -ga OrbStack
            until docker info >/dev/null 2>&1; do sleep 1; done
        fi
        local deps=(${(f)"$(docker compose config --format json | jq -r '.services | to_entries[] | select(.value.build == null) | .key')"})
        if (( $#deps )); then
            echo "󰆼 поднимаю: ${deps[*]}"
            docker compose up -d --wait "${deps[@]}" || return
        fi
    fi
    # приложение видит .env так же, как compose (в подоболочке — shell не засоряется)
    (
        [ -f .env ] && { set -a; source .env; set +a; }
        if [ -f .air.toml ]; then air
        elif [ -d cmd/api ]; then go run ./cmd/api
        else go run .
        fi
    )
    [ -n "$compose" ] && echo "зависимости работают дальше · остановить: dcd"
}

# fkill — выбрать процесс(ы) через fzf и убить (Tab — несколько)
fkill() {
    local pids=$(ps -axo pid,%cpu,%mem,comm | sed 1d | \
        fzf -m --header="убить процесс · tab — несколько" --query="$1" | awk '{print $1}')
    [ -n "$pids" ] && echo "$pids" | xargs kill -${2:-15} && echo "убито: $(echo $pids | tr '\n' ' ')"
}

# gco — переключить ветку через fzf, в превью последние коммиты
# (заменяет алиас gco из oh-my-zsh; gco main — сразу, если ветка одна)
unalias gco 2>/dev/null
gco() {
    local b=$(git branch --all --sort=-committerdate --format='%(refname:short)' | grep -v HEAD | \
        fzf --query="$1" --select-1 --header="ветка" --preview 'git log --oneline --graph --color=always -15 {}')
    [ -n "$b" ] && git switch "${b#origin/}"
}

# port 8080 — кто слушает порт
port() { lsof -nP -iTCP:"$1" -sTCP:LISTEN; }

# serve — раздать текущую папку по http (serve 9000)
serve() { echo "→ http://localhost:${1:-8000}"; python3 -m http.server "${1:-8000}"; }

# weather — погода (weather Moscow)
weather() { curl -s "wttr.in/${1}?lang=ru&F" ; }

# ────────────────────────────────────────────────────────────
# ШПАРГАЛКА: ? или Ctrl+/
# ────────────────────────────────────────────────────────────

source "$HOME/dotfiles/zsh/cheatsheet.zsh"
source "$HOME/dotfiles/zsh/ram.zsh"
source "$HOME/dotfiles/zsh/update.zsh"
source "$HOME/dotfiles/zsh/gonew.zsh"
source "$HOME/dotfiles/zsh/backend.zsh"
source "$HOME/dotfiles/zsh/reminders.zsh"

# ────────────────────────────────────────────────────────────
# ПРИВЕТСТВИЕ: логотип macOS + коротко о системе (~35 мс).
# Только в новом окне Ghostty и если оно большое — не в quick terminal, Zed, VS Code
# ────────────────────────────────────────────────────────────

# Показываем перед первым приглашением, а не при чтении .zshrc: новое окно Ghostty
# в первые миллисекунды ещё маленькое (80×24), и проверка размера ошибочно не проходила
_greeting() {
    add-zsh-hook -d precmd _greeting                     # только один раз
    # не SHLVL: Ghostty запускается через AeroSpace и наследует SHLVL=3+, проверка никогда не проходила.
    # Флаг в окружении: новое окно — с приветствием, вложенный zsh внутри него — без.
    [[ $TERM_PROGRAM == ghostty && -z $DOTFILES_GREETED && $LINES -ge 12 && $COLUMNS -ge 60 && -z $NO_GREETING ]] || return
    export DOTFILES_GREETED=1
    (( $+commands[fastfetch] )) || return
    fastfetch -c "$HOME/dotfiles/fastfetch/greeting.jsonc"
    # совет: случайная функция из шпаргалки — постепенно запоминаются свои команды
    local -a tips=(${(f)"$(_cheat_funcs)"})
    local tip=${tips[RANDOM % $#tips + 1]}
    print -P "\n  $(_c $T_GOLD)󰌵  ${tip%%|*}%f  $(_c $T_MUTED)${tip#*|}  · ? — все команды%f"
    _reminders                                           # update давно не запускался, незапушенное
}
add-zsh-hook precmd _greeting

# ============================================================
#                         END
# ============================================================
