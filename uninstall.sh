#!/usr/bin/env bash
# Откат install.sh: убрать симлинки, вернуть *.bak. Без --yes — только план; --purge — и сгенерированное темой
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
apply=0 purge=0
for a in "$@"; do
    case $a in --yes) apply=1 ;; --purge) purge=1 ;; *) echo "неизвестный флаг: $a"; exit 1 ;; esac
done

run() { if [ "$apply" = 1 ]; then "$@"; else echo "  [план] $*"; fi; }

while read -r src dst; do
    dst=$(eval echo "$dst")
    if [ "$(readlink "$dst" 2>/dev/null)" = "$DOTFILES/$src" ]; then
        run rm "$dst"
        if [ -e "$dst.bak" ]; then run mv "$dst.bak" "$dst"; fi
    fi
done < <(grep -E '^link ' "$DOTFILES/install.sh" | sed -E 's/^link +([^ ]+) +"?([^"]+)"?.*/\1 \2/')

if [ "$purge" = 1 ]; then
    for p in "$HOME/.cache/dotfiles-theme" "$HOME/.config/dotfiles" "$HOME/.config/ghostty/theme.ghostty" \
             "$HOME/.config/ghostty/shaders/cursor_trail.glsl" "$HOME/.config/btop/themes/dotfiles.theme" \
             "$HOME/.config/bat/themes/dotfiles.tmTheme" \
             "$HOME/.config/bat/themes/dotfiles-light.tmTheme" "$HOME/.config/ghostty/themes/dotfiles-dark" \
             "$HOME/.config/ghostty/themes/dotfiles-light" \
             "$HOME/.config/ghostty/backdrop.ghostty"; do
        [ -e "$p" ] && run rm -rf "$p"
    done
fi

if [ "$apply" = 1 ]; then
    echo "готово. Иконки приложений вернуть: swift $DOTFILES/icons/icons.swift reset"
else
    echo "это план. Выполнить: ./uninstall.sh --yes"
fi
