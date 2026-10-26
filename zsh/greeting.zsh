# Приветствие в новом окне Ghostty — рамка в стиле промпта: шкалы ram/disk/bat, недавние проекты, подсказка, напоминания.
# Без fastfetch: 4 коротких процесса (sysctl, memory_pressure, df, pmset), проекты — по журналам .git без запуска git.

# шкала из 12 делений; цвет по заполненности: спокойно → внимание → тревога
_gr_bar() {
    local pct=$1 n=$(( ($1 * 12 + 50) / 100 )) col
    (( pct >= 85 )) && col=$T_LOVE || { (( pct >= 65 )) && col=$T_GOLD || col=$T_FOAM; }
    print -n "$(_p $col)${(l:n::▰:)}$(_p $T_HL_HIGH)${(l:12-n::▱:)}%f $(_p $col)%B${(l:3:)pct}%%%b%f"
}

# секунды → «12 мин» / «3 ч» / «5 дн»
_gr_ago() { (( $1 < 3600 )) && REPLY="$(( $1 / 60 )) мин" || { (( $1 < 86400 )) && REPLY="$(( $1 / 3600 )) ч" || REPLY="$(( $1 / 86400 )) дн"; }; }

_greeting_panel() {
    zmodload -F zsh/stat b:zstat
    local m=$(_p $T_MUTED) dim=$(_p $T_SUBTLE) txt=$(_p $T_TEXT)
    local -a sys=(${(f)"$(sysctl -n hw.memsize kern.boottime 2>/dev/null)"})
    local gib=$(( ${sys[1]:-0} / 1073741824 )) boot=${${sys[2]#*sec = }%%,*}

    # шапка: ╭─( кто㉿где )─[ дата ]─[ часы ]─[ аптайм ]───
    local -a wd=(понедельник вторник среда четверг пятница суббота воскресенье)
    local -a mon=(января февраля марта апреля мая июня июля августа сентября октября ноября декабря)
    local up; _gr_ago $(( EPOCHSECONDS - ${boot:-$EPOCHSECONDS} )); up=$REPLY
    local date="${wd[$(strftime %u $EPOCHSECONDS)]}, $(( $(strftime %d $EPOCHSECONDS) )) ${mon[$(( $(strftime %m $EPOCHSECONDS) ))]}"
    local plain="╭─( $USER㉿${HOST%%.*} )─[ 󰃭 $date ]─[  $(strftime %H:%M $EPOCHSECONDS) ]─[ 󰅐 $up ]"
    local W=$(( COLUMNS - 2 < 96 ? COLUMNS - 2 : 96 ))
    local fill=$(( W - ${(m)#plain} )); (( fill < 0 )) && fill=0
    print -P "$m╭─(%f%B$(_grad $T_IRIS $T_ROSE "$USER㉿${HOST%%.*}")%b$m)─[%f $(_p $T_ROSE)󰃭 $_I$date$_NI $m]─[%f $(_p $T_GOLD) $_I$(strftime %H:%M $EPOCHSECONDS)$_NI $m]─[%f $(_p $T_FOAM)󰅐 $_I$up$_NI $m]${(l:fill::─:)}%f"
    print -P "$m│%f"

    # память — как в `ram`: кэш macOS не считается занятым
    local free=$(memory_pressure -Q 2>/dev/null); free=${${free##*percentage: }%%\%*}
    if [[ $free == <-> ]]; then
        local used=$(( 100 - free ))
        print -P "$m│%f  $(_p $T_IRIS)󰍛  ram %f  $(_gr_bar $used)   $txt$(( used * gib / 10 / 10 )).$(( used * gib / 10 % 10 )) / $gib GiB%f"
    fi
    # диск — том с данными (на APFS / — это неизменяемая система)
    local -a df=(${=${(f)"$(df -k /System/Volumes/Data 2>/dev/null)"}[2]})
    if (( $#df >= 5 )); then
        local dp=${df[5]%\%} avail=$(( df[4] / 1048576 ))
        print -P "$m│%f  $(_p $T_IRIS)󰋊  disk%f  $(_gr_bar $dp)   $txt$avail GiB%f ${dim}свободно%f"
    fi
    # батарея — цвет по остатку заряда (не по заполненности, как у ram/disk)
    local batt=$(pmset -g batt 2>/dev/null)
    if [[ $batt == *InternalBattery* ]]; then
        local bp=${${batt##*$'\t'}%%\%*} state icon=󰁹 col=$T_FOAM
        [[ $batt == *"AC Power"* ]] && { state="от сети"; icon=󰂄; } || state="${${batt#*%; }%%;*}"
        [[ $state == discharging ]] && state="от батареи"
        [[ $state == charging ]] && state="заряжается"
        [[ $state == charged ]] && state="заряжена"
        (( bp <= 20 )) && col=$T_LOVE || { (( bp <= 40 )) && col=$T_GOLD; }
        local n=$(( (bp * 12 + 50) / 100 ))
        print -P "$m│%f  $(_p $T_IRIS)$icon  bat %f  $(_p $col)${(l:n::▰:)}$(_p $T_HL_HIGH)${(l:12-n::▱:)}%f $(_p $col)%B${(l:3:)bp}%%%b%f   $dim$state%f"
    fi

    # недавние проекты: по времени последнего коммита/переключения ветки (журнал HEAD), без git
    local dev=${DEV:-$HOME/dev} f t name br line msg
    local -a st rows
    for f in $HOME/dotfiles/.git/logs/HEAD(N) $dev/*/.git/logs/HEAD(N) $dev/*/*/.git/logs/HEAD(N); do
        name=${${f%/.git/logs/HEAD}#$dev/}
        [[ $name == sandbox* || $name == *.worktrees* ]] && continue
        name=${name:t}
        zstat -A st +mtime $f && rows+=("${st[1]}|$name|$f")
    done
    if (( $#rows )); then
        print -P "$m│%f"
        print -P "$m├─[%f $(_p $T_ROSE)󰊢 ${_I}недавно$_NI $m]%f"
        local -a top=(${${(On)rows}[1,3]}) lines out
        local nw=0 bw=0 r
        for r in $top; do
            name=${${r#*|}%%|*}; f=${r##*|}
            br=$(<${f%/logs/HEAD}/HEAD); [[ $br == ref:* ]] && br=${br#ref: refs/heads/} || br=${br[1,7]}
            lines=("${(@f)$(<$f)}")
            msg=${${(M)lines:#*$'\t'commit*}[-1]}; [[ -z $msg ]] && msg=${lines[-1]}
            msg=${msg#*$'\t'}; msg=${msg#*: }
            _gr_ago $(( EPOCHSECONDS - ${r%%|*} ))
            out+=("$name|$br|$REPLY|$msg")
            (( ${#name} > nw )) && nw=${#name}; (( ${#br} > bw )) && bw=${#br}
        done
        for r in $out; do
            local -a p=("${(@s:|:)r}")
            local room=$(( W - nw - bw - 19 )); (( room < 8 )) && room=8
            msg=${p[4]}; (( ${#msg} > room )) && msg="${msg[1,room-1]}…"
            print -P "$m│%f   $(_p $T_GOLD)%B${(r:nw:)p[1]}%b%f  $(_p $T_PINE) ${(r:bw:)p[2]}%f  $dim${(l:6:)p[3]}%f  $txt$_I${msg//\%/%%}$_NI%f"
        done
    fi
}

# перед первым приглашением, а не при чтении .zshrc: в первые мс окно ещё 80×24 и проверка размера не проходила
_greeting() {
    add-zsh-hook -d precmd _greeting                     # только один раз
    # не SHLVL: Ghostty от AeroSpace наследует SHLVL=3+; флаг в окружении — вложенный zsh без приветствия
    [[ $TERM_PROGRAM == ghostty && -z $DOTFILES_GREETED && $LINES -ge 12 && $COLUMNS -ge 60 && -z $NO_GREETING ]] || return
    export DOTFILES_GREETED=1
    _greeting_panel

    # низ рамки: подсказка дня и напоминания (update, бэкап, незапушенное); последняя строка закрывает рамку
    local m=$(_p $T_MUTED)
    local -a tips=(${(f)"$(_cheat_funcs)"}) foot
    local tip=${tips[RANDOM % $#tips + 1]}
    local desc=${tip#*|}; (( ${#desc} > COLUMNS - ${#tip%%|*} - 28 )) && desc="${desc[1,COLUMNS-${#tip%%|*}-29]}…"
    foot=("$(_c $T_GOLD)󰌵  ${tip%%|*}"$'\e[0m'"  $(_c $T_MUTED)$desc  · ? — все команды"$'\e[0m')
    foot+=(${${(f)"$(_reminders)"}#  })
    print -P "$m│%f"
    local i
    for (( i = 1; i <= $#foot; i++ )); do
        (( i == $#foot )) && print -Pn "$m╰─%f " || print -Pn "$m├─%f "
        print -r -- "${foot[i]}"
    done
}
add-zsh-hook precmd _greeting
