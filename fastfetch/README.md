# fastfetch

🇷🇺 [Русская версия](README.ru.md)

Configs for [fastfetch](https://github.com/fastfetch-cli/fastfetch), the system summary.

| File | What |
|---|---|
| `greeting.jsonc` | the light greeting in every new Ghostty window: macOS logo, uptime, RAM (~35 ms) |
| `config.jsonc` | full version for `ff` / `neofetch` |

**Installed by `install.sh` as symlinks:**

- `config.jsonc` → `~/.config/fastfetch/config.jsonc`

## Notes

RAM is shown like in `ram` (via `memory_pressure`): macOS file cache doesn't count as used. Reminders under the greeting live in [zsh/reminders.zsh](../zsh/reminders.zsh).

[← dotfiles](../README.md)
