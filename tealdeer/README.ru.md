# tealdeer

🇬🇧 [English version](README.md)

Конфиг [tealdeer](https://github.com/tealdeer-rs/tealdeer) — короткие примеры команд (`tldr tar`).

| Файл | Что это |
|---|---|
| `config.toml` | стиль и автообновление страниц |

**`install.sh` ставит симлинками:**

- `config.toml` → `~/.config/tealdeer/config.toml`

## Как пользоваться

```bash
tldr tar        # самые нужные примеры, без простыни man
tldr -u         # обновить страницы вручную (сами обновляются раз в 30 дней, а ещё в `update`)
```

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
