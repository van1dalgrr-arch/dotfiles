# Если что-то не так

🇬🇧 [English version](troubleshooting.md) · [все документы](README.ru.md)

Начни с `dot doctor`: большую часть этого он находит сам и пишет, как починить. Ниже — по темам.

## Внешний вид

<details>
<summary>Иконка приложения вернулась к стандартной</summary>

macOS сбрасывает свои иконки при обновлении приложения. Вернуть: `theme vesper`
(или `swift ~/.cache/dotfiles-theme/icons.swift apply`). Приложениям, установленным от root (VS Code, Telegram), нужен `sudo`.
</details>

<details>
<summary>Терминал не поменял цвета после <code>theme</code></summary>

`theme`, `wall` и `backdrop` сами перезагружают Ghostty через AppleScript. Если не вышло (Ghostty не был запущен
или запрещена «Автоматизация») — нажми `cmd-shift-,`. Промпт и цвета команд меняются в **новых** окнах;
в уже открытом — `exec zsh`.
</details>

<details>
<summary>Хочу вернуть starship</summary>

Добавь `export PROMPT_ENGINE=starship` в `~/.zshenv` — конфиг лежит в `starship/`.
</details>

## Терминал

<details>
<summary>Выпадающий терминал не открывается</summary>

Ghostty должен работать в фоне (его запускает AeroSpace при входе; `cmd+q` закрывает только окна).
Клавишу ловит **AeroSpace** (`ctrl-backtick` в `aerospace.toml`) и запускает `ghostty/quick-terminal.applescript`,
поэтому самому Ghostty разрешение «Универсальный доступ» не нужно. В первый раз macOS спросит, можно ли AeroSpace
управлять Ghostty, — разреши (Настройки → Конфиденциальность и безопасность → Автоматизация, если нажал «нет»).
После правки `aerospace.toml`: `alt-shift-c`.
</details>

<details>
<summary>Команда ведёт себя не как обычно (<code>cat</code>, <code>ls</code>, <code>dc</code>, <code>wall</code>, <code>docker</code>)</summary>

Некоторые имена подменены специально: `cat`→bat, `ls`→eza, `rm/cp/mv` спрашивают перед перезаписью, `dc`→docker compose,
`orbstack`→berth, а `wall`/`pl`/`docker` — функции (`docker` запускает OrbStack, если тот выключен). Оригинал —
`command cat` или `\cat`.
</details>

<details>
<summary>Оболочка пишет «нет oh-my-zsh»</summary>

`.zshrc` работает и без него, но запусти `./install.sh` — он склонирует oh-my-zsh и fzf-tab на закреплённых ревизиях.
</details>

## Docker и <code>orbstack</code>

<details>
<summary><code>docker</code> думает несколько секунд или пишет «запускаю OrbStack…»</summary>

Это обёртка запускает OrbStack, потому что он был выключен: ~4 с, потом команда выполнится. Чтобы движок
работал заранее: `orbstack on`. Не поднялся за минуту — открой OrbStack руками: `open -a OrbStack`.
</details>

<details>
<summary><code>orbstack</code>: «command not found» или старое поведение после обновления</summary>

`orbstack` — псевдоним для `~/go/bin/berth`, который собирается из `berth/`. Пересобрать: `./install.sh` или `update`
(или `go build -C ~/dotfiles/berth -o ~/go/bin/berth .`). `dot doctor` предупредит, если бинарник старее исходников.
В окне, открытом до установки, — `exec zsh`, чтобы появился псевдоним.
</details>

<details>
<summary><code>orbstack</code>: в панели «движок выключен»</summary>

Нажми `e` — движок запустится. Или просто сделай что-нибудь с контейнером — он поднимется сам.
`E` выключает его и возвращает память.
</details>

<details>
<summary><code>orbstack</code>: по <code>f</code> показываются слои образа, а не Dockerfile</summary>

Dockerfile находится по меткам compose на контейнере. Если контейнер запущен через `docker run` или его сервис
в compose взят из готового образа (`image:` вместо `build:`), своего Dockerfile нет — поэтому показываются слои
образа: шаги, из которых он собран. Если compose-файл переехал, метки ещё указывают на старый путь —
пересоздай контейнеры: `docker compose up -d`.
</details>

<details>
<summary><code>orbstack watch</code> поменял мой compose-файл</summary>

Только после вопроса: он добавляет блок `develop.watch` сервисам с `build:`. Комментарии и порядок ключей сохраняются,
пустые строки между сервисами могут пропасть. Что именно изменилось — `git diff`; отменить — `git checkout -- compose.yaml`.
</details>

## Go

<details>
<summary>Go-утилита не той версии, или <code>dot tools</code> показывает <code>!</code></summary>

Версии закреплены в `go/tools.txt`. `dot tools install` поставит ровно их. Обновить — сначала поменяй версию в файле.
tflint лежит в `go/tools.devops.txt` (Homebrew убрал формулу): `dot tools install devops`.
</details>

<details>
<summary>Проекту нужна версия Go новее установленной</summary>

Делать ничего не надо: при стандартном `GOTOOLCHAIN=auto` Go сам скачает версию из `go.mod`
(`go 1.N` / `toolchain go1.N.x`) при первой сборке. Не скачал — проверь `go env GOTOOLCHAIN`: там не должно быть `local`.
</details>

## macOS и <code>dot doctor</code>

<details>
<summary><code>dot doctor</code> показывает ✗ / ! / ○ — что есть что</summary>

`✗` — сломано обязательное (основной `Brewfile`, симлинки, хуки), `dot doctor` выходит с кодом 1.
`!` — стоит посмотреть, но запуск не проваливает. `○` — необязательное (`Brewfile.devops`), просто не настроено.
`·` — справка. В конце каждой строки — как починить. `--deep` добавит версии, закреплённые ревизии, пакеты вне Brewfile
и `brew doctor`.
</details>

<details>
<summary><code>dot doctor</code>: «настроек macos.sh не на месте»</summary>

Обновление macOS (или клик в Настройках) вернул часть настроек. `./macos.sh` покажет какие — «сейчас → должно быть»;
`./macos.sh --yes` вернёт. Поменял специально — поправь или удали эту строку в `macos.sh`.
</details>

<details>
<summary><code>dot doctor</code>: «awake включён»</summary>

`awake on` не даёт маку уснуть даже с закрытой крышкой — удобно для Claude Code с телефона, плохо в рюкзаке.
Вернулся — `awake off` (спросит пароль).
</details>

<details>
<summary><code>brew bundle</code> пишет, что Zed / VS Code «already exists»</summary>

Brewfile их пропускает, если они уже лежат в `/Applications` (поставлены с сайта).
Отдать существующую копию под управление brew: `brew install --cask --adopt zed`.
</details>

<details>
<summary><code>macos.sh</code> ничего не поменял</summary>

Так и задумано: без `--yes` он только показывает план. Запусти `./macos.sh --yes`
(или `./macos.sh --yes finder dock` — только эти группы). Клавиатура, трекпад и тёмная тема — после перелогина.
Откатить одну настройку: `defaults delete <домен> <ключ>` (оба есть в `macos.sh`).
</details>

<details>
<summary><code>macos.sh safari</code>: «нет доступа» / «не проверить»</summary>

Safari хранит настройки в песочнице: терминал не может их читать и писать без
Настройки → Конфиденциальность и безопасность → **Полный доступ к диску** → Ghostty (потом перезапусти Ghostty).
Примени и забери доступ обратно: `tccutil reset SystemPolicyAllFiles com.mitchellh.ghostty`.
</details>
