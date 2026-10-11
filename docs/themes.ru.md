# Темы

🇬🇧 [English version](themes.md) · [все документы](README.ru.md)

<img src="themes.jpg" alt="vesper, kanagawa, rose-pine и светлая Dev Day" width="100%">

<sub>vesper (по умолчанию), kanagawa, rose-pine и Dev Day, которая включается со светлым оформлением macOS. Нарисовано по настоящей палитре и цветам промпта каждой темы.</sub>


```bash
theme            # выбор в fzf, справа — превью палитры
theme vesper     # сразу
```

| Тема | Настроение |
|---|---|
| `vesper` | почти чёрный с насыщенными фиолетовым и синим — основная |
| `kanagawa` | индиго и бумага, по мотивам Хокусая |
| `rose-pine` | мягкая и приглушённая |

Как это работает: все конфиги в репозитории написаны цветами Rosé Pine, а тема — это просто таблица
«какой цвет каким становится» для 19 ролей (`themes/<имя>.sh`). `themes/apply.sh` за один проход перекрашивает
копии конфигов в `~/.config` и `~/.cache` — сам репозиторий при смене темы не меняется.
Перекрашиваются Ghostty, промпт, подсветка команд, fzf, bat, delta, eza, lazygit, btop,
иконки Dock и папок, эффекты терминала (`fx`) и обои; фон терминала пересобирается под них.
Ghostty перечитывает конфиг сам. VS Code остаётся со своей темой; у Zed и GoLand — Dev Night / Dev Day.

## Своя тема

Скопируй палитру, поменяй 19 цветов, примени:

```bash
cp themes/vesper.sh themes/mine.sh   # поправь hex в T_*
theme mine
```

`THEME_WALLPAPER` — какие обои идут с темой; `THEME_GHOSTTY_EXTRA` переопределяет ANSI-палитру Ghostty,
если в базовой есть цвета, которые не нравятся.

## Светлый режим (Dev Day)

Когда macOS переключается на светлое оформление, за ней идёт всё. **Ghostty** меняется сразу:
`apply.sh` пишет две темы Ghostty, `dotfiles-dark` (твоя тема) и `dotfiles-light`, и ставит
`theme = light:dotfiles-light,dark:dotfiles-dark`. **Zed** тоже переключается на Dev Day.

**zsh** (промпт, подсветка команд, fzf, eza, bat, lazygit, delta) берёт светлую палитру
`themes/light/day.sh`, когда оболочка **стартует**. Уже открытые окна остаются в старых цветах до `exec zsh`.

Закрепить один вид независимо от macOS: `export DOTFILES_APPEARANCE=dark` (или `light`) в `~/.zshenv`.
Светлая палитра общая для всех тем: поменяй цвета в `themes/light/day.sh`, потом `theme`.
