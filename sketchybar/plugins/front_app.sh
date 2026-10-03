#!/bin/bash
# Иконка и имя активного приложения

[ "$SENDER" = "front_app_switched" ] || exit 0
source "$CONFIG_DIR/helpers/icon_map.sh"
__icon_map "$INFO"
sketchybar --set "$NAME" icon="$icon_result" label="$INFO"
