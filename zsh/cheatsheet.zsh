# ============================================================
#   ? / Ctrl+/ — шпаргалка: хоткеи, функции и все алиасы.
#   Enter на команде — вставить её в строку ввода.
#   Новый хоткей — допиши строку в _cheat_static (раздел|клавиши|что делает).
# ============================================================

_cheat_static() {
    command cat <<'EOF'
AeroSpace|alt-enter|новый терминал
AeroSpace|alt-e|файловый менеджер (yazi)
AeroSpace|alt-q|закрыть окно
AeroSpace|alt-h/j/k/l|фокус влево/вниз/вверх/вправо
AeroSpace|alt-shift-h/j/k/l|переместить окно
AeroSpace|alt-1..9|перейти на стол
AeroSpace|alt-shift-1..9|унести окно на стол
AeroSpace|alt-tab|предыдущий стол
AeroSpace|alt-shift-tab|стол на другой монитор
AeroSpace|alt-/|раскладка: плитки (гор/верт)
AeroSpace|alt-,|раскладка: аккордеон
AeroSpace|alt-shift-f|на весь экран
AeroSpace|alt-shift-space|плавающее ↔ плитка
AeroSpace|alt-- / alt-=|уже / шире
AeroSpace|alt-r|режим ресайза (hjkl, esc)
AeroSpace|alt-shift-;|сервис: r сброс, f float, ⌫ закрыть остальные
AeroSpace|alt-shift-c|перечитать конфиг
Ghostty|ctrl-`|выпадающий терминал (из любого приложения)
Ghostty|cmd-d / cmd-shift-d|сплит вправо / вниз
Ghostty|cmd-alt-стрелки|перейти между сплитами
Ghostty|cmd-shift-enter|развернуть сплит
Ghostty|cmd-shift-e|выровнять сплиты
Ghostty|cmd-shift-p|палитра команд
Ghostty|cmd-k|очистить экран
Ghostty|cmd-w|закрыть сплит / вкладку / окно
Ghostty|cmd-shift-w|закрыть окно целиком
Shell|ctrl-d / q|выйти из shell (закроет окно)
Shell|ctrl-r|история (atuin)
Shell|ctrl-t|найти файл (fzf + превью)
Shell|alt-c|перейти в папку (fzf)
Shell|tab|автодополнение с превью (fzf-tab), < > — группы
Shell|ctrl-/|эта шпаргалка
Shell|z <часть пути>|прыжок в папку (zoxide)
EOF
}

_cheat_funcs() {
    command cat <<'EOF'
p|выбрать проект из ~/dev (p kino — с фильтром)
y|yazi, при выходе остаёмся в папке
gonew|новый Gin-проект с air: gonew myapi
dsh|зайти в контейнер (fzf)
dlogs|логи контейнера (fzf)
killport|освободить порт: killport 8080
mkcd|создать папку и зайти
fkill|убить процесс (fzf)
gco|переключить ветку (fzf, с логом)
port|кто слушает порт: port 8080
serve|раздать текущую папку по http
weather|погода в терминале
ram|кто ест память (по приложениям): ram 15
update|обслуживание: brew, Go-инструменты, мусор Docker, иконки
dot|dot doctor — всё ли на месте · dot install/update/theme/wall/check
up|запустить проект: compose-зависимости + air/go run с .env
pl|все проекты ~/dev: стек, ветка, изменения, давность
db|pgcli к базе проекта (DATABASE_URL / .env)
vuln|уязвимости: govulncheck + trivy
load|нагрузочный тест: load [url] [сек] [соединений]
theme|сменить тему терминала и обоев: theme kanagawa / theme rose-pine
wall|сменить обои с превью: wall · petals, neon, rain, eclipse, orbit, code…
EOF
}

_cheat_lines() {
    local r=$'\e[0m' dim="$(_c $T_MUTED)"
    local -A col=(
        AeroSpace "$(_c $T_IRIS)"
        Ghostty   "$(_c $T_ROSE)"
        Shell     "$(_c $T_FOAM)"
        func      "$(_c $T_PINE)"
        alias     "$(_c $T_SUBTLE)"
    )
    local sec key desc
    _cheat_static | while IFS='|' read -r sec key desc; do
        printf '%s%-10s%s %-22s %s%s%s\n' "${col[$sec]}" "$sec" "$r" "$key" "$dim" "$desc" "$r"
    done
    _cheat_funcs | while IFS='|' read -r key desc; do
        printf '%s%-10s%s %-22s %s%s%s\n' "${col[func]}" "func" "$r" "$key" "$dim" "$desc" "$r"
    done
    # алиасы берём из живой сессии — шпаргалка не устаревает
    local name
    for name in ${(ko)aliases}; do
        [[ $name == (-|_|[0-9]|which-command|run-help) ]] && continue
        printf '%s%-10s%s %-22s %s%s%s\n' "${col[alias]}" "alias" "$r" "$name" "$dim" "${aliases[$name]}" "$r"
    done
}

# Печатает выбранную команду (для func/alias), для хоткеев — ничего
_cheat_pick() {
    local pick
    pick=$(_cheat_lines | fzf --ansi --no-sort --query="$*" \
        --height=80% --layout=reverse --border=rounded \
        --border-label=' 󰌌  шпаргалка ' --border-label-pos=3 \
        --prompt='  ' --pointer='❯' \
        --header='enter — вставить команду · esc — выход' \
        --color="border:#${T_IRIS},label:#${T_ROSE},header:#${T_MUTED}") || return
    local -a f=(${=pick})
    [[ ${f[1]} == (func|alias) ]] && print -r -- "${f[2]}"
}

cheat() {
    local cmd=$(_cheat_pick "$@")
    [[ -n $cmd ]] && print -z -- "$cmd "
}
alias '?'='cheat'

# Ctrl+/ — шпаргалка, выбранная команда сразу в строке ввода
_cheat_widget() {
    local cmd=$(_cheat_pick </dev/tty)
    [[ -n $cmd ]] && { BUFFER="$cmd "; CURSOR=$#BUFFER; }
    zle reset-prompt
}
zle -N _cheat_widget
bindkey '^_' _cheat_widget
