#!/usr/bin/env bash
# themes/apply.sh <тема> — перекрасить всё: конфиги написаны в цветах Rosé Pine и переводятся
# роль к роли (themes/rose-pine.sh → themes/<тема>.sh) в копии в ~/.config и ~/.cache; репозиторий не меняется.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
name="${1:-$(command cat "$HOME/.config/dotfiles/theme" 2>/dev/null || echo rose-pine)}"
theme="$DOTFILES/themes/$name.sh"
[ -f "$theme" ] || { echo "нет темы: $name (есть: $(cd "$DOTFILES/themes" && command ls *.sh | sed 's/\.sh$//' | grep -v apply | tr '\n' ' '))"; exit 1; }

GEN="$HOME/.cache/dotfiles-theme"
mkdir -p "$GEN" "$HOME/.config/dotfiles" "$HOME/.config/ghostty"

# ─── таблица перевода цветов: эталон rose-pine → палитра (роль к роли) ───
roles=(BASE SURFACE OVERLAY HL_LOW HL_MED HL_HIGH MUTED SUBTLE TEXT LOVE GOLD ROSE PINE FOAM IRIS
       DIFF_ADD DIFF_ADD_EMPH DIFF_DEL DIFF_DEL_EMPH)
make_map() {
    local r from to m=""
    for r in "${roles[@]}"; do
        from=$(source "$DOTFILES/themes/rose-pine.sh"; eval echo "\$T_$r")
        to=$(source "$1"; eval echo "\$T_$r")
        m+="$from=$to,"
    done
    printf '%s' "$m"
}
map=$(make_map "$theme")

# один проход perl по #rrggbb, 0x…, hex("…") — цепочек замен не бывает
recolor() {
    MAP="$map" perl -pe '
        BEGIN { %m = map { split /=/ } split /,/, lc $ENV{MAP} }
        s/(#|0x(?:[0-9a-fA-F]{2})?|hex\(")([0-9a-fA-F]{6})\b/$1 . ($m{lc $2} \/\/ $2)/ge
    ' "$1" > "$2"
}

THEME_GHOSTTY_EXTRA=""
source "$theme"

# ─── Ghostty: две темы — тёмная (выбранная) и светлая Dev Day; переключаются вместе с macOS ───
# Все цвета — внутри файлов тем: явные значения в конфиге перекрыли бы светлую тему.
mkdir -p "$HOME/.config/ghostty/themes"
builtin_theme="/Applications/Ghostty.app/Contents/Resources/ghostty/themes/$THEME_GHOSTTY"
{
    echo "# сгенерировано themes/apply.sh ($name) — не править руками"
    if [ -f "$builtin_theme" ]; then command cat "$builtin_theme"
    else printf 'background = #%s\nforeground = #%s\n' "$T_BASE" "$T_TEXT"; fi
    printf 'cursor-color = #%s\nselection-background = #%s\nunfocused-split-fill = #%s\n' "$T_ROSE" "$T_HL_MED" "$T_BASE"
    printf '%s\n' "${THEME_GHOSTTY_EXTRA:-}"
} > "$HOME/.config/ghostty/themes/dotfiles-dark"
( source "$DOTFILES/themes/light/day.sh"
  printf '# сгенерировано themes/apply.sh — Dev Day (themes/light/day.sh)\n%s\n' "$GHOSTTY_LIGHT" ) \
    > "$HOME/.config/ghostty/themes/dotfiles-light"
command cat > "$HOME/.config/ghostty/theme.ghostty" <<EOF
# сгенерировано themes/apply.sh ($name) — не править руками
theme = light:dotfiles-light,dark:dotfiles-dark
macos-icon-ghost-color = #$T_ROSE
macos-icon-screen-color = #$T_BASE,#$T_OVERLAY
EOF

# ─── starship, eza, lazygit, btop, bat — перекрашенные копии ───
recolor "$DOTFILES/starship/starship.toml" "$GEN/starship.toml"
mkdir -p "$GEN/eza"; recolor "$DOTFILES/eza/theme.yml" "$GEN/eza/theme.yml"
recolor "$DOTFILES/lazygit/config.yml" "$GEN/lazygit.yml"
mkdir -p "$HOME/.config/btop/themes"
recolor "$DOTFILES/btop/themes/rose-pine.theme" "$HOME/.config/btop/themes/dotfiles.theme"
mkdir -p "$HOME/.config/bat/themes"
recolor "$DOTFILES/bat/themes/rose-pine.tmTheme" "$HOME/.config/bat/themes/dotfiles.tmTheme"
bat cache --build >/dev/null 2>&1 || true

# ─── delta (git diff): цвета подключаются в .gitconfig через [include] ───
recolor "$DOTFILES/git/delta.gitconfig" "$GEN/delta.gitconfig.tmp"
sed 's/syntax-theme = .*/syntax-theme = dotfiles/' "$GEN/delta.gitconfig.tmp" > "$GEN/delta.gitconfig" && rm "$GEN/delta.gitconfig.tmp"

# ─── светлые копии (Dev Day) для светлого режима macOS: zsh/theme.zsh выбирает их при старте ───
map=$(make_map "$DOTFILES/themes/light/day.sh")
L="$GEN/light"; mkdir -p "$L/eza"
recolor "$DOTFILES/starship/starship.toml" "$L/starship.toml"
recolor "$DOTFILES/eza/theme.yml" "$L/eza/theme.yml"
recolor "$DOTFILES/lazygit/config.yml" "$L/lazygit.yml"
recolor "$DOTFILES/bat/themes/rose-pine.tmTheme" "$HOME/.config/bat/themes/dotfiles-light.tmTheme"
bat cache --build >/dev/null 2>&1 || true
# delta: светлые цвета — отдельной «фичей» [delta "day"], включается DELTA_FEATURES=+day
recolor "$DOTFILES/git/delta.gitconfig" "$L/delta.tmp"
sed -e 's/^\[delta\]/[delta "day"]/' -e 's/syntax-theme = .*/syntax-theme = dotfiles-light/' "$L/delta.tmp" >> "$GEN/delta.gitconfig"
rm "$L/delta.tmp"

echo "$name" > "$HOME/.config/dotfiles/theme"

# ─── обои: собрать, если ещё нет, и поставить ───
if [ "${NO_WALLPAPER:-}" != 1 ]; then
    if [ ! -f "$THEME_WALLPAPER" ]; then
        echo "рисую обои…"
        mkdir -p "$(dirname "$THEME_WALLPAPER")"
        swift "$DOTFILES/$THEME_WALLPAPER_SRC" "$THEME_WALLPAPER" >/dev/null
    fi
    python3 "$DOTFILES/themes/set-wallpaper.py" "$THEME_WALLPAPER" >/dev/null   # на все рабочие столы
    printf '%s\n' "$THEME_WALLPAPER" > "$HOME/.config/dotfiles/wall-path"        # для backdrop
fi

# ─── иконки приложений и папки ~/dev в цветах темы ───
if [ "${NO_ICONS:-}" != 1 ]; then
    recolor "$DOTFILES/icons/icons.swift" "$GEN/icons.swift"
    recolor "$DOTFILES/icons/folder.swift" "$GEN/folder.swift"
    swift "$GEN/icons.swift" apply 2>/dev/null | grep -c '✓' | xargs -I{} echo "иконок обновлено: {}"
    swift "$GEN/folder.swift" apply >/dev/null 2>&1 || true
    killall Dock 2>/dev/null || true
fi

# Ghostty перечитывает конфиг сам (AppleScript), если запущен
pgrep -xq ghostty && osascript -e 'tell application "Ghostty" to if (count terminals) > 0 then perform action "reload_config" on first terminal' >/dev/null 2>&1 || true
echo "тема: $THEME_TITLE"
