#!/usr/bin/env bash
# ============================================================
#   Применить тему ко всему терминалу и обоям:  themes/apply.sh kanagawa
#
#   Конфиги в репозитории написаны цветами Rosé Pine (эталон). Для другой темы
#   они «переводятся» по таблице themes/rose-pine.sh → themes/<тема>.sh
#   (роль к роли) и кладутся в ~/.config / ~/.cache — репозиторий не меняется.
#   VS Code тема не трогает.
# ============================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
name="${1:-$(command cat "$HOME/.config/dotfiles/theme" 2>/dev/null || echo rose-pine)}"
theme="$DOTFILES/themes/$name.sh"
[ -f "$theme" ] || { echo "нет темы: $name (есть: $(cd "$DOTFILES/themes" && command ls *.sh | sed 's/\.sh$//' | grep -v apply | tr '\n' ' '))"; exit 1; }

GEN="$HOME/.cache/dotfiles-theme"
mkdir -p "$GEN" "$HOME/.config/dotfiles"

# ─── таблица перевода цветов ───
roles=(BASE SURFACE OVERLAY HL_LOW HL_MED HL_HIGH MUTED SUBTLE TEXT LOVE GOLD ROSE PINE FOAM IRIS
       DIFF_ADD DIFF_ADD_EMPH DIFF_DEL DIFF_DEL_EMPH)
map=""
for r in "${roles[@]}"; do
    from=$(source "$DOTFILES/themes/rose-pine.sh"; eval echo "\$T_$r")
    to=$(source "$theme"; eval echo "\$T_$r")
    map+="$from=$to,"
done

# Один проход perl: #rrggbb, 0xrrggbb, 0xffrrggbb, hex("rrggbb") (swift) → цвет темы;
# цепочек замен не бывает
recolor() {
    MAP="$map" perl -pe '
        BEGIN { %m = map { split /=/ } split /,/, lc $ENV{MAP} }
        s/(#|0x(?:[0-9a-fA-F]{2})?|hex\(")([0-9a-fA-F]{6})\b/$1 . ($m{lc $2} \/\/ $2)/ge
    ' "$1" > "$2"
}

THEME_GHOSTTY_EXTRA=""
source "$theme"

# ─── Ghostty: тема + цвета курсора/выделения/иконки (подключается через config-file) ───
command cat > "$HOME/.config/ghostty/theme.ghostty" <<EOF
# сгенерировано themes/apply.sh ($name) — не править руками
theme = $THEME_GHOSTTY
cursor-color = #$T_ROSE
selection-background = #$T_HL_MED
unfocused-split-fill = #$T_BASE
macos-icon-ghost-color = #$T_ROSE
macos-icon-screen-color = #$T_BASE,#$T_OVERLAY
${THEME_GHOSTTY_EXTRA:-}
EOF

# шлейф курсора: цвета в шейдере заданы vec3 с комментарием // #hex
shader="$HOME/.config/ghostty/shaders/cursor_trail.glsl"
mkdir -p "$(dirname "$shader")"
[ -L "$shader" ] && rm "$shader"
recolor "$DOTFILES/ghostty/shaders/cursor_trail.glsl" "$GEN/cursor_trail.glsl"
perl -pe 's{vec3\([^)]*\)(;\s*//\s*#([0-9a-f]{6}))}{sprintf("vec3(%.3f, %.3f, %.3f)%s", (map { hex($_)/255 } unpack("(A2)3", $2)), $1)}ge' \
    "$GEN/cursor_trail.glsl" > "$shader"

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

echo "$name" > "$HOME/.config/dotfiles/theme"

# ─── обои: собрать, если ещё нет, и поставить ───
if [ "${NO_WALLPAPER:-}" != 1 ]; then
    if [ ! -f "$THEME_WALLPAPER" ]; then
        echo "рисую обои…"
        mkdir -p "$(dirname "$THEME_WALLPAPER")"
        swift "$DOTFILES/$THEME_WALLPAPER_SRC" "$THEME_WALLPAPER" >/dev/null
    fi
    python3 "$DOTFILES/themes/set-wallpaper.py" "$THEME_WALLPAPER" >/dev/null   # на все рабочие столы
fi

# ─── иконки приложений и папки ~/dev в цветах темы ───
if [ "${NO_ICONS:-}" != 1 ]; then
    recolor "$DOTFILES/icons/icons.swift" "$GEN/icons.swift"
    recolor "$DOTFILES/icons/folder.swift" "$GEN/folder.swift"
    swift "$GEN/icons.swift" apply 2>/dev/null | grep -c '✓' | xargs -I{} echo "иконок обновлено: {}"
    swift "$GEN/folder.swift" apply >/dev/null 2>&1 || true
    killall Dock 2>/dev/null || true
fi

echo "тема: $THEME_TITLE"
