# orbstack — OrbStack в терминале: баннер, контейнеры и меню (fzf) с пояснением к каждому пункту.
# Всё то же — подкомандами без меню (orbstack help). Контейнер не указан — выбирается из списка.
# Docker поднимается сам (docker() в .zshrc). Шпаргалка по docker: docs/docker.ru.md (orbstack guide)

_ob_logo=(
'█████ ████  ████  █████ █████ █████ █████ █   █'
'█   █ █   █ █   █ █       █   █   █ █     █  █ '
'█   █ ████  ████  █████   █   █████ █     ███  '
'█   █ █  █  █   █     █   █   █   █ █     █  █ '
'█████ █   █ ████  █████   █   █   █ █████ █   █'
)

# шаблоны запуска: образ | порты | переменные | том
typeset -gA _ob_tpl=(
    postgres 'postgres:17|5432:5432|POSTGRES_PASSWORD=postgres|pgdata:/var/lib/postgresql/data'
    redis    'redis:7|6379:6379||'
    nginx    'nginx:alpine|8081:80||'
    mongo    'mongo:8|27017:27017||mongodata:/data/db'
    mysql    'mysql:8|3306:3306|MYSQL_ROOT_PASSWORD=root|mysqldata:/var/lib/mysql'
    rabbitmq 'rabbitmq:4-management|5672:5672 15672:15672||'
)

_ob_rgb() { print -n "$((16#${1:0:2}));$((16#${1:2:2}));$((16#${1:4:2}))"; }
_ob_up() { [[ -S ~/.orbstack/run/docker.sock ]] && command docker info >/dev/null 2>&1; }

# логотип: градиент акцент → синий и «потёки» вниз, как у краски
_ob_banner() {
    local -a a b col; a=(${(s:;:)"$(_ob_rgb $T_ROSE)"}); b=(${(s:;:)"$(_ob_rgb $T_FOAM)"})
    local w=${#_ob_logo[1]} line i k out len c r=$'\e[0m' shade=(▓ ▒ ░) bottom=${_ob_logo[-1]}
    for ((i = 1; i <= w; i++)); do
        col[i]="$(( a[1] + (b[1] - a[1]) * (i - 1) / (w - 1) ));$(( a[2] + (b[2] - a[2]) * (i - 1) / (w - 1) ));$(( a[3] + (b[3] - a[3]) * (i - 1) / (w - 1) ))"
    done
    print
    for line in $_ob_logo; do
        out="  "
        for ((i = 1; i <= w; i++)); do
            [[ ${line[i]} == ' ' ]] && out+=' ' || out+=$'\e[38;2;'"${col[i]}m${line[i]}"
        done
        print -r -- "$out$r"
    done
    for k in 1 2 3; do
        out="  "
        for ((i = 1; i <= w; i++)); do
            len=$(( (i * 7 + i / 3 * 5) % 4 ))          # длина потёка — от номера колонки, без рандома
            if [[ ${bottom[i]} == █ ]] && (( k <= len )); then
                c=(${(s:;:)col[i]})
                out+=$'\e[38;2;'"$(( c[1] * (4 - k) / 4 ));$(( c[2] * (4 - k) / 4 ));$(( c[3] * (4 - k) / 4 ))m${shade[k]}"
            else out+=' '; fi
        done
        print -r -- "$out$r"
    done
}

# порты из docker ps коротко: 0.0.0.0:5432->5432/tcp, [::]:5432->… → 5432→5432
_ob_ports() { grep -oE '[0-9]+->[0-9]+' <<<"$1" | sort -u | sed 's/->/→/' | paste -sd' ' -; }

# главный экран: строка состояния и таблица контейнеров
_ob_status() {
    local ok="$(_c $T_FOAM)" bad="$(_c $T_LOVE)" warn="$(_c $T_GOLD)" dim="$(_c $T_MUTED)" acc="$(_c $T_ROSE)" r=$'\e[0m'
    local ver="OrbStack $(orb version 2>/dev/null | awk '/^Version/{print $2}') · Docker $(command docker --version 2>/dev/null | awk '{print $3}' | tr -d ,)"
    print
    if ! _ob_up; then
        print "  ${warn}○${r} движок выключен ${dim}· $ver · включится сам при первом действии${r}"
    else
        local -a rows; rows=(${(f)"$(command docker ps -a --format '{{.State}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null)"})
        local run=${#${(M)rows:#running*}} img=$(command docker images -q | sort -u | wc -l | tr -d ' ')
        local disk=$(command docker system df --format '{{.Size}}' 2>/dev/null | head -1)
        print "  ${ok}●${r} движок работает ${dim}· $ver · образов $img · ${disk:-0B}${r}"
        print
        if (( ! $#rows )); then
            print "  ${dim}контейнеров нет — «запустить контейнер» в меню или orbstack run${r}"
        else
            print "  ${dim}контейнеры: ${r}${acc}$run${r}${dim} работают из $#rows${r}"
            local row st name stat ports dot shown=0
            for row in $rows; do
                (( ++shown > 8 )) && { print "  ${dim}  … и ещё $(( $#rows - 8 )) — «контейнеры» в меню${r}"; break; }
                st=${row%%$'\t'*}; row=${row#*$'\t'}; name=${row%%$'\t'*}; row=${row#*$'\t'}
                stat=${row%%$'\t'*}; ports=$(_ob_ports "${row#*$'\t'}")
                case $st in
                    running)          dot="${ok}●" ;;
                    restarting|dead)  dot="${bad}●" ;;
                    paused|created)   dot="${warn}●" ;;
                    *)                dot="${dim}○" ;;
                esac
                [[ $stat == *unhealthy* ]] && dot="${bad}●"
                printf '    %s%s %-22s %s%-26s%s %s\n' "$dot" "$r" "${name[1,22]}" "$dim" "${stat[1,26]}" "$r" "${ports:+$acc$ports$r}"
            done
        fi
    fi
    local compose=( (compose|docker-compose).y(a|)ml(N) )
    (( $#compose )) && print "\n  ${acc}⚑${r} проект ${PWD:t} ${dim}($compose[1]) — compose up / down в меню${r}"
    print
}

# выбор контейнера: имя · статус · образ · порты, снизу/справа — свежий лог
_ob_pick() {
    docker ps -a --format '{{.Names}}\t{{.Status}}\t{{.Image}}' 2>/dev/null | column -t -s $'\t' |
        fzf --height=70% --prompt='контейнер ❯ ' --border-label=' контейнеры ' \
            --header='enter — действия · esc — назад' \
            --preview 'docker logs --tail 40 {1} 2>&1' --preview-label=' лог ' \
            --preview-window='right,50%,wrap,<90(down,45%,wrap)' |
        awk '{print $1}'
}

_ob_sh() { docker exec -it "$1" sh -c 'command -v bash >/dev/null && exec bash || exec sh'; }

_ob_container() {
    local c=${1:-$(_ob_pick)}; [[ -n $c ]] || return 1
    local state=$(command docker inspect -f '{{.State.Status}}' "$c" 2>/dev/null) toggle
    [[ $state == running ]] && toggle=$'stop\tостановить\tdocker stop — данные и том на месте' \
                            || toggle=$'start\tзапустить\tdocker start — с теми же настройками'
    local act=$(print -l \
        $'logs\tлоги\tdocker logs -f — вживую, ctrl+c — назад' \
        $'sh\tтерминал\tdocker exec -it … sh — зайти внутрь, exit — выйти' \
        $'restart\tперезапустить\tdocker restart' \
        "$toggle" \
        $'inspect\tподробно\tобраз, порты, тома, переменные' \
        $'rm\tудалить\tdocker rm -f — тома останутся' |
        fzf --height=45% --delimiter='\t' --with-nth=2,3 --prompt="$c ❯ " --border-label=" $c · $state " | cut -f1)
    case $act in
        logs)    _ob_logs "$c" ;;
        sh)      _ob_sh "$c" ;;
        restart) docker restart "$c" >/dev/null && echo "↻ перезапущен: $c" ;;
        stop)    docker stop "$c" >/dev/null && echo "■ остановлен: $c" ;;
        start)   docker start "$c" >/dev/null && echo "▶ запущен: $c" ;;
        inspect) docker inspect "$c" | jq '.[0] | {Name, Image: .Config.Image, State: .State.Status, Started: .State.StartedAt, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[] | {Source, Destination}], Env: .Config.Env}' | bat -l json --style=plain --paging=never ;;
        rm)      read -q "?удалить $c? [y/N] " && { echo; docker rm -f "$c" >/dev/null && echo "✗ удалён: $c"; } || echo ;;
        *)       return 1 ;;
    esac
}

_ob_logs() {
    local c=${1:-$(_ob_pick)}; [[ -n $c ]] || return 1
    print "$(_c $T_MUTED)лог $c вживую · ctrl+c — назад\e[0m"
    docker logs -f --tail 200 "$c"
}

# запуск: шаблон или свой образ → готовая команда docker run, её можно поправить перед запуском
_ob_run() {
    local t=$1 spec image ports env vol name cmd p
    if [[ -z $t ]]; then
        t=$({ for p in postgres redis nginx mongo mysql rabbitmq; do
                spec=${_ob_tpl[$p]}; print "$p\t${spec%%|*}\t$(_ob_runcmd $p "${(@s:|:)spec}")"
            done; print "свой\tлюбой образ\tспрошу образ, порт и имя"; } |
            fzf --height=60% --delimiter='\t' --with-nth=1,2 --prompt='запустить ❯ ' --border-label=' новый контейнер ' \
                --header='шаблон: порты, пароль и том уже прописаны' \
                --preview 'printf "%s\n\n%s\n" "команда:" {3}' --preview-window='down,5,wrap' | cut -f1)
        [[ -n $t ]] || return 1
    fi
    if [[ -n ${_ob_tpl[$t]} ]]; then
        spec=${_ob_tpl[$t]}; cmd=$(_ob_runcmd $t "${(@s:|:)spec}"); name=$t
    else
        image=${t:#свой}
        [[ -n $image ]] || vared -p 'образ (например alpine:3, node:22): ' image
        [[ -n $image ]] || return 1
        vared -p 'порт Mac:контейнер (enter — без портов): ' ports
        name=${${image%%:*}##*/}; vared -p 'имя контейнера: ' name
        cmd=$(_ob_runcmd $name "$image" "$ports" "" "")
    fi
    if command docker inspect "$name" >/dev/null 2>&1; then
        if [[ $(command docker inspect -f '{{.State.Status}}' "$name") == running ]]; then
            echo "уже работает: $name"; return
        fi
        read -q "?контейнер $name уже есть, но остановлен — запустить его? [y/N] " && { echo; docker start "$name" >/dev/null && echo "▶ запущен: $name"; } || echo
        return
    fi
    print "$(_c $T_MUTED)команда — можно поправить, enter — запустить, ctrl+c — отмена\e[0m"
    vared -p '❯ ' cmd || return 1
    eval "$cmd" >/dev/null && {
        print "$(_c $T_FOAM)▶ запущен: $name\e[0m"
        [[ $cmd == *" -p "* ]] && print "  localhost:${${cmd#* -p }%%:*}"
    }
}

# docker run из полей шаблона: имя образ порты переменные том
_ob_runcmd() {
    local name=$1 image=$2 ports=$3 env=$4 vol=$5 cmd="docker run -d --name $1" p
    for p in ${(z)ports}; do cmd+=" -p $p"; done
    [[ -n $env ]] && cmd+=" -e $env"
    [[ -n $vol ]] && cmd+=" -v $vol"
    print -r -- "$cmd --restart unless-stopped $image"
}

# отслеживание: CPU, память, сеть вживую
_ob_top() {
    _ob_up || _docker_ready || return 1
    if [[ -z $(command docker ps -q) ]]; then echo "нет запущенных контейнеров"; return; fi
    print "$(_c $T_MUTED)обновляется само · ctrl+c — назад\e[0m"
    docker stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.PIDs}}'
}

# события: что запускается, останавливается и падает — вживую
_ob_events() {
    _ob_up || _docker_ready || return 1
    local ok="$(_c $T_FOAM)" bad="$(_c $T_LOVE)" dim="$(_c $T_MUTED)" r=$'\e[0m' t act name
    print "${dim}события контейнеров вживую · ctrl+c — назад${r}"
    docker events --filter type=container \
        --filter event=start --filter event=stop --filter event=die --filter event=restart \
        --filter event=kill --filter event=oom --filter event=health_status --filter event=destroy \
        --format '{{.Time}}	{{.Action}}	{{.Actor.Attributes.name}}' |
    while IFS=$'\t' read -r t act name; do
        case $act in
            start)                     act="${ok}▶ запущен${r}" ;;
            die|kill|oom)              act="${bad}✗ $act${r}" ;;
            *unhealthy*)               act="${bad}♥ нездоров${r}" ;;
            health_status*)            act="${ok}♥ здоров${r}" ;;
            *)                         act="${dim}■ $act${r}" ;;
        esac
        print "  ${dim}$(date -r $t +%H:%M:%S)${r}  $act  $name"
    done
}

_ob_images() {
    local img=$(docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}' | column -t -s $'\t' |
        fzf --height=60% --prompt='образ ❯ ' --border-label=' образы ' --header='enter — удалить · esc — назад' | awk '{print $1}')
    [[ -n $img ]] || return 1
    read -q "?удалить $img? [y/N] " && { echo; docker rmi "$img"; } || echo
}

_ob_clean() {
    command docker system df 2>/dev/null
    print "\nубрать висячие образы и кэш сборки старше недели (контейнеры и тома не трогаются)"
    read -q "?убрать? [y/N] " || { echo; return; }
    echo; docker image prune -f | tail -1; docker builder prune -f --filter until=168h | tail -1
}

_ob_power() {
    case $1 in
        on)  _docker_ready && echo "● OrbStack запущен" ;;
        off) orb stop >/dev/null 2>&1; osascript -e 'quit app "OrbStack"' >/dev/null 2>&1; echo "○ OrbStack выключен, память свободна" ;;
    esac
}

_ob_guide() { bat -l md --style=plain --paging=always ~/dotfiles/docs/docker.ru.md; }

# пункт меню: ключ · название · коротко · пояснение справа (\n — перенос)
_ob_item() { print -r -- "$1"$'\t'"$2"$'\t'"$3"$'\t'"$4"; }

_ob_menu() {
    local compose=( (compose|docker-compose).y(a|)ml(N) )
    {
        _ob_item containers 'контейнеры' 'управлять и смотреть логи' \
            'Список всех контейнеров со свежим логом справа. Выбери — и дальше: логи вживую, терминал внутри, перезапуск, стоп/старт, подробности, удаление.\n\nкоманды: docker ps -a · docker logs -f · docker exec -it\nбез меню: orbstack logs · sh · restart · stop · rm'
        _ob_item run 'запустить' 'postgres, redis, nginx… или свой образ' \
            'Новый контейнер по шаблону: порты, пароль и том уже прописаны. Перед запуском покажу готовую\nкоманду docker run — её можно поправить.\n\nкоманда: docker run -d --name … -p … -e … -v … образ\nбез меню: orbstack run postgres'
        _ob_item top 'отслеживать' 'CPU, память и сеть вживую' \
            'Таблица запущенных контейнеров, обновляется сама: процессор, память (и доля от лимита), сеть, процессы. ctrl+c — назад.\n\nкоманда: docker stats\nбез меню: orbstack top'
        _ob_item events 'события' 'что запускается и падает' \
            'Живая лента: контейнер запустился, остановился, упал (die / oom — кончилась память), здоров или нет. Удобно держать открытым, пока поднимаешь проект.\n\nкоманда: docker events\nбез меню: orbstack events'
        (( $#compose )) && {
            _ob_item up 'compose up' "поднять проект ${PWD:t}" \
                "Все сервисы из $compose[1] в фоне.\n\nкоманда: docker compose up -d\nбез меню: orbstack up"
            _ob_item down 'compose down' 'остановить проект' \
                "Остановить и убрать контейнеры проекта. Тома (данные баз) остаются.\n\nкоманда: docker compose down\nбез меню: orbstack down"
        }
        _ob_item images 'образы' 'список и удаление' \
            'Скачанные образы с размером и возрастом. enter — удалить ненужный.\n\nкоманда: docker images · docker rmi\nбез меню: orbstack images'
        _ob_item clean 'уборка' 'освободить место' \
            'Покажет, сколько занимают образы, контейнеры и тома, и уберёт висячие образы и кэш сборки старше недели. Контейнеры и тома не трогает.\n\nкоманда: docker system df · docker image prune\nбез меню: orbstack clean'
        _ob_item guide 'шпаргалка' 'как запускать контейнеры из терминала' \
            'Образ, контейнер и том в двух словах, флаги docker run с объяснением, compose, уборка — и что из этого делает orbstack. q — закрыть.\n\nфайл: ~/dotfiles/docs/docker.ru.md\nбез меню: orbstack guide'
        if _ob_up; then
            _ob_item off 'выключить' 'остановить OrbStack, вернуть память' \
                'Движок остановится, память вернётся системе. Следующая команда docker поднимет его сама (~4 с).\n\nкоманда: orb stop\nбез меню: orbstack off'
        else
            _ob_item on 'включить' 'запустить OrbStack' \
                'Запустить движок заранее. Можно и не включать: любое действие с контейнерами поднимет его само.\n\nкоманда: open -a OrbStack\nбез меню: orbstack on'
        fi
    } | fzf --height=60% --no-sort --delimiter='\t' --with-nth=2,3 --tabstop=16 \
            --prompt='orbstack ❯ ' --border-label=' меню ' --header='↑↓ — выбрать · enter — открыть · esc — выход' \
            --preview 'printf "%b " {4}' --preview-label=' что это ' \
            --preview-window='right,48%,wrap,<100(down,9,wrap)' |
        cut -f1
}

orbstack() {
    case $1 in
        ps)                docker ps -a ;;
        logs)              _ob_logs "$2" ;;
        sh|exec)           local c=${2:-$(_ob_pick)}; [[ -n $c ]] && _ob_sh "$c" ;;
        restart|stop|start)
                           local c=${2:-$(_ob_pick)}; [[ -n $c ]] && docker $1 "$c" ;;
        rm)                local c=${2:-$(_ob_pick)}; [[ -n $c ]] && docker rm -f "$c" ;;
        run)               _ob_run "$2" ;;
        top|stats)         _ob_top ;;
        events)            _ob_events ;;
        images)            _ob_images ;;
        clean)             _ob_clean ;;
        up)                docker compose up -d ;;
        down)              docker compose down ;;
        on|off)            _ob_power $1 ;;
        guide)             _ob_guide ;;
        -h|--help|help)
            local d="$(_c $T_MUTED)" r=$'\e[0m'
            print "orbstack                  ${d}главный экран и меню${r}"
            print "orbstack ps               ${d}все контейнеры${r}"
            print "orbstack run [шаблон]     ${d}новый контейнер: postgres redis nginx mongo mysql rabbitmq или свой образ${r}"
            print "orbstack logs [имя]       ${d}лог вживую${r}"
            print "orbstack sh [имя]         ${d}терминал внутри контейнера${r}"
            print "orbstack restart|stop|start|rm [имя]"
            print "orbstack top              ${d}CPU, память, сеть вживую${r}"
            print "orbstack events           ${d}что запускается и падает${r}"
            print "orbstack up|down          ${d}compose-проект в текущей папке${r}"
            print "orbstack images|clean     ${d}образы, уборка${r}"
            print "orbstack on|off           ${d}движок: включить / выключить и вернуть память${r}"
            print "orbstack guide            ${d}шпаргалка: как запускать контейнеры из терминала${r}"
            print "${d}без имени контейнера — выбор из списка${r}" ;;
        "")
            # ctrl+c прерывает лог / мониторинг и возвращает в меню, а не выкидывает из orbstack
            setopt localoptions localtraps; trap ':' INT
            local pick pause
            while true; do
                clear; _ob_banner; _ob_status
                pick=$(_ob_menu); [[ -n $pick ]] || break
                pause=1
                case $pick in
                    containers) _ob_container || pause=0 ;;
                    run)        _ob_run || pause=0 ;;
                    top)        _ob_top; pause=0 ;;
                    events)     _ob_events; pause=0 ;;
                    up)         docker compose up -d ;;
                    down)       docker compose down ;;
                    images)     _ob_images || pause=0 ;;
                    clean)      _ob_clean ;;
                    guide)      _ob_guide; pause=0 ;;
                    on|off)     _ob_power $pick ;;
                esac
                (( pause )) && { print -n "\n$(_c $T_MUTED)enter — в меню\e[0m"; read -s -k1; print; }
            done
            clear ;;
        *) print "orbstack: не знаю «$1» — orbstack help" >&2; return 2 ;;
    esac
}
