# Dev Night & Dev Day for GoLand

Editor color schemes for GoLand and any other JetBrains IDE (IntelliJ IDEA, PyCharm, WebStorm…).
**Dev Night** is near-black with saturated violet and blue accents. **Dev Day** is its light twin.
Both are generated from the [Zed theme](../zed/dev-night-theme) by `build.py`, so the colors match everywhere.

![Dev Night and Dev Day](../docs/zed-themes.png)

## Install

**Plugin (UI theme + editor colors), recommended**

1. Download `dev-night-theme-1.0.0.jar` from the [latest release](https://github.com/van1dalgrr-arch/dotfiles/releases/tag/jetbrains-v1.0.0).
2. GoLand → **Settings → Plugins** → ⚙️ → **Install Plugin from Disk…** → pick the `.jar` → restart.
3. **Settings → Appearance → Theme** → **Dev Night** (or Dev Day).

Coming to JetBrains Marketplace: then it's just **Settings → Plugins → Marketplace → "Dev Night"**.

**Editor colors only**

GoLand → **Settings → Editor → Color Scheme** → ⚙️ → **Import Scheme…** → [`Dev Night.icls`](Dev%20Night.icls) or [`Dev Day.icls`](Dev%20Day.icls).

To follow macOS dark/light: **Settings → Appearance → Sync with OS**, Dev Night for dark, Dev Day for light.

## Build

```bash
python3 jetbrains/build.py   # both .icls + the plugin jar in jetbrains/dist/, from the Zed theme
```
