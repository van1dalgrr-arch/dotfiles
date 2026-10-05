# Ghostty

🇬🇧 [English version](README.md)

Конфиг терминала [Ghostty](https://ghostty.org): без заголовка, выпадающий терминал по `` ctrl+` ``, плавный курсор, фон из обоев.

| Файл | Что это |
|---|---|
| `config.ghostty` | шрифт, отступы, сплиты, выпадающий терминал, шейдеры, клавиши; подключает сгенерированную тему и фон |
| `shaders/cursor_smooth.glsl` | плавный курсор: настоящий скрыт, шейдер рисует и ведёт его |
| `shaders/cursor_trail.glsl` | светящийся шлейф на больших прыжках; цвета перекрашивает `theme` |
| `shaders/.prefix.glsl` | заголовок шейдеров Ghostty — только чтобы `make check` компилировал шейдеры |
| `config.ghostty.pre-clean` | старая копия, не используется |

**`install.sh` ставит симлинками:**

- `config.ghostty` → `~/.config/ghostty/config.ghostty`
- `shaders/cursor_smooth.glsl` → `~/.config/ghostty/shaders/cursor_smooth.glsl`

## Генерируется, не в git

`theme` пишет `~/.config/ghostty/theme.ghostty` и две темы (`dotfiles-dark`, `dotfiles-light`) — Ghostty следует светлому/тёмному режиму macOS. `backdrop` пишет `~/.config/ghostty/backdrop.ghostty`. Перечитать после изменений: `cmd+shift+,`.

## Выпадающий терминал

Работает из любого приложения, только если у Ghostty есть **Универсальный доступ** (Настройки → Конфиденциальность и безопасность). `dot doctor` это проверяет.

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
