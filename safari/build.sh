#!/bin/bash
# safari/build.sh — стартовая страница и таблица стилей Safari в цветах темы и с текущими обоями
# → ~/.cache/dotfiles/safari/{start.html,user.css,wallpaper.jpg}. Зовут themes/apply.sh и wall
set -euo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$HOME/.cache/dotfiles/safari"
MONO='"JetBrainsMono Nerd Font", "JetBrains Mono", ui-monospace, monospace'
mkdir -p "$OUT"

theme=$(cat "$HOME/.config/dotfiles/theme" 2>/dev/null || echo vesper)
[ -f "$DOTFILES/themes/$theme.sh" ] || theme=vesper
# shellcheck disable=SC1090
. "$DOTFILES/themes/$theme.sh"

# обои: кадр из HEIC в JPG рядом со страницей (Safari не грузит файлы из чужих папок)
wall=$(cat "$HOME/.config/dotfiles/wall-path" 2>/dev/null || true)
if [ -f "$wall" ]; then
    sips -s format jpeg -s formatOptions 85 -Z 2560 "$wall" --out "$OUT/wallpaper.jpg" >/dev/null
fi

# закладки: «название  адрес» → <a>, номер = клавиша
links=$(grep -v -e '^#' -e '^[[:space:]]*$' "$DOTFILES/safari/links" | head -9 | awk '{
    url = $NF; $NF = ""; sub(/[ \t]+$/, "")
    printf "    <a href=\"%s\"><span>%d</span>%s</a>\\n", url, NR, $0 }')

fill() {
    awk -v links="$links" -v mono="$MONO" \
        -v base="$T_BASE" -v surface="$T_SURFACE" -v muted="$T_MUTED" -v subtle="$T_SUBTLE" \
        -v text="$T_TEXT" -v rose="$T_ROSE" -v foam="$T_FOAM" '{
        gsub(/%BASE%/, base); gsub(/%SURFACE%/, surface); gsub(/%MUTED%/, muted); gsub(/%SUBTLE%/, subtle)
        gsub(/%TEXT%/, text); gsub(/%ROSE%/, rose); gsub(/%FOAM%/, foam); gsub(/%MONO%/, mono)
        if ($0 == "%LINKS%") { printf "%s", links; next }
        print }' "$1" > "$2"
}
fill "$DOTFILES/safari/start.html" "$OUT/start.html"
fill "$DOTFILES/safari/user.css" "$OUT/user.css"
