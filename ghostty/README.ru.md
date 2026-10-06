# Ghostty

🇬🇧 [English version](README.md)

Конфиг терминала [Ghostty](https://ghostty.org): прозрачный заголовок (только кнопки окна), выпадающий терминал по `` ctrl+` ``, плавный курсор, фон из обоев.

| Файл | Что это |
|---|---|
| `config.ghostty` | шрифт, отступы, сплиты, выпадающий терминал, шейдеры, клавиши; подключает сгенерированную тему и фон |
| `fx.sh` | переключатель эффектов для `fx`: пишет `~/.config/ghostty/fx.ghostty` |
| `shaders/cursor_smooth.glsl` | `cursor`: плавный курсор — настоящий скрыт, шейдер рисует и ведёт его |
| `shaders/cursor_trail.glsl` | `trail`: светящийся шлейф на больших прыжках курсора |
| `shaders/sparks.glsl` | `sparks`: при наборе из-под курсора вылетают искры |
| `shaders/focus.glsl` | `focus`: окно, получившее фокус, вспыхивает по краям — удобно с AeroSpace |
| `shaders/glow.glsl` | `glow`: мягкое неоновое свечение яркого текста (в светлой теме выключено) |
| `shaders/.prefix.glsl` | заголовок шейдеров Ghostty — только чтобы `make check` компилировал шейдеры |
| `quick-terminal.sh` | это запускает AeroSpace по `` ctrl+` ``: один раз собирает хелпер активации и вызывает AppleScript |
| `activate.swift` | активирует Ghostty, не поднимая все его окна: вперёд выходит только выпадающий терминал |
| `quick-terminal.applescript` | показать/спрятать выпадающий терминал; вызывает AeroSpace по `` ctrl+` `` |

**`install.sh` ставит симлинками:**

- `config.ghostty` → `~/.config/ghostty/config.ghostty`

## Генерируется, не в git

`theme` пишет `~/.config/ghostty/theme.ghostty` и две темы (`dotfiles-dark`, `dotfiles-light`) — Ghostty следует светлому/тёмному режиму macOS. `backdrop` пишет `~/.config/ghostty/backdrop.ghostty`. После `theme`, `wall`, `backdrop` и `update` Ghostty перечитывает конфиг сам (AppleScript `reload_config`); после ручной правки конфига — `cmd+shift+,`.

## Эффекты: `fx`

`fx` (fzf: Tab — отметить, Enter — переключить) или `fx on sparks`, `fx off trail`, `fx set none`. По умолчанию: `cursor trail focus`.
Цвета шейдеры берут из темы терминала (`iCursorColor`, `iPalette`), поэтому `theme` и светлый режим перекрашивают их сразу. Шейдеры используются прямо из репозитория, ничего не копируется.

## Выпадающий терминал

`` ctrl+` `` ловит AeroSpace (у него уже есть «Универсальный доступ») и запускает `quick-terminal.applescript`, который показывает выпадающий терминал Ghostty. Поэтому он работает из любого приложения, а Ghostty не нужно отдельное разрешение.

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
