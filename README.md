# dotfiles

Настройки терминала на macOS. Тема везде одна: Rosé Pine.

| Что | Файл |
|---|---|
| zsh | `zsh/.zshrc` |
| Ghostty (+ шлейф курсора) | `ghostty/config.ghostty`, `ghostty/shaders/` |
| Тайлинг окон (AeroSpace) | `aerospace/aerospace.toml` |
| Шпаргалка `?` / Ctrl+/ | `zsh/cheatsheet.zsh` |
| `ram` — кто ест память | `zsh/ram.zsh` |
| Промпт (starship) | `starship/starship.toml` |
| git + delta | `git/.gitconfig` |
| lazygit | `lazygit/config.yml` |
| btop | `btop/` |
| eza | `eza/theme.yml` |
| fastfetch | `fastfetch/config.jsonc` |
| tldr (tealdeer) | `tealdeer/config.toml` |

## Установка на новый Mac

Сначала нужны Homebrew и oh-my-zsh, потом:

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
brew bundle
./install.sh
```

`install.sh` создаёт симлинки из системы на файлы в репозитории. Правишь конфиг как обычно, а изменения сразу видны в `git status` этого репозитория.
