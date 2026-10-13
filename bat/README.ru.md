# bat

🇬🇧 [English version](README.md)

Тема для [bat](https://github.com/sharkdp/bat) — `cat` с подсветкой синтаксиса (`cat` — алиас на него).

| Файл | Что это |
|---|---|
| `themes/rose-pine.tmTheme` | эталонная тема в цветах Rosé Pine; `theme` генерирует перекрашенные копии `dotfiles` и `dotfiles-light` |

**`install.sh` ставит симлинками:**

- `themes/rose-pine.tmTheme` → `~/.config/bat/themes/rose-pine.tmTheme`

## Как пользоваться

```bash
cat main.go              # то же, что bat: подсветка, номера строк, изменения git на полях
bat -A file.txt          # показать невидимые символы (табы, переводы строк)
bat --list-themes        # все темы; своя называется dotfiles (и dotfiles-light для светлого режима)
```

Он же подсвечивает превью в fzf (`ctrl-t`, `tab`) и логи в `orbstack`.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
