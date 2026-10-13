# Твои фото

🇬🇧 [English version](README.md)

Фото для обоев-фотографий (`wall add <фото> [имя]`).

| Файл | Что это |
|---|---|
| `photos/` | твои фото; **в .gitignore**, на GitHub не уходят |

## Важно

Здесь папка в `.gitignore`, но сама она — копия **приватного** репозитория `dotfiles-photos`: `wall add` отправляет туда каждое новое фото, это резервная копия. На новом Mac: `gh repo clone dotfiles-photos ~/dotfiles/wallpapers/photos`.

## Как добавить фото

```bash
wall add ~/Downloads/photo.jpg sakura      # почистит JPEG-артефакты, увеличит под экран, отправит копию в приватный репозиторий
wall sakura                                # поставить
backdrop sakura                            # то же фото — тёмным фоном терминала
```

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
