# ============================================================
#   Промпт на чистом zsh — в духе Arch-райсов, без starship.
#   Всё, что можно, считается встроенными средствами zsh:
#   вне git-репозитория — ни одного процесса, внутри — один `git status`.
#   Цвета — из палитры темы (T_*).
#
#     󰣇  logsence/internal/handler on  main +1 !2 ?3 ≡1 ⇡1   1.25 󰡨      󱎫 3s · 13:42
#   ❯
#
#   После Enter старый промпт сворачивается до «❯ команда» — история чистая.
# ============================================================

zmodload zsh/datetime
autoload -Uz add-zle-hook-widget add-zsh-hook
setopt PROMPT_SUBST

_p() { print -n "%F{#$1}"; }                     # %F{#hex} из палитры

# корень git-репозитория — подъёмом по папкам, без запуска git
_prompt_root() {
    local d=$PWD
    while [[ -n $d ]]; do
        [[ -e $d/.git ]] && { REPLY=$d; return 0; }
        d=${d%/*}
    done
    return 1
}

# путь: в репозитории — от его корня (имя проекта жирным), иначе — ~ и последние папки
_prompt_dir() {
    local root=$1
    if [[ -n $root ]]; then
        local sub=${PWD#$root}
        local -a parts=(${(s:/:)sub})
        (( $#parts > 2 )) && sub="/…/${(j:/:)parts[-2,-1]}"
        print -n "%B$(_p $T_FOAM)${root:t}%b$(_p $T_FOAM)${sub}"
    else
        print -n "%B$(_p $T_FOAM)%(4~|…/%2~|%~)%b"
    fi
}

# git: одна команда — ветка, отставание, stash, счётчики
_prompt_git() {
    local line branch="" ahead=0 behind=0 stash=0 staged=0 changed=0 untracked=0 conflicts=0
    while IFS= read -r line; do
        case $line in
            "# branch.head "*)  branch=${line#\# branch.head } ;;
            "# branch.oid "*)   local oid=${line#\# branch.oid } ;;
            "# branch.ab "*)    local ab=(${=line#\# branch.ab }); ahead=${ab[1]#+}; behind=${ab[2]#-} ;;
            "# stash "*)        stash=${line#\# stash } ;;
            [12]" "*)           [[ ${line[3]} != . ]] && ((staged++)); [[ ${line[4]} != . ]] && ((changed++)) ;;
            "u "*)              ((conflicts++)) ;;
            "? "*)              ((untracked++)) ;;
        esac
    done < <(git status --porcelain=v2 --branch --show-stash 2>/dev/null)
    [[ -z $branch ]] && return
    [[ $branch == "(detached)" ]] && branch="${oid[1,7]}"

    local s="$(_p $T_SUBTLE)on $(_p $T_GOLD) $branch"
    (( staged ))    && s+=" $(_p $T_FOAM)+$staged"
    (( changed ))   && s+=" $(_p $T_ROSE)!$changed"
    (( conflicts )) && s+=" $(_p $T_LOVE)=$conflicts"
    (( untracked )) && s+=" $(_p $T_MUTED)?$untracked"
    (( stash ))     && s+=" $(_p $T_MUTED)≡$stash"
    (( ahead ))     && s+=" $(_p $T_FOAM)⇡$ahead"
    (( behind ))    && s+=" $(_p $T_LOVE)⇣$behind"
    print -n " $s"
}

# контекст проекта — только чтение файлов и переменных, без запуска программ
_prompt_context() {
    local root=$1 s=""
    if [[ -n $root && -f $root/go.mod ]]; then
        local gv=${${(M)${(f)"$(<$root/go.mod)"}:#go [0-9]*}#go }
        [[ -n $gv ]] && s+=" $(_p $T_FOAM) $gv"
    fi
    local -a compose=(${root:-$PWD}/(compose|docker-compose).y(a|)ml(N))
    (( $#compose )) && s+=" $(_p $T_FOAM)󰡨"
    [[ -n $VIRTUAL_ENV ]] && s+=" $(_p $T_GOLD) ${VIRTUAL_ENV:t}"
    [[ -n $SSH_CONNECTION ]] && s+=" $(_p $T_LOVE)%n@%m"
    print -n "${s:+ $(_p $T_HL_HIGH)·$s}"
}

# время выполнения
_prompt_preexec() { _prompt_t0=$EPOCHREALTIME; }

_prompt_precmd() {
    local code=$?
    local took=""
    if [[ -n $_prompt_t0 ]]; then
        local sec=$(( EPOCHREALTIME - _prompt_t0 )); sec=${sec%.*}
        if   (( sec >= 3600 )); then took="$((sec/3600))h$((sec%3600/60))m"
        elif (( sec >= 60 ));   then took="$((sec/60))m$((sec%60))s"
        elif (( sec >= 2 ));    then took="${sec}s"
        fi
        unset _prompt_t0
    fi

    # пустая строка между командами (но не над самым первым промптом)
    [[ -n $_prompt_drawn ]] && print
    _prompt_drawn=1

    local REPLY root=""
    _prompt_root && root=$REPLY

    # код выхода: 130 → INT (Ctrl+C), 137 → KILL …
    local status_part=""
    if (( code > 128 && code < 160 )) && [[ -n ${signals[code-127]} ]]; then
        status_part=" $(_p $T_LOVE)✘ ${signals[code-127]}"
    elif (( code )); then
        status_part=" $(_p $T_LOVE)✘ $code"
    fi

    local jobs_part="%(1j. $(_p $T_GOLD)✦ %j.)"
    local git_part=""; [[ -n $root ]] && git_part=$(_prompt_git)

    PROMPT="$(_p $T_ROSE)󰣇 %f $(_prompt_dir $root)$git_part$(_prompt_context $root)$jobs_part$status_part%f
$(_p $T_ROSE)%(?..$(_p $T_LOVE))❯%f "
    RPROMPT="${took:+$(_p $T_GOLD)󱎫 $took $(_p $T_HL_HIGH)· }$(_p $T_MUTED)%D{%H:%M}%f"
}

# «транзиентный» промпт: после Enter остаётся только ❯ команда
_prompt_collapse() {
    PROMPT="$(_p $T_ROSE)❯%f "
    RPROMPT=""
    zle .reset-prompt
}
add-zle-hook-widget line-finish _prompt_collapse

add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd

# clear / cmd+k — промпт снова сверху, без пустой строки
_prompt_clear() { _prompt_drawn=; zle .clear-screen; }
zle -N clear-screen _prompt_clear
alias c='_prompt_drawn= ; clear'

# ─── «команда не найдена» как в Arch (pkgfile): подсказать brew и похожие свои команды ───
_brew_index=~/.cache/zsh/brew-formulae
command_not_found_handler() {
    local cmd=$1
    print -P "$(_p $T_LOVE)✘%f команда %B$cmd%b не найдена" >&2
    # список формул обновляется раз в неделю в фоне (brew formulae ~1 c)
    local -a stale=(${~_brew_index}(N.mw+1))
    if [[ ! -s $_brew_index ]] || (( $#stale )); then
        mkdir -p ${_brew_index:h}
        ( brew formulae >| $_brew_index.tmp 2>/dev/null && command mv -f $_brew_index.tmp $_brew_index & ) >/dev/null 2>&1
    fi
    if [[ -s $_brew_index ]] && command grep -qx -- "$cmd" $_brew_index; then
        print -P "  $(_p $T_FOAM)есть в brew:%f brew install $cmd" >&2
    fi
    # свои алиасы и функции, похожие по началу
    local -a near=(${(k)aliases[(I)${cmd[1,3]}*]} ${(k)functions[(I)${cmd[1,3]}*]})
    near=(${near:#_*})
    (( $#near )) && print -P "  $(_p $T_MUTED)похожие свои:%f ${(j:, :)${(o)near[1,6]}}" >&2
    return 127
}
