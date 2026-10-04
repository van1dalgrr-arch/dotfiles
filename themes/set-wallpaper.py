#!/usr/bin/env python3
# Ставит обои на ВСЕ рабочие столы (Spaces) и мониторы сразу.
# AppleScript (System Events) меняет только текущий стол, поэтому правим базу обоев macOS
# (com.apple.wallpaper/Store/Index.plist) и перезапускаем WallpaperAgent.
# Перед записью кладём копию Index.plist.bak рядом.
#   set-wallpaper.py ~/Pictures/Wallpapers/kanagawa-dynamic.heic
import os, plistlib, shutil, subprocess, sys
from pathlib import Path
from urllib.parse import quote

img = Path(sys.argv[1]).expanduser().resolve()
if not img.is_file():
    sys.exit(f"нет файла: {img}")
store = Path.home() / "Library/Application Support/com.apple.wallpaper/Store/Index.plist"
url = "file://" + quote(str(img))

data = plistlib.loads(store.read_bytes())
shutil.copy2(store, store.with_suffix(".plist.bak"))
config = plistlib.dumps({"type": "imageFile", "url": {"relative": url}}, fmt=plistlib.FMT_BINARY)

changed = 0
def walk(node):
    global changed
    if isinstance(node, dict):
        for key, val in node.items():
            # только «Desktop» (обои); «Idle» — заставка, её не трогаем
            if key == "Desktop" and isinstance(val, dict) and "Content" in val:
                val["Content"]["Choices"] = [{"Configuration": config, "Files": [],
                                              "Provider": "com.apple.wallpaper.choice.image"}]
                val["Content"]["EncodedOptionValues"] = "$null"   # без «заливки цветом» от старой картинки
                changed += 1
            else:
                walk(val)
    elif isinstance(node, list):
        for v in node:
            walk(v)
walk(data)

store.write_bytes(plistlib.dumps(data, fmt=plistlib.FMT_BINARY))
subprocess.run(["killall", "WallpaperAgent"], stderr=subprocess.DEVNULL)
print(f"обои на всех столах ({changed}): {img.name}")
