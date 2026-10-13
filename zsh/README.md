# zsh

🇷🇺 [Русская версия](README.ru.md)

Shell config: hand-written prompt, aliases, functions. Starts in ~0.15 s. All commands: [docs/guide.md](../docs/guide.md).

| File | What |
|---|---|
| `.zshrc` | PATH, oh-my-zsh, fzf, zoxide, atuin, aliases, `p`, `pl`, `up`, `gco`, the `docker` wrapper (starts OrbStack on demand), `orbstack` → [berth](../berth), greeting |
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

## What the shell does

- **A cheatsheet at hand:** `?` or `ctrl+/` — every hotkey, function and alias, searchable.
- **A prompt that doesn't lag:** no processes outside git, one `git status` inside. After `enter` it collapses to `$ command`.
- **Help when you mistype:** an unknown command suggests `brew install` and similar own commands.
- **fzf everywhere:** `ctrl-t` — file with a preview, `alt-c` — folder, `tab` — completion with a preview, `ctrl-r` — history (atuin).
- **Folder jumps:** `z part-of-path` (zoxide) and `p` — a project from `~/dev`.
- **Memory on 8 GB:** `ram` — who eats memory, by app; `lean on` / `lean off` — close the heavy stuff and bring it back.
- **Docker without "cannot connect":** the `docker` wrapper starts OrbStack when it's off.
- **Sleep:** `awake on` — don't sleep with the lid closed (for working from the phone), `awake off` — back to normal.

[← dotfiles](../README.md)
