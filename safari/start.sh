#!/usr/bin/env bash
# Собрать стартовую страницу Safari: перекрашенная под тему копия safari/start.html (её пишет
# themes/apply.sh) + текущие обои рядом (bg.jpg — Safari в песочнице не читает ~/Pictures,
# а файл рядом со страницей — читает). Вызывают theme (apply.sh) и wall. Результат:
# ~/.cache/dotfiles-theme/start/index.html — его и ставит домашней страницей macos.sh safari.
set -euo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
GEN="$HOME/.cache/dotfiles-theme"
out="$GEN/start"
mkdir -p "$out"

src="$GEN/start.tmpl.html"
[ -f "$src" ] || src="$DOTFILES/safari/start.html"          # темы ещё не применяли — эталонные цвета
cp -f "$src" "$out/index.html"

wall=$(cat "$HOME/.config/dotfiles/wall-path" 2>/dev/null || true)
if [ -n "$wall" ] && [ -f "$wall" ]; then
    # первый кадр, 2560 по ширине, JPEG — HEIC с 12 кадрами Safari открыл бы, но весит он в разы больше
    sips -s format jpeg -s formatOptions 82 -Z 2560 "$wall" --out "$out/bg.jpg" >/dev/null
else
    rm -f "$out/bg.jpg"                                          # без обоев — просто фон темы
fi
