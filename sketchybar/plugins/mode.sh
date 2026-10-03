#!/bin/bash
# Плашка режима AeroSpace: видна в resize/service, скрыта в main

case "$MODE" in
    resize)  sketchybar --set "$NAME" drawing=on icon=󰩨 label="RESIZE  hjkl · esc" ;;
    service) sketchybar --set "$NAME" drawing=on icon=󰒓 label="SERVICE  r f ⌫ · esc" ;;
    *)       sketchybar --set "$NAME" drawing=off ;;
esac
