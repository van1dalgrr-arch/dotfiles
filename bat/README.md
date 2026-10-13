# bat

🇷🇺 [Русская версия](README.ru.md)

Theme for [bat](https://github.com/sharkdp/bat), `cat` with syntax highlighting (`cat` is an alias for it).

| File | What |
|---|---|
| `themes/rose-pine.tmTheme` | reference theme in Rosé Pine colors; `theme` generates recolored `dotfiles` and `dotfiles-light` copies |

**Installed by `install.sh` as symlinks:**

- `themes/rose-pine.tmTheme` → `~/.config/bat/themes/rose-pine.tmTheme`

## Using it

```bash
cat main.go              # same as bat: highlighting, line numbers, git changes in the margin
bat -A file.txt          # show invisible characters (tabs, line ends)
bat --list-themes        # every theme; ours is dotfiles (and dotfiles-light in light mode)
```

It also highlights fzf previews (`ctrl-t`, `tab`) and logs in `orbstack`.

[← dotfiles](../README.md)
