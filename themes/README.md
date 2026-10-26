# Themes

🇷🇺 [Русская версия](README.ru.md)

Color palettes and the script that recolors everything. Pictures of all themes: [docs/themes.md](../docs/themes.md).

| File | What |
|---|---|
| `vesper.sh` | default: near-black, saturated violet and blue |
| `kanagawa.sh` | Kanagawa Wave |
| `tokyonight.sh` · `gruvbox-material.sh` · `everforest.sh` · `oxocarbon.sh` | Tokyo Night, Gruvbox Material, Everforest, Oxocarbon |
| `rose-pine.sh` | **reference palette**: all configs are written in its colors; can't be removed |
| `light/day.sh` | Dev Day, the light palette used in macOS light mode |
| `apply.sh` | `theme <name>`: recolors configs role by role into `~/.config` and `~/.cache` |
| `set-wallpaper.py` | sets a wallpaper on every Space at once |

## New theme

Copy a palette file, change the 19 `T_*` colors, then `theme <name>`.

## Using it

```bash
theme              # pick with a color preview
theme kanagawa     # right away
```

One palette recolors Ghostty, the prompt, fzf, bat, delta, btop, eza, lazygit, starship, app and folder icons,
and sets the theme's wallpaper. Generated files go to `~/.config` and `~/.cache/dotfiles-theme`, never into the repo.
macOS light mode switches to Dev Day by itself — in Ghostty and Zed.

[← dotfiles](../README.md)
