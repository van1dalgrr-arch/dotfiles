# Dev Night for GoLand

🇷🇺 [Русская версия](README.ru.md)

Dev Night and Dev Day for GoLand and other JetBrains IDEs, generated from the Zed theme.

| File | What |
|---|---|
| `Dev Night.icls` | editor colors, dark |
| `Dev Day.icls` | editor colors, light |
| `build.py` | generates both `.icls` and the plugin jar (UI + editor) into `dist/` |

## Install

**Plugin:** download the jar from the [release](https://github.com/van1dalgrr-arch/dotfiles/releases/tag/jetbrains-v1.0.0) → Settings → Plugins → ⚙️ → Install Plugin from Disk → Appearance → Theme → Dev Night.

**Editor colors only:** Settings → Editor → Color Scheme → ⚙️ → Import Scheme → `Dev Night.icls`.

Rebuild: `python3 jetbrains/build.py`.

[← dotfiles](../README.md)
