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

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
