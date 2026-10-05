# Если Mac сбросился

Почти всё возвращается одной командой из этого репозитория. Руками остаётся войти в аккаунты,
поставить приложения не из Brewfile и склонировать проекты. Всё, что не запушено, пропадает.

## Восстановление (~1 час, в основном ожидание загрузок)

1. Инструменты Xcode (git, компилятор): `xcode-select --install`
2. Homebrew: одна строка с [brew.sh](https://brew.sh), потом `eval "$(/opt/homebrew/bin/brew shellenv)"`
3. dotfiles:
   ```bash
   git clone https://github.com/van1dalgrr-arch/dotfiles ~/dotfiles
   cd ~/dotfiles && make install
   ```
4. Настройки macOS: `./macos.sh` (план) → `./macos.sh --yes`, потом выйти и зайти в систему
5. Открыть Ghostty → `dot doctor`. Всё должно быть ✓, у каждого ✗ написано, как починить

Необязательно: `make devops` (kind, OpenTofu, tflint…).

## Что вернётся само

| Что | Откуда |
|---|---|
| Программы: Ghostty, OrbStack, AeroSpace, Raycast, Yaak, TablePlus, Zed, VS Code, все CLI | `Brewfile` |
| Конфиги: zsh, промпт, git, Ghostty, AeroSpace, Zed, VS Code, btop, lazygit… | `install.sh` (симлинки) |
| Тема, обои, иконки приложений и папок | `theme vesper`, `wall eclipse` (рисуются из Swift-файлов) |
| Темы Zed Dev Night / Dev Day и иконки | `zed/dev-night-theme`, `zed/dev-night-icons` |
| gopls, air, govulncheck, gofumpt тех же версий | `go/tools.txt` |
| Расширения VS Code | `vscode/extensions.txt` |
| Клавиатура, Finder, Dock, скриншоты | `macos.sh` |

## Руками

- [ ] GitHub: `gh auth login` (вход по HTTPS через браузер, SSH-ключей нет)
- [ ] Проекты: `mkdir ~/dev && cd ~/dev && gh repo clone <имя>` для каждого (`gh repo list` — все свои)
- [ ] Войти: Telegram, Discord, Яндекс Музыка, Chrome, Claude, ChatGPT
- [ ] VPN (Happ / WireGuard): заново добавить конфиги
- [ ] Raycast: импортировать настройки, если сохранял экспорт (Settings → Advanced → Export)
- [ ] Zed: войти в аккаунт (для AI)
- [ ] Права в «Конфиденциальность и безопасность»: AeroSpace и Ghostty → Универсальный доступ (без этого не работают хоткеи и выпадающий терминал)

## Приложения не из Brewfile

Ставятся с сайтов или из App Store, `dot doctor --deep` показывает их как «нет в Brewfile»:
Telegram, Discord, Яндекс Музыка, Happ, Chrome, Spotify, ChatGPT, Claude, GitHub Desktop, JetBrains Toolbox, UTM, iTerm, Rectangle, Hammerspoon.
Нужное постоянно — лучше внести в `Brewfile` (`cask "telegram"` и т.п.), тогда тоже вернётся само.

## Что пропадает

| Что | Как не потерять |
|---|---|
| Незакоммиченное и незапушенное в проектах | `pl` — у проекта `!N` (изменения) или `⇡N` (не запушено) → закоммить и запушь |
| Ветки без upstream (только локальные) | `git push -u origin <ветка>` |
| Базы данных в контейнерах OrbStack (тома Docker) | для учебных — не страшно, миграции пересоздадут; важное — `pg_dump` |
| История команд (atuin), прыжки zoxide | не критично, наберётся заново |
| Всё остальное в домашней папке (загрузки, документы) | Time Machine или iCloud Drive |

## Как не терять в будущем

- **Time Machine** на внешний диск: встроено в macOS, сохраняет вообще всё, памяти не ест.
- Перед выходом из проекта — `pl`: если где-то `!` или `⇡`, запушить.
- Новая программа → сразу строка в `Brewfile`; новый конфиг → в репозиторий + `link` в `install.sh`.
- Обновление macOS (27 и дальше) ничего из этого не стирает — восстановление нужно только после стирания диска.
