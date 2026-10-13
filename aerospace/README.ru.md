# AeroSpace

🇬🇧 [English version](README.md)

Конфиг [AeroSpace](https://github.com/nikitabobko/AeroSpace) — тайлинговый оконный менеджер в духе i3. Хоткеи работают в любой раскладке.

| Файл | Что это |
|---|---|
| `aerospace.toml` | столы, хоткеи (`alt-…`), правила приложений: Zed → стол 2, Safari → 3, Ghostty плавает |

**`install.sh` ставит симлинками:**

- `aerospace.toml` → `~/.config/aerospace/aerospace.toml`

## Заметки

AeroSpace стартует при входе и запускает Ghostty в фоне — поэтому выпадающий терминал (`` ctrl+` ``) всегда доступен. Окна Ghostty плавают на текущем столе: тайлинг ломал выпадающий терминал. Ещё он ловит `` ctrl+` `` и запускает `ghostty/quick-terminal.applescript` — выпадающий терминал Ghostty. Применить изменения: `alt-shift-c`. Все хоткеи — [docs/hotkeys.md](../docs/hotkeys.md).

## Как пользоваться

- **Окна раскладываются сами** плиткой; `alt-h/j/k/l` — фокус, `alt-shift-h/j/k/l` — переставить, `alt-1…9` — стол.
- **Раскладка:** `alt-/` — плитки, `alt-,` — аккордеон, `alt-shift-f` — на весь экран, `alt-shift-space` — плавающее ↔ плитка.
- **Размер:** `alt--` / `alt-=` или режим `alt-r` (дальше `h/j/k/l`, `esc` — выйти).
- **Важно для других программ:** весь слой `alt` (и `alt-shift`) занят AeroSpace, поэтому до приложений он не доходит.
  Свои хоткеи в редакторах вешай на `cmd`, `ctrl-alt` или F-клавиши — так сделано в Rune.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
