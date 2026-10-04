# ============================================================
#   ram — кто ест память. Процессы сгруппированы по приложениям:
#   все «Chrome Helper» → одна строка Chrome, VM Docker — отдельно.
#   ram 15 — показать 15 строк (по умолчанию 10).
# ============================================================

ram() {
    local n=${1:-10}
    local r=$'\e[0m' dim=$'\e[38;2;110;106;134m' txt=$'\e[38;2;224;222;244m'
    local foam=$'\e[38;2;156;207;216m' gold=$'\e[38;2;246;193;119m' love=$'\e[38;2;235;111;146m'

    local total=$(( $(sysctl -n hw.memsize) / 1048576 ))
    local free=$(memory_pressure -Q 2>/dev/null | awk -F': ' '/percentage/{gsub("%","",$2); print $2}')
    local used=$(( 100 - ${free:-0} ))
    local swap=$(sysctl -n vm.swapusage | awk '{print $6}')

    # полоса давления на память: бирюзовая → жёлтая → красная
    local c=$foam; (( used >= 60 )) && c=$gold; (( used >= 80 )) && c=$love
    local w=30 fill=$(( used * 30 / 100 ))
    printf '\n %s󰍛  память%s  %s%s%s%s%s  %s%d%%%s %sиз %d ГБ · swap %s%s\n\n' \
        "$txt" "$r" "$c" "${(l:$fill::━:)}" "$dim" "${(l:$(( w - fill ))::━:)}" "$r" \
        "$c" "$used" "$r" "$dim" "$(( total / 1024 ))" "$swap" "$r"

    # RSS по процессам → по приложениям (путь до первого .app или имя бинаря)
    ps -axo rss=,comm= | awk -v n="$n" -v total="$total" \
        -v txt="$txt" -v dim="$dim" -v c1="$foam" -v c2="$gold" -v c3="$love" -v r="$r" '
    {
        rss = $1; $1 = ""; path = substr($0, 2)
        if (path ~ /Virtualization\.VirtualMachine/) name = "Docker (VM)"
        else if (match(path, /[^\/]+\.app\//)) name = substr(path, RSTART, RLENGTH - 5)
        else { k = split(path, p, "/"); name = p[k] }
        mem[name] += rss; cnt[name]++
    }
    END {
        for (a in mem) printf "%d\t%d\t%s\n", mem[a] / 1024, cnt[a], a
    }' | sort -rn | head -n "$n" | while IFS=$'\t' read -r mb k name; do
        local col=$foam; (( mb >= 300 )) && col=$gold; (( mb >= 1000 )) && col=$love
        local bar=$(( mb * 24 / 1500 )); (( bar > 24 )) && bar=24; (( bar < 1 )) && bar=1
        local procs=""; (( k > 1 )) && procs="  ×$k"
        printf ' %s%6d МБ%s  %s%-24s%s %s%s%s%s\n' \
            "$col" "$mb" "$r" "$txt" "${name[1,24]}" "$r" "$col" "${(l:$bar::▪:)}" "$dim$procs" "$r"
    done
    print
}
