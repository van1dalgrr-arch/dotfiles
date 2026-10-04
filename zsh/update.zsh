# ============================================================
#   update — обслуживание одной командой (раз в неделю):
#   brew, Go-инструменты, мусор Docker и кэши, tldr, иконки (слетают после обновлений).
#   Только безопасное: контейнеры и тома Docker не трогаются.
# ============================================================

update() {
    local r=$'\e[0m' ok="$(_c $T_FOAM)" head="$(_c $T_ROSE)" dim="$(_c $T_MUTED)"
    local before=$(df -k / | awk 'NR==2 {print $4}')
    _step() { print -n "\n${head}󰚰  $1${r}\n"; }

    _step "brew"
    brew update --quiet && brew upgrade && brew cleanup --prune=7 -q

    if (( $+commands[go] )); then
        _step "Go-инструменты"
        go install golang.org/x/tools/gopls@latest && go install github.com/air-verse/air@latest && print "${ok}gopls, air ✓${r}"
    fi

    if docker info >/dev/null 2>&1; then
        _step "Docker: висячие образы и кэш сборки"
        docker image prune -f | tail -1
        docker builder prune -f --filter until=168h | tail -1
    fi

    _step "tldr"
    tldr --update >/dev/null 2>&1 && print "${ok}справочник обновлён ✓${r}"

    _step "иконки и тема"
    NO_WALLPAPER=1 ~/dotfiles/themes/apply.sh | tail -2

    local after=$(df -k / | awk 'NR==2 {print $4}')
    local freed=$(( (after - before) / 1024 ))
    print "\n${ok}✓ готово${r}  ${dim}освобождено: ${freed} МБ · свободно: $(( after / 1048576 )) ГБ${r}"
}
