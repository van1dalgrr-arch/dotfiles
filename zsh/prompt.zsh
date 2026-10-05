# Промпт на чистом zsh: вне git — ни одного процесса, в git — один `git status`. Цвета — T_* темы.
# ⎈ контекст kubectl — только в k8s-проекте или после kubectl/helm в этом окне (читается файл).

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

    local s="$(_p $T_GOLD) $branch"
    (( staged ))    && s+=" $(_p $T_FOAM)+$staged"
    (( changed ))   && s+=" $(_p $T_ROSE)!$changed"
    (( conflicts )) && s+=" $(_p $T_LOVE)=$conflicts"
    (( untracked )) && s+=" $(_p $T_MUTED)?$untracked"
    (( stash ))     && s+=" $(_p $T_MUTED)≡$stash"
    (( ahead ))     && s+=" $(_p $T_FOAM)⇡$ahead"
    (( behind ))    && s+=" $(_p $T_LOVE)⇣$behind"
    print -n "$s"
}

# контекст kubectl из ~/.kube/config (или $KUBECONFIG) — чтением файла, без запуска kubectl
_prompt_kube() {
    local cfg=${KUBECONFIG%%:*}; cfg=${cfg:-$HOME/.kube/config}
    [[ -r $cfg ]] || return
    local ctx=${${(M)${(f)"$(<$cfg)"}:#current-context:*}#current-context: }
    ctx=${ctx//\"/}
    [[ -n $ctx ]] && print -n "$(_p $T_ROSE)⎈ $ctx"
}

# контекст проекта — только чтение файлов и переменных, без запуска программ
_prompt_context() {
    local root=$1 base=${1:-$PWD}
    local -a s
    if [[ -n $root && -f $root/go.mod ]]; then
        local gv=${${(M)${(f)"$(<$root/go.mod)"}:#go [0-9]*}#go }
        [[ -n $gv ]] && s+="$(_p $T_FOAM) $gv"
    fi
    local -a compose=($base/(compose|docker-compose).y(a|)ml(N))
    (( $#compose )) && s+="$(_p $T_FOAM)󰡨"
    local -a k8s=($base/(k8s|manifests|Chart.yaml|kustomization.y(a|)ml)(N) $base/deploy/k8s(N))
    if (( $#k8s || _prompt_kube_used )); then
        local kube=$(_prompt_kube); [[ -n $kube ]] && s+="$kube"
    fi
    [[ -n $VIRTUAL_ENV ]] && s+="$(_p $T_GOLD) ${VIRTUAL_ENV:t}"
    print -n "${(j: :)s}"
}

_seg() { [[ -n $1 ]] && print -n "$(_p $T_MUTED)─[%f$1$(_p $T_MUTED)]"; }

# время команды; заодно — была ли она про Kubernetes (тогда показываем ⎈)
_prompt_preexec() {
    _prompt_t0=$EPOCHREALTIME
    [[ $1 == (kubectl|k|helm|k9s|kind|kx|kn|kubectx|kubens|stern|klogs)(| *) ]] && _prompt_kube_used=1
}

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

    # кто@где — настоящие имя и хост; по SSH хост красный, чтобы не перепутать машину
    local host_color=$T_FOAM; [[ -n $SSH_CONNECTION ]] && host_color=$T_LOVE
    local who="%B$(_p $T_ROSE)%n%b$(_p $T_MUTED)@%B$(_p $host_color)%m%b"

    PROMPT="$(_p $T_MUTED)╭─[%f$who$(_p $T_MUTED)]$(_seg "$(_prompt_dir $root)")$(_seg "$git_part")$(_seg "$(_prompt_context $root)")$jobs_part$status_part%f
$(_p $T_MUTED)╰─%(?.$(_p $T_ROSE).$(_p $T_LOVE))%(!.#.$)%f "
    RPROMPT="${took:+$(_p $T_GOLD)󱎫 $took $(_p $T_HL_HIGH)· }$(_p $T_MUTED)%D{%H:%M}%f"
}

# «транзиентный» промпт: после Enter остаётся только $ команда
_prompt_collapse() {
    PROMPT="$(_p $T_ROSE)%(!.#.$)%f "
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
