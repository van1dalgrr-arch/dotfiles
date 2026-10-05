#!/bin/bash
# ============================================================
#   Новый Mac → настроенный одной командой:
#     curl -fsSL https://raw.githubusercontent.com/van1dalgrr-arch/dotfiles/main/bootstrap.sh | bash
#   Шаги (уже сделанное пропускается, запускать повторно безопасно):
#     1. Command Line Tools (git, clang) — macOS покажет окно установки
#     2. Homebrew — спросит пароль администратора
#     3. ~/dotfiles — git clone (или git pull, если уже есть)
#     4. make install — программы из Brewfile, симлинки, oh-my-zsh, Go-утилиты, тема
#   Настройки macOS не трогает: после — ./macos.sh (план) и ./macos.sh --yes.
#   --dry-run — только показать, что будет сделано.
# ============================================================
set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/van1dalgrr-arch/dotfiles}"
DIR="${DOTFILES:-$HOME/dotfiles}"
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1

c=$'\e[38;2;168;85;247m' d=$'\e[38;2;110;110;120m' r=$'\e[0m'
step() { printf '\n%s▸ %s%s\n' "$c" "$1" "$r"; }
skip() { printf '  %s✓ %s%s\n' "$d" "$1" "$r"; }
run()  { if [ "$DRY" = 1 ]; then printf '  [план] %s\n' "$*"; else "$@"; fi; }

[ "$(uname -s)" = Darwin ] || { echo "только macOS"; exit 1; }
[ "$(uname -m)" = arm64 ] || echo "внимание: не Apple Silicon — пути /opt/homebrew рассчитаны на arm64"

step "Command Line Tools (git, clang)"
if xcode-select -p >/dev/null 2>&1; then skip "уже стоят"
else
    run xcode-select --install || true
    if [ "$DRY" = 0 ]; then
        echo "  нажми «Установить» в окне macOS; жду окончания…"
        until xcode-select -p >/dev/null 2>&1; do sleep 10; done
    fi
fi

step "Homebrew"
if [ -x /opt/homebrew/bin/brew ]; then skip "уже стоит"
else run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

step "dotfiles → ${DIR/#$HOME/~}"
if [ -d "$DIR/.git" ]; then
    skip "уже склонирован — обновляю"
    run git -C "$DIR" pull --ff-only
else run git clone "$REPO" "$DIR"; fi

step "make install: программы, симлинки, тема"
if [ "$DRY" = 1 ]; then printf '  [план] make -C %s install\n' "$DIR"
else make -C "$DIR" install; fi

printf '\n%s✓ готово%s\n' "$c" "$r"
cat <<EOF
  дальше:
    exec zsh                  новый shell с настройками
    ~/dotfiles/macos.sh       план настроек macOS → ./macos.sh --yes
    dot doctor                всё ли на месте
    ~/dotfiles/docs/recovery.ru.md — что вернуть руками (аккаунты, проекты)
EOF
