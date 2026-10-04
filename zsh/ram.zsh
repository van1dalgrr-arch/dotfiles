# ============================================================
#   ram — кто ест память. Процессы сгруппированы по приложениям:
#   все «Chrome Helper» → одна строка Chrome, VM Docker — отдельно.
#   ram 15 — показать 15 строк (по умолчанию 10).
# ============================================================

ram() {
    local n=${1:-10}
    local r=$'\e[0m' dim="$(_c $T_MUTED)" sub="$(_c $T_SUBTLE)" txt="$(_c $T_TEXT)"
    local foam="$(_c $T_FOAM)" gold="$(_c $T_GOLD)" love="$(_c $T_LOVE)"
    local iris="$(_c $T_IRIS)" rose="$(_c $T_ROSE)"

    # ── шапка: давление на память (кэш macOS не считается занятым) ──
    local total=$(( $(sysctl -n hw.memsize) / 1048576 ))
    local free=$(memory_pressure -Q 2>/dev/null | awk -F': ' '/percentage/{gsub("%","",$2); print $2}')
    local used=$(( 100 - ${free:-0} ))
    local swap=$(sysctl -n vm.swapusage | awk '{print $6}')

    local c=$foam mood="спокойно"
    (( used >= 60 )) && { c=$gold; mood="плотно"; }
    (( used >= 80 )) && { c=$love; mood="тесно — закрой лишнее"; }

    local w=28 fill=$(( used * 28 / 100 ))
    printf '\n  %s󰍛%s  %sпамять%s  %s%s%s%s%s  %s%d%%%s  %s%s%s\n' \
        "$iris" "$r" "$txt" "$r" \
        "$c" "${(l:$fill::▰:)}" "$dim" "${(l:$(( w - fill ))::▱:)}" "$r" \
        "$c" "$used" "$r" "$dim" "$mood" "$r"
    printf '  %s   %.1f из %d ГБ · swap %s%s\n\n' \
        "$dim" "$(( used * total / 102400.0 ))" "$(( total / 1024 ))" "${swap%.00M}" "$r"

    # ── RSS по процессам → по приложениям ──
    local -a rows=("${(@f)$(ps -axo rss=,comm= | awk '
    {
        rss = $1; $1 = ""; path = substr($0, 2)
        if (path ~ /Virtualization\.VirtualMachine/) name = "Docker (VM)"
        else if (path ~ /com\.apple\.WebKit/) name = "Safari"   # вкладки Safari живут в процессах WebKit
        else if (match(path, /[^\/]+\.app\//)) name = substr(path, RSTART, RLENGTH - 5)
        else { k = split(path, p, "/"); name = p[k] }
        mem[name] += rss; cnt[name]++
    }
    END { for (a in mem) printf "%d\t%d\t%s\n", mem[a] / 1024, cnt[a], a }' | sort -rn | head -n "$n")}")

    local -A icon=(
        Safari 󰀹  "Google Chrome" $'\uf268'  "Visual Studio Code" 󰨞  Code 󰨞
        Ghostty $'\U000f02a0'  OrbStack 󰡨  "Docker (VM)" 󰡨  Docker 󰡨  com.docker.backend 󰡨
        Telegram $'\uf2c6'  Discord 󰙯  Spotify 󰓇  gopls $'\U000f07d3'  go $'\U000f07d3'  claude 󰚩
        Finder 󰀶  WindowServer 󰍹  Raycast 󱓞  AeroSpace 󰕰
        Happ $'\uf132'  lghub $'\U000f037d'  Dock $'\U000f10a9'  Spotlight $'\U000f0349'
        mds_stores $'\U000f0349'  mdworker_shared $'\U000f0349'  corespotlightd $'\U000f0349'
    )
    local -a eighths=('' ▏ ▎ ▍ ▌ ▋ ▊ ▉)
    local max=${${rows[1]}%%$'\t'*} bw=20
    (( max < 1 )) && max=1

    local row mb k name col e bar size ic
    for row in $rows; do
        mb=${row%%$'\t'*}; row=${row#*$'\t'}; k=${row%%$'\t'*}; name=${row#*$'\t'}
        col=$foam; (( mb >= 300 )) && col=$gold; (( mb >= 1000 )) && col=$love
        # плавная полоса в восьмых долях клетки, длина — относительно лидера
        e=$(( mb * bw * 8 / max )); (( e < 1 )) && e=1
        bar="${(l:$(( e / 8 ))::█:)}${eighths[$(( e % 8 + 1 ))]}"
        (( mb >= 1024 )) && size=$(printf '%.1f ГБ' $(( mb / 1024.0 ))) || size="$mb МБ"
        ic=${icon[$name]:-$dim·$r}
        printf '  %s%s%s  %s%-20s%s %s%-*s%s %s%8s%s %s%s%s\n' \
            "$rose" "$ic" "$r" "$txt" "${name[1,20]}" "$r" \
            "$col" "$(( bw + 1 ))" "$bar" "$r" "$sub" "$size" "$r" \
            "$dim" "$( (( k > 1 )) && print "×$k")" "$r"
    done
    print
}
