<div align="center">

# dotfiles

Мой macOS для разработки на Go и Docker: тёмный, быстрый и бережный к памяти.<br>
MacBook Air M2 · 8 ГБ · zsh · Ghostty · AeroSpace · Zed

![macOS](https://img.shields.io/badge/macOS-Tahoe-101010?style=flat-square&logo=apple&logoColor=white)
![shell](https://img.shields.io/badge/shell-zsh-a855f7?style=flat-square)
![Go](https://img.shields.io/badge/Go-Gin-3b82f6?style=flat-square&logo=go&logoColor=white)
![license](https://img.shields.io/badge/license-MIT-101010?style=flat-square)

<img src="docs/wallpapers.jpg" alt="Живые обои из этого репозитория" width="100%">

<sub>19 живых обоев — все нарисованы кодом на Swift и меняются в течение дня</sub>

</div>

---

## Зачем это

У меня 8 ГБ оперативки, и при этом Docker, Go и пара редакторов. Поэтому всё здесь собрано
вокруг двух вещей: **чтобы ничего не тормозило** и **чтобы было приятно смотреть**.

Пара примеров того, к чему это привело:

- **Docker — через OrbStack**, а не Docker Desktop. Память берётся по мере надобности и отдаётся обратно, вместо постоянных 4 ГБ под виртуалку.
- **Промпт на чистом zsh**, без starship. Вне git-репозитория он не запускает ни одного процесса, внутри — один `git status`. Шелл стартует за ~0.15 с.
- **Zed вместо VS Code** для повседневного кода: обычно в разы меньше памяти.
- **Обои не висят в фоне** — это обычные динамические HEIC, кадры переключает сама macOS.

## Установка

Нужны [Homebrew](https://brew.sh) и [oh-my-zsh](https://ohmyz.sh).

```bash
git clone https://github.com/van1dalgrr-arch/dotfiles ~/dotfiles
cd ~/dotfiles
brew bundle          # все программы из Brewfile
./install.sh         # симлинки конфигов + тема + обои
```

`install.sh` ничего не удаляет: если на месте конфига уже лежит файл, он переименуется в `*.bak`.
Дальше конфиги правятся прямо в `~/dotfiles`, изменения сразу видны в `git status`.

`macos.sh` — отдельно и по желанию: быстрый повтор клавиш, без автозамен, скриншоты в `~/Pictures/Screenshots`.

## Что внутри

| | |
|---|---|
| **Терминал** | [Ghostty](https://ghostty.org) с выпадающим окном по `` ctrl+` `` и светящимся шлейфом курсора |
| **Окна** | [AeroSpace](https://github.com/nikitabobko/AeroSpace) — тайлинг как в i3, хоткеи работают и на русской раскладке |
| **Промпт** | свой, на zsh: путь от корня проекта, git, версия Go из `go.mod`, время команды |
| **Редактор** | [Zed](https://zed.dev) со своей темой Dev Night, иконками и задачами по `ctrl-r` |
| **Темы** | `theme vesper` / `kanagawa` / `rose-pine` — перекрашивают весь терминал, иконки и обои |
| **Обои** | `wall` — выбор из 19 живых обоев с превью прямо в терминале |
| **Git** | delta для диффов, lazygit, gitleaks перед каждым коммитом |
| **Docker** | OrbStack, lazydocker, `up` — поднять зависимости и запустить проект одной командой |

## Каждый день

Забыл команду — жми `?` (или `ctrl+/`): откроется шпаргалка со всеми хоткеями, функциями и алиасами.

| Команда | Что делает |
|---|---|
| `p` | выбрать проект из `~/dev` (fzf с превью и последними коммитами) |
| `up` | поднять из compose только зависимости (postgres, redis…) и запустить приложение с `.env` |
| `pl` | все проекты разом: стек, ветка, несохранённое, давность последнего коммита |
| `gonew myapi` | новый проект на Gin с air и git |
| `got` / `gotw` | тесты через gotestsum / перезапуск тестов при сохранении |
| `ram` | кто ест память — по приложениям, а не по процессам |
| `dsh` / `dlogs` | зайти в контейнер / смотреть его логи (выбор через fzf) |
| `gco` | переключить ветку через fzf |
| `killport 8080` | освободить порт |
| `theme` | сменить тему всего терминала |
| `wall` | сменить обои |

Если набрать несуществующую команду, промпт подскажет, есть ли она в brew — как `pkgfile` в Arch.

## Хоткеи

<details>
<summary><b>AeroSpace</b> — окна и рабочие столы</summary>

| Клавиши | Действие |
|---|---|
| `alt-enter` | новый терминал |
| `alt-e` | файловый менеджер (yazi) |
| `alt-q` | закрыть окно |
| `alt-h/j/k/l` | фокус влево / вниз / вверх / вправо |
| `alt-shift-h/j/k/l` | переместить окно |
| `alt-1…9` | перейти на стол |
| `alt-shift-1…9` | унести окно на стол |
| `alt-tab` | предыдущий стол |
| `alt-/` · `alt-,` | раскладка: плитки · аккордеон |
| `alt-shift-f` | на весь экран |
| `alt-shift-space` | плавающее ↔ плитка |
| `alt-r` | режим ресайза (`hjkl`, `esc`) |

</details>

<details>
<summary><b>Ghostty</b> — терминал</summary>

| Клавиши | Действие |
|---|---|
| `` ctrl+` `` | выпадающий терминал из любого приложения |
| `cmd-d` · `cmd-shift-d` | сплит вправо · вниз |
| `cmd-alt-стрелки` | переход между сплитами |
| `cmd-shift-enter` | развернуть сплит |
| `cmd-q` | закрыть окна (Ghostty остаётся в фоне, `` ctrl+` `` работает) |
| `cmd-shift-,` | перечитать конфиг после смены темы |

</details>

<details>
<summary><b>Zed</b> — редактор</summary>

| Клавиши | Действие |
|---|---|
| `ctrl-r` | меню задач: `up`, `air`, тесты, линтер, compose |
| `ctrl-shift-r` | повторить последнюю задачу |
| `alt-g` · `alt-d` | lazygit · lazydocker внутри Zed |
| `cmd-j` | терминал |
| `cmd-1` · `cmd-2` · `cmd-3` | файлы · структура файла · git |
| `cmd-shift-d` | все ошибки проекта |

Сниппеты Go: `iferr`, `iferrw`, `ginh`, `ginbind`, `ginr`, `ttest`, `jstruct`, `ctxt`.

</details>

## Темы

```bash
theme            # выбрать в fzf, справа — палитра
theme vesper     # сразу
```

| Тема | Настроение |
|---|---|
| `vesper` | почти чёрный, насыщенные фиолетовый и синий — основная |
| `kanagawa` | индиго и бумага, по мотивам Хокусая |
| `rose-pine` | мягкая, приглушённая |

Как это устроено: все конфиги в репозитории написаны цветами Rosé Pine, а тема — это просто таблица
«какой цвет на какой заменить» по 19 ролям (`themes/<имя>.sh`). `themes/apply.sh` за один проход
перекрашивает копии конфигов в `~/.config` и `~/.cache` — сам репозиторий при смене темы не меняется.
Под тему перекрашиваются Ghostty, промпт, подсветка, fzf, bat, delta, eza, lazygit, btop, рамка окон,
иконки в Dock и обои. VS Code тему не меняет.

## Обои

```bash
wall             # список с превью-картинкой, enter — поставить
wall eclipse     # сразу
```

Космос — `eclipse` `orbit` `rings` `aurora` `horizon`<br>
Технологии — `code` `circuit` `ridges` `minimal` `halftone`<br>
Остальное — `petals` `prism` `ocean` `glass` `neon` `rain` `bauhaus` `mesh` `kanagawa`

Каждые обои — короткий Swift-скрипт в `icons/`. Он рисует 12 кадров на сутки, и все параметры
(цвет, свет, положение деталей) считаются от часа непрерывно, поэтому macOS плавно перетекает
от кадра к кадру. Обои ставятся сразу на все рабочие столы.

Хочешь свои — создай `icons/wallpaper-<имя>.swift`:

```swift
runWallpaper { hour in
    let ctx = canvas()                     // почти чёрный холст
    let (a, b) = tint(hour)                // цвета суток
    radialGlow(ctx, CGPoint(x: W / 2, y: H / 2), 400 * S, a, 0.3)
    return bloom(ctx.makeImage()!)
}
```

Палитра, звёзды, свечение и сборка HEIC — в `icons/wallpaper-kit.swift`. После этого `wall <имя>`.

## Защита от утечек

Перед **каждым** коммитом в любом репозитории [gitleaks](https://github.com/gitleaks/gitleaks)
проверяет, что коммитится. Нашёл пароль, токен или ключ — коммит не пройдёт и покажет файл и строку.
Глобальный `.gitignore` не пускает в репозитории `.env`, ключи и `.DS_Store`.

Хуки самих проектов продолжают работать — `git/hooks/_chain` вызывает их после проверки.
Ложное срабатывание: комментарий `gitleaks:allow` в строке или `git commit --no-verify`.

## Структура

```
dotfiles/
├── zsh/            .zshrc, промпт, тема, шпаргалка, ram
├── themes/         палитры тем и apply.sh, который их применяет
├── icons/          обои, иконки приложений, иконка папки ~/dev
├── ghostty/        конфиг и шейдер шлейфа курсора
├── aerospace/      тайлинг окон
├── zed/            настройки, тема Dev Night, иконки, задачи, сниппеты
├── git/            .gitconfig, delta, хуки с gitleaks, глобальный ignore
├── fastfetch/      приветствие с логотипом Arch в новом окне
├── vscode/         настройки и список расширений
├── borders/ btop/ bat/ eza/ lazygit/ atuin/ tealdeer/ starship/
├── Brewfile        всё, что ставится через brew
├── install.sh      симлинки
└── macos.sh        системные настройки (по желанию)
```

## Если что-то пошло не так

<details>
<summary>Иконка приложения стала обычной</summary>

macOS сбрасывает свою иконку при обновлении приложения. Верни: `theme vesper`
(или `swift ~/.cache/dotfiles-theme/icons.swift apply`). Приложениям, установленным от root (VS Code, Telegram), нужен `sudo`.
</details>

<details>
<summary>Терминал не поменял цвета после <code>theme</code></summary>

Ghostty читает конфиг при запуске — нажми `cmd-shift-,` и открой новое окно.
</details>

<details>
<summary>Выпадающий терминал не открывается</summary>

Ghostty должен работать в фоне (AeroSpace запускает его при входе) и иметь доступ
в «Универсальном доступе» — без этого глобальные хоткеи не работают.
</details>

<details>
<summary>Хочу обратно starship</summary>

`export PROMPT_ENGINE=starship` в `~/.zshenv` — конфиг лежит в `starship/`.
</details>

## Спасибо

[Vesper](https://github.com/raunofreiberg/vesper) ·
[Rosé Pine](https://rosepinetheme.com) ·
[Kanagawa](https://github.com/rebelot/kanagawa.nvim) ·
[Nerd Fonts](https://www.nerdfonts.com) ·
[Ghostty](https://ghostty.org) ·
[AeroSpace](https://github.com/nikitabobko/AeroSpace) ·
[OrbStack](https://orbstack.dev)

## Лицензия

[MIT](LICENSE) — бери что нравится, копируй, меняй под себя.
