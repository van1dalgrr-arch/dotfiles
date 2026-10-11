# orbstack — OrbStack в терминале: баннер, статус и меню (fzf); всё то же — подкомандами без меню.
# Контейнер не указан — выбирается из списка. Docker поднимается сам (docker() в .zshrc)

_ob_logo=(
'█████ ████  ████  █████ █████ █████ █████ █   █'
'█   █ █   █ █   █ █       █   █   █ █     █  █ '
'█   █ ████  ████  █████   █   █████ █     ███  '
'█   █ █  █  █   █     █   █   █   █ █     █  █ '
'█████ █   █ ████  █████   █   █   █ █████ █   █'
)

_ob_rgb() { print -n "$((16#${1:0:2}));$((16#${1:2:2}));$((16#${1:4:2}))"; }

# логотип с градиентом акцент → синий и «потёками» вниз, как у краски
_ob_banner() {
    local -a a b; a=(${(s:;:)"$(_ob_rgb $T_ROSE)"}); b=(${(s:;:)"$(_ob_rgb $T_FOAM)"})
    local w=${#_ob_logo[1]} line i ch k out len r=$'\e[0m'
    local -a col
    for ((i = 1; i <= w; i++)); do       # цвет колонки
        col[i]="$(( a[1] + (b[1] - a[1]) * (i - 1) / (w - 1) ));$(( a[2] + (b[2] - a[2]) * (i - 1) / (w - 1) ));$(( a[3] + (b[3] - a[3]) * (i - 1) / (w - 1) ))"
    done
    print
    for line in $_ob_logo; do
        out="  "
        for ((i = 1; i <= w; i++)); do
            ch=${line[i]}
            [[ $ch == ' ' ]] && out+=' ' || out+=$'\e[38;2;'"${col[i]}m$ch"
        done
        print -r -- "$out$r"
    done
    # потёки: под каждой закрашенной колонкой нижней строки — 0–3 клетки ▓▒░, всё темнее
    local shade=(▓ ▒ ░) bottom=${_ob_logo[-1]} c1 c2 c3
    for k in 1 2 3; do
        out="  "
        for ((i = 1; i <= w; i++)); do
            len=$(( (i * 7 + i / 3 * 5) % 4 ))          # длина потёка — от номера колонки, без рандома
            if [[ ${bottom[i]} == █ ]] && (( k <= len )); then
                c1=(${(s:;:)col[i]})
                out+=$'\e[38;2;'"$(( c1[1] * (4 - k) / 4 ));$(( c1[2] * (4 - k) / 4 ));$(( c1[3] * (4 - k) / 4 ))m${shade[k]}"
            else out+=' '; fi
        done
        print -r -- "$out$r"
    done
}

_ob_status() {
    local ok="$(_c $T_FOAM)" warn="$(_c $T_GOLD)" dim="$(_c $T_MUTED)" acc="$(_c $T_ROSE)" r=$'\e[0m'
    print "  ${dim}OrbStack $(orb version 2>/dev/null | awk '/^Version/{print $2}') · Docker $(command docker --version 2>/dev/null | awk '{print $3}' | tr -d ,)${r}"
    print
    if [[ -S ~/.orbstack/run/docker.sock ]] && command docker info >/dev/null 2>&1; then
        local run=$(command docker ps -q | wc -l | tr -d ' ') all=$(command docker ps -aq | wc -l | tr -d ' ')
        local img=$(command docker images -q | sort -u | wc -l | tr -d ' ')
        local disk=$(command docker system df --format '{{.Size}}' 2>/dev/null | head -1)
        print "  ${ok}✓${r} движок запущен"
        print "  ${ok}✓${r} контейнеры: ${acc}$run${r} работают · $all всего"
        print "  ${ok}✓${r} образы: $img · ${disk:-0B} на диске"
    else
        print "  ${warn}○${r} OrbStack выключен ${dim}— включится сам при первом действии${r}"
    fi
    local compose=( (compose|docker-compose).y(a|)ml(N) )
    (( $#compose )) && print "  ${acc}⚑${r} проект: ${PWD:t} ${dim}($compose[1])${r}"
    print
}

# выбор контейнера: имя · статус · образ · порты, справа — последние строки лога
_ob_pick() {
    local all=${1:-a}
    docker ps -$all --format '{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}' 2>/dev/null |
        column -t -s $'\t' |
        fzf --height=60% --reverse --prompt='контейнер ❯ ' --header='enter — выбрать · esc — назад' \
            --preview 'docker logs --tail 40 {1} 2>&1' --preview-window=down:45%:wrap |
        awk '{print $1}'
}

_ob_sh() { docker exec -it "$1" sh -c 'command -v bash >/dev/null && exec bash || exec sh'; }

_ob_container() {
    local c=${1:-$(_ob_pick)}; [[ -n $c ]] || return
    local state=$(command docker inspect -f '{{.State.Status}}' "$c" 2>/dev/null)
    local -a acts=('логи' 'терминал' 'перезапустить')
    [[ $state == running ]] && acts+=('остановить') || acts+=('запустить')
    acts+=('подробно' 'удалить')
    local act=$(print -l $acts | fzf --height=40% --reverse --prompt="$c ❯ " --header="состояние: $state")
    case $act in
        логи)          docker logs -f --tail 200 "$c" ;;
        терминал)      _ob_sh "$c" ;;
        перезапустить) docker restart "$c" >/dev/null && echo "↻ $c" ;;
        остановить)    docker stop "$c" >/dev/null && echo "■ $c" ;;
        запустить)     docker start "$c" >/dev/null && echo "▶ $c" ;;
        подробно)      docker inspect "$c" | jq '.[0] | {Name, Image: .Config.Image, State: .State.Status, Started: .State.StartedAt, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[] | {Source, Destination}], Env: .Config.Env}' | bat -l json --style=plain --paging=never ;;
        удалить)       read -q "?удалить $c? [y/N] " && { echo; docker rm -f "$c" >/dev/null && echo "✗ $c"; } || echo ;;
    esac
}

_ob_images() {
    local img=$(docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}' | column -t -s $'\t' |
        fzf --height=60% --reverse --prompt='образ ❯ ' --header='enter — удалить · esc — назад' | awk '{print $1}')
    [[ -n $img ]] && read -q "?удалить $img? [y/N] " && { echo; docker rmi "$img"; } || true
}

_ob_clean() {
    print "висячие образы и кэш сборки старше недели (контейнеры и тома не трогаются)"
    read -q "?убрать? [y/N] " || { echo; return; }
    echo; docker image prune -f | tail -1; docker builder prune -f --filter until=168h | tail -1
}

_ob_power() {
    case $1 in
        on)  _docker_ready && echo "✓ OrbStack запущен" ;;
        off) orb stop >/dev/null 2>&1; osascript -e 'quit app "OrbStack"' >/dev/null 2>&1; echo "○ OrbStack выключен" ;;
    esac
}

_ob_menu() {
    local -a items compose=( (compose|docker-compose).y(a|)ml(N) )
    items=('контейнеры     выбрать и управлять')
    (( $#compose )) && items+=('compose up     поднять проект в этой папке' 'compose down   остановить проект')
    items+=('образы         список, удалить' 'статистика     CPU и память контейнеров' 'уборка         висячие образы и кэш сборки')
    [[ -S ~/.orbstack/run/docker.sock ]] && items+=('выключить      остановить OrbStack и освободить память') \
                                         || items+=('включить       запустить OrbStack')
    print -l $items | fzf --height=50% --reverse --no-sort --prompt='orbstack ❯ ' --header='esc — выход' | awk '{print $1, $2}'
}

orbstack() {
    case $1 in
        ps)           docker ps -a ;;
        logs)         local c=${2:-$(_ob_pick)}; [[ -n $c ]] && docker logs -f --tail 200 "$c" ;;
        sh|exec)      local c=${2:-$(_ob_pick)}; [[ -n $c ]] && _ob_sh "$c" ;;
        restart|stop|start|rm)
                      local c=${2:-$(_ob_pick)}; [[ -n $c ]] || return
                      [[ $1 == rm ]] && set -- "rm -f" "$c"; docker ${=1} "$c" ;;
        images)       _ob_images ;;
        stats)        docker stats --no-stream ;;
        clean)        _ob_clean ;;
        up)           docker compose up -d ;;
        down)         docker compose down ;;
        on|off)       _ob_power $1 ;;
        -h|--help|help)
            print "orbstack            баннер и меню"
            print "orbstack ps         все контейнеры"
            print "orbstack logs|sh|restart|stop|start|rm [контейнер]   без имени — выбор из списка"
            print "orbstack images · stats · clean · up · down · on · off" ;;
        "")
            local pick
            while true; do
                clear; _ob_banner; _ob_status
                pick=$(_ob_menu) || break
                case $pick in
                    "контейнеры "*) _ob_container ;;
                    "compose up")   docker compose up -d ;;
                    "compose down") docker compose down ;;
                    "образы "*)     _ob_images ;;
                    "статистика "*) docker stats --no-stream ;;
                    "уборка "*)     _ob_clean ;;
                    "выключить "*)  _ob_power off ;;
                    "включить "*)   _ob_power on ;;
                    *) break ;;
                esac
                print -n "\n$(_c $T_MUTED)enter — в меню${r:-$'\e[0m'}"; read -s -k1; print
            done ;;
        *) print "orbstack: не знаю «$1» — orbstack help" >&2; return 2 ;;
    esac
}
