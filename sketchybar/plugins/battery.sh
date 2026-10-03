#!/bin/bash
source "$CONFIG_DIR/colors.sh"

info="$(pmset -g batt)"
pct="$(printf '%s' "$info" | grep -Eo '[0-9]+%' | head -1 | tr -d %)"
[ -z "$pct" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

case $pct in
    9[0-9]|100) icon=󰁹 ;;
    [7-8][0-9]) icon=󰂁 ;;
    [5-6][0-9]) icon=󰁿 ;;
    [3-4][0-9]) icon=󰁽 ;;
    [1-2][0-9]) icon=󰁻 ;;
    *)          icon=󰂎 ;;
esac
color=$GOLD
[ "$pct" -le 20 ] && color=$LOVE
if printf '%s' "$info" | grep -q 'AC Power'; then
    icon=󰂄; color=$FOAM
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color=$color label="$pct%"
