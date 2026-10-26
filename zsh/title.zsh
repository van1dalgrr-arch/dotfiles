# Заголовок вкладки Ghostty: значок по типу программы + что запущено, в простое — ❯ папка.
# Значки — обычный Unicode: заголовки рисует macOS шрифтом SF Pro, символы Nerd Font там — квадратики.
# Свой заголовок вместо Ghostty: shell-integration-features = no-title (ghostty/config.ghostty).
# Без процессов: только хуки zsh и printf.

autoload -Uz add-zsh-hook

_title_set() { print -rn -- $'\e]2;'"$1"$'\a'; }

# значок по имени программы
_title_icon() {
    case $1 in
        nvim|ownvim|vim|vi|hx|micro|nano|zed|code) REPLY='✎' ;;
        git|lazygit|gh|tig|gw)                     REPLY='⎇' ;;
        kubectl|k|helm|k9s|kx|kn|kubectx|kubens|stern|kind|klogs) REPLY='⎈' ;;
        ssh|mosh|scp|sftp|rsync)                   REPLY='⇄' ;;
        docker|lazydocker|dive|orb|compose)        REPLY='▣' ;;
        go|cargo|make|npm|pnpm|bun|yarn|uv|pip|brew|gotestsum|golangci-lint|cmake) REPLY=$'\u2699\ufe0e' ;;
        python|python3|ipython|node|deno|irb|lua)  REPLY='λ' ;;
        psql|pgcli|mysql|redis-cli|sqlite3|usql)   REPLY='⛁' ;;
        btop|htop|top|ctop|bandwhich)              REPLY='◔' ;;
        yazi|ranger|lf|nnn|y)                      REPLY='▤' ;;
        claude)                                    REPLY='✻' ;;
        man|less|bat|glow|tldr)                    REPLY='☰' ;;
        watchexec|air|entr|watch)                  REPLY='⟳' ;;
        *)                                         REPLY='▸' ;;
    esac
}

# простой: ❯ имя проекта (в git) или папка, дома — ⌂
_title_precmd() {
    local d=$PWD r=$PWD
    while [[ -n $r && ! -e $r/.git ]]; do r=${r%/*}; done
    if [[ $d == $HOME ]]; then _title_set '⌂ ~'
    elif [[ -n $r ]]; then                              # ❯ dotfiles, ❯ dotfiles/zsh, ❯ dotfiles/…/plugins
        local -a p=(${(s:/:)${d#$r}})
        case $#p in
            0) _title_set "❯ ${r:t}" ;;
            1) _title_set "❯ ${r:t}/${p[1]}" ;;
            *) _title_set "❯ ${r:t}/…/${p[-1]}" ;;
        esac
    else _title_set "❯ ${d:t}"
    fi
}

# запущено: значок + команда (редактор — открытый файл), не длиннее 40 символов
_title_preexec() {
    local -a w=(${(z)1})
    local cmd=${w[1]} REPLY
    [[ $cmd == (sudo|time|noglob|nocorrect|command|exec|env) && -n ${w[2]} ]] && cmd=${w[2]}
    cmd=${cmd:t}
    _title_icon $cmd
    local t
    case $REPLY in
        ✎) t="${${w[2]:-${PWD:t}}:t}" ;;          # ✎ main.go
        *) t=$1 ;;
    esac
    (( ${#t} > 40 )) && t="${t[1,39]}…"
    _title_set "$REPLY $t"
}

add-zsh-hook precmd _title_precmd
add-zsh-hook preexec _title_preexec
