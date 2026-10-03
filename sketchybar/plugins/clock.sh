#!/bin/bash
# «сб 3 окт · 17:42»
label="$(LC_ALL=ru_RU.UTF-8 date '+%a %-d %b · %H:%M' | sed 's/\.//')"
sketchybar --set "$NAME" label="$label"
