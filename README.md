# dotfiles

Настройки терминала на macOS. Тема везде одна: Rosé Pine.

| Что | Файл |
|---|---|
| zsh | `zsh/.zshrc` |
| Ghostty (+ шлейф курсора) | `ghostty/config.ghostty`, `ghostty/shaders/` |
| Тайлинг окон (AeroSpace) | `aerospace/aerospace.toml` |
| Шпаргалка `?` / Ctrl+/ | `zsh/cheatsheet.zsh` |
| `ram` — кто ест память | `zsh/ram.zsh` |
| Промпт starship (запасной: `PROMPT_ENGINE=starship`) | `starship/starship.toml` |
| git + delta | `git/.gitconfig` |
| lazygit | `lazygit/config.yml` |
| btop | `btop/` |
| eza | `eza/theme.yml` |
| fastfetch | `fastfetch/config.jsonc` |
| tldr (tealdeer) | `tealdeer/config.toml` |
| Zed (лёгкий редактор, ~300 МБ против 1–2 ГБ у VS Code): тема Dev Night, иконки Dev Night Icons, задачи `ctrl-r`, сниппеты Go | `zed/` |
| Промпт на чистом zsh (без starship) + приветствие с логотипом Arch | `zsh/prompt.zsh`, `fastfetch/greeting.jsonc` |

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

Docker работает через OrbStack (Docker Desktop удалён 2026-10-04, данные перенесены
через `orb docker migrate`). Те же `docker` / `docker compose`, но память берётся
по мере надобности и отдаётся обратно — на 8 ГБ это заметно.

Если `docker compose` пропал: плагины — ссылки в `~/.docker/cli-plugins/` на
`/Applications/OrbStack.app/Contents/MacOS/xbin/docker-{compose,buildx}`.

## Живые обои

`icons/wallpaper.swift` рисует горы и сосны в Rosé Pine в 8 вариантах освещения
(ночь → рассвет → день → закат → сумерки) и собирает их в динамический HEIC.
Кадры по времени суток переключает сама macOS, в фоне ничего не работает.

```bash
swift icons/wallpaper.swift ~/Pictures/Wallpapers/rose-pine-dynamic.heic   # собрать
swift icons/wallpaper.swift /tmp/wp/                                       # все кадры в PNG — посмотреть
```

Цвета каждого времени суток — структуры `Look` в начале файла, расписание — массив `frames`.

## Защита от утечек

Перед каждым коммитом в любом репозитории `gitleaks` проверяет, что коммитится
(`git/hooks/pre-commit`). Нашёл пароль/токен/ключ — коммит не пройдёт, покажет файл и строку.
`git/ignore` — глобальный .gitignore: `.env`, ключи, `.DS_Store` не попадут никуда.
Хуки самих проектов (`.git/hooks`) продолжают работать — `git/hooks/_chain` их вызывает.

Ложное срабатывание: комментарий `gitleaks:allow` в строке или `git commit --no-verify`.

## Тесты

`got` — все тесты через gotestsum (строка на пакет, упавшие — с выводом),
`gotw` — перезапуск тестов при каждом сохранении файла.

## Темы: `theme`

`theme` — выбрать тему в fzf (с превью палитры), `theme kanagawa` / `theme rose-pine` — сразу.
Меняет весь терминал (Ghostty, промпт, подсветку, fzf, bat, delta, eza, lazygit, btop, шлейф курсора),
рамку окон, иконки в Dock и живые обои. VS Code не трогает. После смены — `cmd+shift+,` в Ghostty.

Как устроено: конфиги в репозитории написаны цветами Rosé Pine. Тема — файл `themes/<имя>.sh`
с теми же 19 ролями (`T_BASE`, `T_ROSE`, …). `themes/apply.sh` переводит каждый цвет Rosé Pine
в цвет темы по роли и кладёт готовые конфиги в `~/.config` / `~/.cache/dotfiles-theme` —
репозиторий не меняется. Новая тема = новый файл палитры (+ свои обои по желанию).

| Тема | Настроение | Обои |
|---|---|---|
| `rose-pine` | горы, сосны, луна | `icons/wallpaper.swift` |
| `kanagawa` | Фудзи, море сэйгайха, касуми, печать 波 | `icons/wallpaper-kanagawa.swift` |
| `vesper` | минимализм: почти чёрный, точечная сетка, контуры, мягкий свет | `icons/wallpaper-minimal.swift` |

## Лицензия

MIT — бери, копируй, меняй под себя. Тема Vesper — по мотивам [Vesper](https://github.com/raunofreiberg/vesper) (MIT).
