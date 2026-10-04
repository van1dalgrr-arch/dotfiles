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

## Docker → OrbStack

Docker работает через OrbStack вместо Docker Desktop: те же `docker` / `docker compose`,
но память берётся по мере надобности и отдаётся обратно (на 8 ГБ это заметно).

```bash
docker context use orbstack        # OrbStack (сейчас)
docker context use desktop-linux   # вернуться на Docker Desktop
```

Старые образы остались в Docker Desktop. Перенести: OrbStack → Settings → Migrate from Docker Desktop
(или просто пересобрать `docker compose build`).

## Живые обои

`icons/wallpaper.swift` рисует горы и сосны в Rosé Pine в 8 вариантах освещения
(ночь → рассвет → день → закат → сумерки) и собирает их в динамический HEIC.
Кадры по времени суток переключает сама macOS, в фоне ничего не работает.

```bash
swift icons/wallpaper.swift ~/Pictures/Wallpapers/rose-pine-dynamic.heic   # собрать
swift icons/wallpaper.swift /tmp/wp/                                       # все кадры в PNG — посмотреть
```

Цвета каждого времени суток — структуры `Look` в начале файла, расписание — массив `frames`.
