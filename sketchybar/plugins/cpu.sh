#!/bin/bash
# Загрузка CPU (сумма %cpu всех процессов / число ядер). Клик — btop.
source "$CONFIG_DIR/colors.sh"

cores="$(sysctl -n hw.ncpu)"
load="$(ps -A -o %cpu= | awk -v c="$cores" '{s+=$1} END {printf "%d", s/c}')"

color=$TEXT
[ "$load" -ge 50 ] && color=$GOLD
[ "$load" -ge 80 ] && color=$LOVE
sketchybar --set "$NAME" label="$load%" label.color=$color
