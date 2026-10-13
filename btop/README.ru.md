# btop

🇬🇧 [English version](README.md)

Конфиг и тема [btop](https://github.com/aristocratos/btop) — монитор ресурсов (`top` — алиас на него).

| Файл | Что это |
|---|---|
| `btop.conf` | настройки btop; большинство комментариев — от самого btop |
| `themes/rose-pine.theme` | эталонная тема; `theme` пишет перекрашенную `dotfiles.theme` |

**`install.sh` ставит симлинками:**

- `btop.conf` → `~/.config/btop/btop.conf`
- `themes/rose-pine.theme` → `~/.config/btop/themes/rose-pine.theme`

## Как пользоваться

`top` открывает btop: процессор, память, сеть и процессы (`shown_boxes = cpu mem net proc`), обновление раз в 2 с,
сортировка по CPU. `f` — фильтр процессов, `k` — завершить выбранный, `esc` — меню, `q` — выйти.
Для вопроса «что ест память» удобнее `ram`: он считает по приложениям, а не по процессам.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
