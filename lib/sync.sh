# shellcheck shell=bash disable=SC2154  # цвета — из lib/ui.sh
# dot sync [--yes] — подтянуть свежие dotfiles с GitHub: показать, что придёт, только fast-forward,
# потом doctor и смоук-тесты. Незакоммиченное никогда не перезаписывается (git сам откажет).

sync() {
    local yes=0 a
    for a in "$@"; do
        case $a in --yes) yes=1 ;; *) echo "dot sync [--yes]" >&2; return 2 ;; esac
    done
    local g="git -C $DOTFILES"
    section "Репозиторий"
    local branch up
    branch=$($g branch --show-current)
    up=$($g rev-parse --abbrev-ref '@{u}' 2>/dev/null) || { failed "у ветки $branch нет upstream" "→ git push -u origin $branch"; summary; return; }
    $g fetch -q 2>/dev/null || { failed "git fetch не удался" "→ сеть / VPN?"; summary; return; }
    local dirty ahead behind
    dirty=$($g status --porcelain | wc -l | tr -d ' ')
    read -r behind ahead <<<"$($g rev-list --left-right --count "$up...HEAD")"
    [ "$dirty" -gt 0 ] && warning "$dirty незакоммиченных файлов — они останутся как есть" "→ git -C ~/dotfiles status"
    [ "$ahead" -gt 0 ] && info "$ahead своих коммитов не запушено"
    if [ "$behind" -eq 0 ]; then pass "$branch = $up, обновлений нет"; summary; return; fi
    if [ "$ahead" -gt 0 ]; then
        failed "ветки разошлись: $ahead своих и $behind новых" "→ git -C ~/dotfiles pull --rebase"; summary; return
    fi

    section "Придёт $behind коммитов"
    $g log --format='  %h %s' "HEAD..$up" | head -20
    local files; files=$($g diff --name-only "HEAD...$up")
    printf '%s\n' "$files" | sed 's/^/    /' | head -15
    if [ "$yes" != 1 ]; then
        [ -t 0 ] || { info "без терминала — только просмотр; применить: dot sync --yes"; summary; return; }
        printf '\n  применить? [y/N] '; read -r a
        case $a in y | Y | д | Д) ;; *) info "ничего не менял"; summary; return ;; esac
    fi

    section "Обновление"
    if $g merge -q --ff-only "$up"; then pass "fast-forward до $($g rev-parse --short HEAD)"
    else failed "fast-forward не прошёл (локальные правки в тех же файлах?)" "→ git -C ~/dotfiles status"; summary; return; fi
    # что ещё надо сделать руками — по списку изменённых файлов
    grep -qE '^install\.sh$' <<<"$files" && info "поменялся install.sh → ./install.sh"
    grep -qE '^Brewfile' <<<"$files" && info "поменялся Brewfile → brew bundle"
    grep -qE '^berth/' <<<"$files" && info "поменялся berth → go build -C ~/dotfiles/berth -o ~/go/bin/berth ."
    grep -qE '^zsh/' <<<"$files" && info "поменялся zsh → exec zsh"

    section "Проверки"
    if "$DOTFILES/tests/smoke.sh" >/dev/null 2>&1; then pass "смоук-тесты"; else failed "смоук-тесты упали" "→ make test"; fi
    local d
    if d=$("$DOTFILES/bin/dot" doctor --json 2>/dev/null) || [ -n "$d" ]; then
        local dfail; dfail=$(sed -nE 's/.*"fail":([0-9]+).*/\1/p' <<<"${d%%,\"checks\"*}")
        if [ "${dfail:-1}" = 0 ]; then pass "dot doctor: без ошибок"; else failed "dot doctor: ошибок ${dfail:-?}" "→ dot doctor"; fi
    fi
    summary
}
