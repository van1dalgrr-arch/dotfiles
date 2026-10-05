# Dev Night & Dev Day for GoLand

Editor color schemes for GoLand and any other JetBrains IDE (IntelliJ IDEA, PyCharm, WebStorm…).
**Dev Night** is near-black with saturated violet and blue accents. **Dev Day** is its light twin.
Both are generated from the [Zed theme](../zed/dev-night-theme) by `build.py`, so the colors match everywhere.

![Dev Night and Dev Day](../docs/zed-themes.png)

## Install

1. Download [`Dev Night.icls`](Dev%20Night.icls) (and/or [`Dev Day.icls`](Dev%20Day.icls)).
2. GoLand → **Settings → Editor → Color Scheme** → ⚙️ → **Import Scheme…** → pick the file.
3. Select **Dev Night** in the scheme list → OK.

Recommended font: JetBrains Mono, 14. Pair it with the **Dark** UI theme (or **Light** for Dev Day).
To switch with macOS appearance: **Settings → Appearance → Sync with OS**, then pick Dev Night for dark and Dev Day for light.

## Build

```bash
python3 jetbrains/build.py   # regenerates both .icls from the Zed theme
```
