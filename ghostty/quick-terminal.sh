#!/bin/bash
# Выпадающий терминал Ghostty по ctrl+` (вызывает AeroSpace): переключить и отдать ему фокус.
# Хелпер активации собирается один раз из ghostty/activate.swift.
set -u
dir="$(cd "$(dirname "$0")" && pwd)"
bin="$HOME/.cache/dotfiles/ghostty-activate"
if [ ! -x "$bin" ] || [ "$dir/activate.swift" -nt "$bin" ]; then
    mkdir -p "$(dirname "$bin")" && swiftc -O "$dir/activate.swift" -o "$bin" 2>/dev/null
fi
osascript "$dir/quick-terminal.applescript" "$bin"
