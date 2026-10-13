# starship

🇷🇺 [Русская версия](README.ru.md)

Optional [starship](https://starship.rs) prompt. The default prompt is the hand-written one in [zsh/prompt.zsh](../zsh/prompt.zsh).

| File | What |
|---|---|
| `starship.toml` | used only with `PROMPT_ENGINE=starship` in `~/.zshenv` |

**Installed by `install.sh` as symlinks:**

- `starship.toml` → `~/.config/starship.toml`

## Turning it on

```bash
echo 'export PROMPT_ENGINE=starship' >> ~/.zshenv && exec zsh      # on
sed -i '' '/PROMPT_ENGINE=starship/d' ~/.zshenv && exec zsh      # back to the own prompt
```

The own prompt is faster (no processes outside git), so it's the default. starship is kept as a fallback
in case you want modules the own one doesn't have. `theme` generates its colors too.

[← dotfiles](../README.md)
