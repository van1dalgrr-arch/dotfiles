# shellcheck shell=bash disable=SC2154  # цвета — из lib/ui.sh
# ============================================================
#   dot clean [--yes] [--trash] — освободить место. Без --yes только показывает план.
#   Чистит то, что пересоздаётся само: кэши Homebrew, сборки Go, gopls, golangci-lint,
#   JetBrains (если GoLand закрыт), мусор Docker (висячие образы и кэш сборки).
#   --trash — ещё и очистить Корзину (это необратимо).
#   Порог свободного места для напоминаний и doctor: DISK_MIN_GB (по умолчанию 100).
# ============================================================

DISK_MIN_GB="${DISK_MIN_GB:-100}"
disk_free_gb() { df -k / | awk 'NR == 2 { printf "%d", $4 / 1048576 }'; }

# размер папки в МБ (0, если нет)
size_mb() { [ -d "$1" ] && du -sk "$1" 2>/dev/null | awk '{ printf "%d", $1 / 1024 }' || echo 0; }

clean() {
    local apply=0 trash=0 a
    for a in "$@"; do
        case $a in
            --yes|-y) apply=1 ;;
            --trash) trash=1 ;;
            *) echo "dot clean [--yes] [--trash]" >&2; return 2 ;;
        esac
    done
    local before total=0
    before=$(disk_free_gb)
    section "Место на диске: свободно ${before} ГБ (порог ${DISK_MIN_GB} ГБ)"

    # item <описание> <МБ> <команда…> — показать и (с --yes) выполнить
    item() {
        local desc=$1 size=$2; shift 2
        [ "$size" -gt 0 ] || return 0
        total=$((total + size))
        local pad=$((40 - $(printf '%s' "$desc" | wc -m)))     # по буквам, не байтам
        printf '  %s~%s %s%*s%s%6d МБ%s\n' "$c_head" "$r" "$desc" "$pad" '' "$c_dim" "$size" "$r"
        [ "$apply" = 1 ] && "$@" >/dev/null 2>&1
        return 0
    }

    has brew && item "кэш Homebrew (старые пакеты)" "$(size_mb "$(brew --cache)")" brew cleanup --prune=all -s
    if has go; then
        item "кэш сборки Go" "$(size_mb "$(go env GOCACHE)")" go clean -cache
    fi
    item "кэш gopls" "$(size_mb "$HOME/Library/Caches/gopls")" rm -rf "$HOME/Library/Caches/gopls"
    item "кэш golangci-lint" "$(size_mb "$HOME/Library/Caches/golangci-lint")" rm -rf "$HOME/Library/Caches/golangci-lint"
    if pgrep -xq goland; then info "кэш JetBrains пропущен — GoLand открыт"
    else item "кэш JetBrains (GoLand)" "$(size_mb "$HOME/Library/Caches/JetBrains")" rm -rf "$HOME/Library/Caches/JetBrains"; fi
    if docker info >/dev/null 2>&1; then
        local dmb
        dmb=$(docker system df --format '{{.Type}} {{.Reclaimable}}' 2>/dev/null | awk '/Images|Build Cache/ {
            v = $2; u = v; gsub(/[0-9.]/, "", u); gsub(/[A-Za-z]/, "", v)
            s += (u == "GB" ? v * 1024 : u == "MB" ? v : u == "kB" ? v / 1024 : 0) } END { printf "%d", s }')
        item "Docker: висячие образы и кэш сборки" "${dmb:-0}" sh -c 'docker image prune -f; docker builder prune -f'
    else info "Docker не запущен — его мусор не считаю (контейнеры и тома не трогаются никогда)"; fi
    if [ "$trash" = 1 ]; then
        # внутрь ~/.Trash macOS терминал не пускает — считаем через Finder
        local n
        n=$(osascript -e 'tell application "Finder" to count items of trash' 2>/dev/null || echo 0)
        if [ "${n:-0}" -gt 0 ]; then
            printf '  %s~%s %s %s(размер macOS не показывает)%s\n' "$c_head" "$r" "Корзина: $n шт., необратимо" "$c_dim" "$r"
            [ "$apply" = 1 ] && osascript -e 'tell application "Finder" to empty trash' >/dev/null 2>&1
            total=$((total + 1))
        fi
    fi

    if [ "$total" -eq 0 ]; then pass "чистить нечего"
    elif [ "$apply" = 1 ]; then pass "освобождено: $(( $(disk_free_gb) - before )) ГБ · свободно $(disk_free_gb) ГБ"
    elif [ "$total" -ge 1024 ]; then info "можно освободить ~$(( total / 1024 )) ГБ · выполнить: dot clean --yes"
    else info "можно освободить ~$total МБ · выполнить: dot clean --yes"; fi
    [ "$trash" = 1 ] || info "Корзина не трогается; очистить и её: dot clean --yes --trash"
}
