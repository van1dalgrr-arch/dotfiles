# ============================================================
#   Напоминания под приветствием нового окна — только когда есть повод:
#     󰚰  update не запускался 9 дней
#     󰊢  не запушено: pulse ⇡2 · MINI-deploy ⇡1 · watchdog !3
#   ⇡N — коммиты, которых нет ни на одном remote (включая ветки без upstream),
#   !N — незакоммиченные файлы. Это то, что пропадёт, если Mac сбросится.
#
#   Окно не ждёт git: показывается прошлый результат из кэша, а свежий
#   собирается в фоне (не чаще раза в 10 минут) — к следующему окну он готов.
#   Выключить: NO_REMINDERS=1 в ~/.zshenv
# ============================================================

_rem_dir=~/.cache/dotfiles
_rem_repos=$_rem_dir/repos-status          # строки «имя ⇡N !N»
_rem_update=$_rem_dir/last-update          # трогает update по завершении

# собрать статус всех репозиториев ~/dev (как pl: без sandbox и *.worktrees)
_reminders_refresh() {
    local d name ahead dirty out=""
    for d in ${DEV:-$HOME/dev}/*(/N) ${DEV:-$HOME/dev}/*/*(/N); do
        [[ -e $d/.git ]] || continue
        name=${d#${DEV:-$HOME/dev}/}
        [[ $name == sandbox* || $name == *.worktrees* ]] && continue
        ahead=$(git -C "$d" rev-list --count --branches --not --remotes 2>/dev/null) || continue
        dirty=$(git -C "$d" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        (( ahead || dirty )) && out+="${name} ${ahead} ${dirty}"$'\n'
    done
    mkdir -p $_rem_dir && print -rn -- "$out" >| $_rem_repos.tmp && command mv -f $_rem_repos.tmp $_rem_repos
}

_reminders() {
    [[ -n $NO_REMINDERS ]] && return
    local r=$'\e[0m' dim="$(_c $T_MUTED)" gold="$(_c $T_GOLD)" love="$(_c $T_LOVE)" foam="$(_c $T_FOAM)"
    mkdir -p $_rem_dir

    # 1. update: отсчёт с первого запуска этой функции, если update ещё ни разу не отметился
    [[ -f $_rem_update ]] || touch $_rem_update
    local -a old=($_rem_update(Nm+6))
    if (( $#old )); then
        zmodload -F zsh/stat b:zstat
        local -a st; zstat -A st +mtime $_rem_update
        print "  ${gold}󰚰  update не запускался $(( (EPOCHSECONDS - st[1]) / 86400 )) дн.${r} ${dim}· update${r}"
    fi

    # 2. незапушенное — из кэша
    if [[ -s $_rem_repos ]]; then
        local name ahead dirty
        local -a items
        while read -r name ahead dirty; do
            local item="${foam}${name}${r}"
            (( ahead )) && item+=" ${love}⇡$ahead${r}"
            (( dirty )) && item+=" ${gold}!$dirty${r}"
            items+=("$item")
        done < $_rem_repos
        local more=""; (( $#items > 4 )) && more=" ${dim}+$(( $#items - 4 ))${r}"
        print "  ${love}󰊢  не запушено:${r} ${(pj: · :)items[1,4]}$more ${dim}· pl${r}"
    fi

    # обновить кэш в фоне, если он старше 10 минут (или его нет)
    local -a fresh=($_rem_repos(Nmm-10))
    (( $#fresh )) || ( _reminders_refresh & ) >/dev/null 2>&1
}
