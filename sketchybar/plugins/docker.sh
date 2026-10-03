#!/bin/bash
# Сколько контейнеров запущено. Docker выключен — виджет скрыт. Клик — lazydocker.

PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
if ids="$(docker ps -q 2>/dev/null)"; then
    count="$(printf '%s' "$ids" | grep -c .)"
    sketchybar --set "$NAME" drawing=on label="$count"
else
    sketchybar --set "$NAME" drawing=off
fi
