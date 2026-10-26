# lock — «матричный дождь» в цветах темы ~1.5 с, потом экран гаснет и Mac блокируется.
# Без процессов: чистый zsh + printf; блокировка — pmset displaysleepnow (пароль сразу после сна).

_rain() {
    local secs=${1:-1.5} cols=$COLUMNS rows=$LINES
    local glyphs='ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎ0123456789ZXCV<>*+=:'
    local head=$(_c $T_TEXT) body=$(_c $T_ROSE) tail=$(_c $T_HL_HIGH) dim=$(_c $T_MUTED)
    local -a drop speed
    local i x y g n=${#glyphs}
    for (( i = 1; i <= cols; i += 2 )); do drop[i]=$(( -RANDOM % rows )); speed[i]=$(( 1 + RANDOM % 2 )); done
    printf '\e[?1049h\e[?25l\e[2J'
    local end=$(( EPOCHREALTIME + secs ))
    while (( EPOCHREALTIME < end )); do
        for (( x = 1; x <= cols; x += 2 )); do
            y=${drop[x]}
            (( y += speed[x], drop[x] = y > rows + 8 ? -(RANDOM % 6) : y ))
            g=${glyphs[RANDOM % n + 1]}
            (( y >= 1 && y <= rows ))         && printf '\e[%d;%dH%s%s' $y $x "$head" "$g"
            (( y - 1 >= 1 && y - 1 <= rows )) && printf '\e[%d;%dH%s%s' $((y - 1)) $x "$body" "${glyphs[RANDOM % n + 1]}"
            (( y - 4 >= 1 && y - 4 <= rows )) && printf '\e[%d;%dH%s%s' $((y - 4)) $x "$tail" "${glyphs[RANDOM % n + 1]}"
            (( y - 8 >= 1 && y - 8 <= rows )) && printf '\e[%d;%dH ' $((y - 8)) $x
        done
        sleep 0.04
    done
    # подпись в центре — как баннер Kali
    local msg="  ${USER}㉿${HOST%%.*} · locked  "
    printf '\e[%d;%dH\e[1;3m%s%s\e[0m' $((rows / 2)) $(( (cols - ${#msg}) / 2 )) "$(_c $T_ROSE)" "$msg"
    sleep 0.6
    printf '\e[0m\e[?25h\e[?1049l'
}

lock() {
    zmodload -F zsh/datetime p:EPOCHREALTIME
    _rain "${1:-1.5}"
    pmset displaysleepnow
}

# rain — просто дождь, без блокировки (rain 5 — пять секунд)
rain() { zmodload -F zsh/datetime p:EPOCHREALTIME; _rain "${1:-3}"; }
