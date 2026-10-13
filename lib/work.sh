# shellcheck shell=bash disable=SC2154  # цвета — из lib/ui.sh
# dot work [имя|off|list] — режим проекта: поднять всё окружение одной командой и погасить до нуля.
# Описание режима — work/<имя>.work в dotfiles (не в репозитории проекта: командный репо не засоряем):
#   dir=~/dev/kinozaBack/kinoza-back   # папка проекта
#   containers="kinoza-pg"             # docker start/stop; пусто → сервисы compose без build:
#   editor=zed                         # zed | none
# Состояние — ~/.config/dotfiles/work: имя, время старта, папка (его читает промпт, без процессов).

WORK_DEFS=${WORK_DEFS:-$DOTFILES/work}
WORK_STATE=${WORK_STATE:-$HOME/.config/dotfiles/work}
WORK_KEEP_APPS="Finder Happ Ghostty"       # обычные приложения, которые off не закрывает

work_def() {
    dir="" containers="" editor=zed
    [ -f "$WORK_DEFS/$1.work" ] || return 1
    # shellcheck source=/dev/null
    . "$WORK_DEFS/$1.work"
    dir=${dir/#\~/$HOME}
}

work_active() { [ -f "$WORK_STATE" ] && sed -n 1p "$WORK_STATE"; }

work_age() {
    local s=$(($(date +%s) - $1))
    if [ "$s" -ge 3600 ]; then echo "$((s / 3600))ч$((s % 3600 / 60))м"; else echo "$((s / 60))м"; fi
}

docker_up() { [ -S "$HOME/.orbstack/run/docker.sock" ] && docker info >/dev/null 2>&1; }

docker_wait() {
    docker_up && return 0
    info "запускаю OrbStack…"
    # после `orb stop` приложение остаётся открытым, и open -ga уже ничего не делает — движок будит orb start
    if has orb; then orb start >/dev/null 2>&1; else open -ga OrbStack; fi
    local i=0
    while [ $i -lt 60 ]; do docker info >/dev/null 2>&1 && return 0; sleep 1; i=$((i + 1)); done
    failed "OrbStack не запустился за минуту" "→ open -a OrbStack"; return 1
}

# сервисы compose без build: (postgres, redis…) — как у up
compose_deps() {
    local f
    for f in compose.yaml compose.yml docker-compose.yaml docker-compose.yml; do
        [ -s "$dir/$f" ] || continue
        docker compose -f "$dir/$f" config --format json 2>/dev/null \
            | jq -r '.services | to_entries[] | select(.value.build == null) | .key'
        return
    done
}

# обычные (не menu-bar) приложения, кроме разрешённых
extra_apps() {
    lsappinfo list 2>/dev/null | grep -E '^ *[0-9]+\) "|type=' | paste - - | grep 'type="Foreground"' \
        | sed -E 's/^ *[0-9]+\) "([^"]+)".*/\1/' | while read -r app; do
            case " $WORK_KEEP_APPS " in *" $app "*) ;; *) echo "$app" ;; esac
        done
}

# сессии Claude Code, запущенные в папке проекта
claude_in() {
    local pid cwd
    for pid in $(pgrep -f 'claude' 2>/dev/null); do
        cwd=$(lsof -a -d cwd -p "$pid" -Fn 2>/dev/null | sed -n 's/^n//p')
        case $cwd in "$1" | "$1"/*) echo "$pid" ;; esac
    done
}

work_on() {
    local name=$1 c deps
    work_def "$name" || { echo "нет режима «${name}» → dot work list" >&2; return 2; }
    [ -d "$dir" ] || { failed "нет папки $dir" "→ поправь dir= в work/$name.work"; return 1; }
    local cur; cur=$(work_active)
    if [ -n "$cur" ] && [ "$cur" != "$name" ]; then info "сначала гашу «${cur}»"; work_off_quiet "$cur"; fi

    section "◆ $name"
    deps=$(compose_deps 2>/dev/null)
    if [ -n "$containers" ] || [ -n "$deps" ]; then
        docker_wait || return 1
        for c in $containers; do
            if docker start "$c" >/dev/null 2>&1; then pass "контейнер $c"; else failed "контейнер $c не стартовал" "→ docker ps -a"; fi
        done
        if [ -z "$containers" ] && [ -n "$deps" ]; then
            # shellcheck disable=SC2086  # список сервисов
            if (cd "$dir" && docker compose up -d --wait $deps >/dev/null 2>&1); then pass "compose: $(echo $deps)"
            else failed "compose не поднялся" "→ cd $dir && docker compose up"; fi
        fi
    else
        info "контейнеров нет — OrbStack не нужен"
    fi
    if [ "$editor" = zed ]; then
        if has zed; then zed "$dir" && pass "Zed: $dir"; else warning "zed не найден" "→ brew install --cask zed"; fi
    fi
    mkdir -p "$(dirname "$WORK_STATE")"
    printf '%s\n%s\n%s\n' "$name" "$(date +%s)" "$dir" > "$WORK_STATE"
    info "погасить всё: dot work off"
    [ "$fail" -eq 0 ]
}

# остановить то, что поднял режим; без отчёта
work_off_quiet() {
    local c deps
    work_def "$1" || true
    if docker_up; then
        for c in $containers; do docker stop "$c" >/dev/null 2>&1; done
        deps=$(compose_deps 2>/dev/null)
        # shellcheck disable=SC2086
        [ -z "$containers" ] && [ -n "$deps" ] && (cd "$dir" && docker compose stop $deps >/dev/null 2>&1)
    fi
    rm -f "$WORK_STATE"
}

work_off() {
    local cur app c
    cur=$(work_active)
    section "Гашу${cur:+ «${cur}»}"
    if [ -n "$cur" ]; then
        work_def "$cur" || true
        work_off_quiet "$cur"
        [ -n "$containers" ] && pass "остановлены: $containers"
    fi
    # закрываем всё лишнее, как просит правило «только Finder, Happ, Ghostty»; menu-bar приложения не трогаем
    while read -r app; do
        [ -n "$app" ] || continue
        osascript -e "quit app \"$app\"" >/dev/null 2>&1 && pass "закрыт $app"
    done < <(extra_apps)
    # quit асинхронный: ждём, пока приложения правда закроются (до 10 с), иначе отчёт увидит их живыми
    local i=0
    while [ $i -lt 10 ] && [ -n "$(extra_apps)" ]; do sleep 1; i=$((i + 1)); done
    if docker_up; then
        c=$(docker ps -q | wc -l | tr -d ' ')
        if [ "$c" -eq 0 ]; then
            orb stop >/dev/null 2>&1 && pass "OrbStack выключен"
        else
            warning "OrbStack оставлен: работают чужие контейнеры ($c)" "→ docker ps"
        fi
    fi
    work_report
}

# что сейчас поднято; ✓ — когда кроме режима ничего не работает
work_report() {
    section "Сейчас"
    local cur apps n pids
    cur=$(work_active)
    if [ -n "$cur" ]; then
        pass "режим «${cur}» · $(work_age "$(sed -n 2p "$WORK_STATE")") · $(sed -n 3p "$WORK_STATE")"
    else
        pass "режим не включён"
    fi
    apps=$(extra_apps | tr '\n' ' ' | sed 's/ $//')
    if [ -z "$apps" ]; then pass "приложения: только $WORK_KEEP_APPS"
    else warning "лишние приложения: $apps" "→ dot work off"; fi
    if docker_up; then
        n=$(docker ps --format '{{.Names}}' | tr '\n' ' ' | sed 's/ $//')
        if [ -n "$cur" ]; then info "OrbStack: ${n:-контейнеров нет}"
        else warning "OrbStack работает без режима${n:+: $n}" "→ dot work off"; fi
    else
        pass "OrbStack выключен"
    fi
    if [ -n "$cur" ]; then
        work_def "$cur" || true
        pids=$(claude_in "$dir" | tr '\n' ' ' | sed 's/ $//')
        [ -n "$pids" ] && info "сессии Claude в проекте: $pids"
    fi
}

work_list() {
    section "Режимы (work/*.work)"
    local f n cur
    cur=$(work_active)
    for f in "$WORK_DEFS"/*.work; do
        [ -f "$f" ] || { info "пока ни одного: скопируй work/example.work.sample"; return 0; }
        n=$(basename "$f" .work)
        work_def "$n"
        if [ "$n" = "$cur" ]; then pass "$n · включён · $dir"; else info "$n · $dir${containers:+ · $containers}"; fi
    done
}

work() {
    case "${1:-}" in
        "") work_report ;;
        off) work_off ;;
        list) work_list ;;
        dir) work_def "$(work_active)" && echo "$dir" ;;
        -*) echo "dot work [имя|off|list]" >&2; return 2 ;;
        *) work_on "$1" ;;
    esac
    local code=$?
    [ "$code" = 2 ] && return 2
    [ "$fail" -eq 0 ]
}
