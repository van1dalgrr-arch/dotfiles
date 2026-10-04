# dotfiles

| `ram` — кто ест память | `zsh/ram.zsh` |
Настройки терминала на macOS. Тема везде одна: Rosé Pine.

| `ram` — кто ест память | `zsh/ram.zsh` |
| Что | Файл |
|---|---|
| zsh | `zsh/.zshrc` |
| Ghostty (+ шлейф курсора) | `ghostty/config.ghostty`, `ghostty/shaders/` |
| Тайлинг окон (AeroSpace) | `aerospace/aerospace.toml` |
| Шпаргалка `?` / Ctrl+/ | `zsh/cheatsheet.zsh` |
| Промпт (starship) | `starship/starship.toml` |
| git + delta | `git/.gitconfig` |
| lazygit | `lazygit/config.yml` |
| btop | `btop/` |
| eza | `eza/theme.yml` |
| fastfetch | `fastfetch/config.jsonc` |
| tldr (tealdeer) | `tealdeer/config.toml` |

| `ram` — кто ест память | `zsh/ram.zsh` |
## Установка на новый Mac

| `ram` — кто ест память | `zsh/ram.zsh` |
Сначала нужны Homebrew и oh-my-zsh, потом:

| `ram` — кто ест память | `zsh/ram.zsh` |
```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
brew bundle
./install.sh
```

| `ram` — кто ест память | `zsh/ram.zsh` |
`install.sh` создаёт симлинки из системы на файлы в репозитории. Правишь конфиг как обычно, а изменения сразу видны в `git status` этого репозитория.
