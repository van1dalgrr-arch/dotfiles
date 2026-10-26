# Темы

🇬🇧 [English version](README.md)

Палитры и скрипт, который перекрашивает всё. Картинки всех тем — [docs/themes.md](../docs/themes.md).

| Файл | Что это |
|---|---|
| `vesper.sh` | по умолчанию: почти чёрный, насыщенные фиолетовый и синий |
| `kanagawa.sh` | Kanagawa Wave |
| `tokyonight.sh` · `gruvbox-material.sh` · `everforest.sh` · `oxocarbon.sh` | Tokyo Night, Gruvbox Material, Everforest, Oxocarbon |
| `rose-pine.sh` | **эталон**: все конфиги написаны в её цветах — удалять нельзя |
| `light/day.sh` | Dev Day — светлая палитра для светлого режима macOS |
| `apply.sh` | `theme <имя>`: перекрашивает конфиги роль к роли в `~/.config` и `~/.cache` |
| `set-wallpaper.py` | ставит обои сразу на все рабочие столы |

## Новая тема

Скопируй файл палитры, поменяй 19 цветов `T_*`, затем `theme <имя>`.

## Как пользоваться

```bash
theme              # выбор с превью цветов
theme kanagawa     # сразу
```

Одна палитра перекрашивает Ghostty, промпт, fzf, bat, delta, btop, eza, lazygit, starship, иконки приложений и папок
и ставит обои темы. Сгенерированные файлы лежат в `~/.config` и `~/.cache/dotfiles-theme`, в репозиторий не попадают.
Светлый режим macOS включает Dev Day сам — в Ghostty и Zed.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
