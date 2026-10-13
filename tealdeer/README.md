# tealdeer

🇷🇺 [Русская версия](README.ru.md)

Config for [tealdeer](https://github.com/tealdeer-rs/tealdeer), short command examples (`tldr tar`).

| File | What |
|---|---|
| `config.toml` | style and auto-update of the pages |

**Installed by `install.sh` as symlinks:**

- `config.toml` → `~/.config/tealdeer/config.toml`

## Using it

```bash
tldr tar        # the examples you actually need, no man page wall
tldr -u         # update pages by hand (they update themselves every 30 days, and in `update`)
```

[← dotfiles](../README.md)
