# Themes

```bash
theme            # pick in fzf, palette preview on the right
theme vesper     # apply directly
```

| Theme | Mood |
|---|---|
| `vesper` | near-black with saturated violet and blue — the main one |
| `kanagawa` | indigo and paper, inspired by Hokusai |
| `rose-pine` | soft and muted |

How it works: every config in the repo is written in Rosé Pine colors, and a theme is just a map
of "which color becomes which" across 19 roles (`themes/<name>.sh`). `themes/apply.sh` recolors copies
of the configs into `~/.config` and `~/.cache` in a single pass — the repo itself never changes when you switch.
It recolors Ghostty, the prompt, syntax highlighting, fzf, bat, delta, eza, lazygit, btop,
Dock and folder icons, and the wallpaper. VS Code keeps its own theme.
