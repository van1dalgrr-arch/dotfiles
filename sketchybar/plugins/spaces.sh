#!/bin/bash
# Перерисовывает все рабочие столы AeroSpace: подсветка активного,
# иконки приложений, пустые неактивные столы прячутся.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/helpers/icon_map.sh"

focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
windows="$(aerospace list-windows --all --format '%{workspace}|%{app-name}')"

args=(--animate tanh 12)
for sid in $(aerospace list-workspaces --all); do
    icons=""
    while IFS= read -r app; do
        [ -z "$app" ] && continue
        __icon_map "$app"
        icons+="${icons:+ }$icon_result"
    done <<< "$(printf '%s\n' "$windows" | awk -F'|' -v s="$sid" '$1==s {print $2}' | sort -u)"

    if [ "$sid" = "$focused" ]; then
        args+=(--set "space.$sid" drawing=on
               background.color=$IRIS icon.color=$BASE label.color=$BASE)
    elif [ -n "$icons" ]; then
        args+=(--set "space.$sid" drawing=on
               background.color=$TRANSPARENT icon.color=$SUBTLE label.color=$MUTED)
    else
        args+=(--set "space.$sid" drawing=off)
    fi
    args+=(--set "space.$sid" label="$icons" label.drawing=$([ -n "$icons" ] && echo on || echo off))
done

sketchybar "${args[@]}"
