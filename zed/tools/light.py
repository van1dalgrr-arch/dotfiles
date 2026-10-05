#!/usr/bin/env python3
# ============================================================
#   Dev Day — светлая пара к Dev Night, собирается из неё же.
#   Меняешь Dev Night → python3 zed/tools/light.py → обе темы в themes/dev-night.json остаются согласованы.
#   Фон — почти белый, акценты те же (фиолетовый, синий, розовый), но на тон глубже,
#   чтобы читались на белом (yellow-500 на белом не виден → amber-700 и т.п.).
# ============================================================
import json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
PATH = os.path.join(HERE, "..", "dev-night-theme", "themes", "dev-night.json")

# тёмный цвет → светлый (без альфы; альфа-суффикс сохраняется)
MAP = {
    # фоны и поверхности
    "#101010": "#fafafb", "#141414": "#f3f3f6", "#161616": "#f1f1f5", "#171717": "#f3effd",
    "#181818": "#ffffff", "#191919": "#ececf1", "#1c1c1c": "#ebebf0", "#1e1e1e": "#e3e3ea",
    "#1f1f1f": "#e8e8ee", "#202020": "#e5e5ec", "#222222": "#e1e1ea", "#242424": "#dddde6",
    "#262626": "#d9d9e3", "#2c2c2c": "#d2d3dc", "#333333": "#c9cad6", "#3c3c3c": "#b1b4c4",
    # серые тексты и служебное
    "#45495a": "#a3a6b8", "#4a4e60": "#9da0b3", "#4f4f4f": "#9e9ea8", "#555a6e": "#8a8ea4",
    "#575c72": "#7d8199", "#5a5a5a": "#8a8a94", "#666666": "#6e6e78", "#686d86": "#6c7190",
    "#6a6a6a": "#74747e", "#6a6f88": "#727793", "#6e6e6e": "#6e6e78", "#6f748c": "#6a6f88",
    "#7c82a0": "#5a607e", "#7e7e7e": "#6a6a74", "#858aa3": "#5c6180", "#a0a0a0": "#55555f",
    "#a0a8d0": "#4a5277", "#a3a8c3": "#2e3350", "#b8bdd4": "#3d4262", "#c8cfec": "#2c3254",
    "#d6d9e8": "#1b1e2d", "#eceef8": "#0f111a", "#ffffff": "#0f111a",
    # акценты — на тон глубже
    "#a855f7": "#7c3aed", "#c084fc": "#9333ea", "#818cf8": "#4f46e5", "#3b82f6": "#2563eb",
    "#0ea5e9": "#0284c7", "#ec4899": "#db2777", "#ef4444": "#dc2626", "#f97316": "#c2410c",
    "#f59e0b": "#b45309", "#eab308": "#a16207",
    # пастель терминала → насыщенные
    "#9fb8e8": "#1d4ed8", "#b4c8f0": "#2563eb", "#f5a3b8": "#be185d", "#f0d39c": "#92400e",
}

# полупрозрачные белые подсветки на тёмном → такие же чёрные на светлом
def recolor(v):
    m = re.fullmatch(r"#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?", v)
    if not m:
        return v
    base, alpha = "#" + m.group(1).lower(), m.group(2) or ""
    if base == "#ffffff" and alpha:
        return "#000000" + alpha
    if base == "#000000":
        return v
    if base not in MAP:
        raise SystemExit(f"нет светлой пары для {base} — добавь в MAP")
    return MAP[base] + alpha

def walk(x):
    if isinstance(x, dict):
        return {k: walk(v) for k, v in x.items()}
    if isinstance(x, list):
        return [walk(v) for v in x]
    return recolor(x) if isinstance(x, str) else x

family = json.load(open(PATH))
dark = next(t for t in family["themes"] if t["appearance"] == "dark")
style = walk(dark["style"])

# терминал: в светлой теме чёрный и белый меняются местами
style.update({
    "terminal.background": "#fafafb", "terminal.foreground": "#1b1e2d",
    "terminal.bright_foreground": "#0f111a", "terminal.dim_foreground": "#6a6a74",
    "terminal.ansi.black": "#1b1e2d", "terminal.ansi.bright_black": "#6c7190",
    "terminal.ansi.white": "#d2d3dc", "terminal.ansi.bright_white": "#ffffff",
})

light = {"name": "Dev Day", "appearance": "light", "style": style}
family["themes"] = [dark, light]
with open(PATH, "w") as f:
    json.dump(family, f, indent=2, ensure_ascii=False)
    f.write("\n")
print("Dev Day ← Dev Night:", PATH)
