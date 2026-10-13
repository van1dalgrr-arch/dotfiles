# starship

🇬🇧 [English version](README.md)

Запасной промпт [starship](https://starship.rs). По умолчанию работает свой — [zsh/prompt.zsh](../zsh/prompt.zsh).

| Файл | Что это |
|---|---|
| `starship.toml` | используется только с `PROMPT_ENGINE=starship` в `~/.zshenv` |

**`install.sh` ставит симлинками:**

- `starship.toml` → `~/.config/starship.toml`

## Как включить

```bash
echo 'export PROMPT_ENGINE=starship' >> ~/.zshenv && exec zsh      # включить
sed -i '' '/PROMPT_ENGINE=starship/d' ~/.zshenv && exec zsh      # вернуть свой промпт
```

Свой промпт быстрее (вне git — ни одного процесса), поэтому он по умолчанию. starship оставлен как запасной:
если захочется модулей, которых нет в своём. Цвета для него тоже генерирует `theme`.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
