#!/usr/bin/env bash
# ghostty/fx.sh — эффекты (шейдеры) Ghostty: какие включены, пишет ~/.config/ghostty/fx.ghostty
#   fx.sh                 список: что включено
#   fx.sh on|off <эф…>    включить / выключить
#   fx.sh set <эф…>       ровно этот набор (none — без эффектов)
#   fx.sh apply           пересобрать конфиг из сохранённого набора (install.sh)
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
STATE="$HOME/.config/dotfiles/fx"
CFG="$HOME/.config/ghostty/fx.ghostty"
DEFAULT="cursor trail focus"

# порядок = порядок проходов: свечение до курсора, чтобы курсор не размывался
ALL="glow cursor trail sparks focus"
file_of() { case $1 in cursor) echo cursor_smooth ;; trail) echo cursor_trail ;; *) echo "$1" ;; esac; }
about() {
    case $1 in
        glow)   echo "свечение яркого текста (в светлой теме выключается само)" ;;
        cursor) echo "плавный курсор, как в VS Code" ;;
        trail)  echo "светящийся шлейф на больших прыжках курсора" ;;
        sparks) echo "искры из-под курсора при наборе" ;;
        focus)  echo "вспышка по краям окна, получившего фокус" ;;
    esac
}
known() { case " $ALL " in *" $1 "*) return 0 ;; esac; return 1; }
has()   { case " $cur " in *" $1 "*) return 0 ;; esac; return 1; }

cur=" $(cat "$STATE" 2>/dev/null || echo "$DEFAULT") "

write() {
    local e list=""
    for e in $ALL; do has "$e" && list="$list $e"; done
    mkdir -p "$(dirname "$STATE")" "$(dirname "$CFG")"
    echo "${list# }" > "$STATE"
    {
        echo "# сгенерировано ghostty/fx.sh (${list# }) — не править руками, команда: fx"
        # настоящий курсор прячем, только если его рисует шейдер
        has cursor && echo "cursor-opacity = 0"
        for e in $list; do echo "custom-shader = $DOTFILES/ghostty/shaders/$(file_of "$e").glsl"; done
    } > "$CFG"
    pgrep -xq ghostty && osascript -e 'tell application "Ghostty" to if (count terminals) > 0 then perform action "reload_config" on first terminal' >/dev/null 2>&1 || true
}

show() {
    local e
    for e in $ALL; do
        if has "$e"; then printf '  \033[32m●\033[0m %-7s %s\n' "$e" "$(about "$e")"
        else printf '  \033[2m○ %-7s %s\033[0m\n' "$e" "$(about "$e")"; fi
    done
}

cmd="${1:-list}"; [ $# -gt 0 ] && shift
for e in "$@"; do
    [ "$e" = none ] || known "$e" || { echo "нет эффекта: $e (есть: $ALL)" >&2; exit 2; }
done
case $cmd in
    list)  show ;;
    apply) write ;;
    on)    for e in "$@"; do has "$e" || cur="$cur$e "; done; write; show ;;
    off)   for e in "$@"; do cur="${cur/ $e / }"; done; write; show ;;
    set)   cur=" "; for e in "$@"; do [ "$e" = none ] || cur="$cur$e "; done; write; show ;;
    about) for e in "$@"; do about "$e"; done ;;
    *)     sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2 ;;
esac
