# zsh

🇷🇺 [Русская версия](README.ru.md)

Shell config: hand-written prompt, aliases, functions. Starts in ~0.15 s. All commands: [docs/guide.ru.md](../docs/guide.ru.md).

| File | What |
|---|---|
| `.zshrc` | PATH, oh-my-zsh, fzf, zoxide, atuin, aliases, `p`, `pl`, `up`, `gco`, greeting |
| `prompt.zsh` | framed prompt, transient prompt, command-not-found hints |
| `theme.zsh` | `theme`, `wall`, `wall add`, `backdrop`, `palette`, light mode |
| `reminders.zsh` | reminders under the greeting: stale `update`, unpushed work |
| `backend.zsh` | `db`, `vuln`, `load`, Kubernetes aliases |
| `gonew.zsh` | `gonew`: new Go project with CI |
| `update.zsh` | `update`: weekly upkeep |
| `cheatsheet.zsh` | `?` / `ctrl+/` cheatsheet |
| `ram.zsh` | `ram`: memory by app |
| `completions/_dot` | Tab completion for `dot`, `theme`, `wall`, `backdrop`, `awake` |

**Installed by `install.sh` as symlinks:**

- `.zshrc` → `~/.zshrc`

## Load order

`.zshrc` sources oh-my-zsh, then `theme.zsh` (palette first: everything else uses its colors), the prompt, tools, and the other modules. Syntax highlighting goes last.

[← dotfiles](../README.md)
