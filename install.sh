#!/usr/bin/env bash
# Симлинки на конфиги (обычный файл на месте → <файл>.bak), закреплённые клоны, Go-утилиты, тема.
# Повторный запуск безопасен. Программы ставит `brew bundle`.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# закреплённые ревизии git clone; уже склонированное не трогается (oh-my-zsh обновляется сам)
OMZ_REV=74965c96098134b192f00084f966b4b02438a739
FZF_TAB_REV=24105b15714bfec37989ed5c5b6e60f572253019

[ "$(uname -s)" = Darwin ] || { echo "только macOS"; exit 1; }
[ "$(uname -m)" = arm64 ] || echo "внимание: не arm64 (Rosetta?) — пути /opt/homebrew рассчитаны на Apple Silicon"

clone_pinned() {
    [ -d "$2" ] && return 0
    git clone -q --filter=blob:none "$1" "$2"
    git -C "$2" -c advice.detachedHead=false checkout -q "$3"
    echo "cloned: $2 @ ${3:0:7}"
}

link() {
    local src="$DOTFILES/$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        mv "$dst" "$dst.bak"
        echo "backup: $dst.bak"
    fi

    ln -s "$src" "$dst"
    echo "linked: $dst"
}

link zsh/.zshrc                      "$HOME/.zshrc"
link git/.gitconfig                  "$HOME/.gitconfig"
link git/repo-hooks/pre-push         "$DOTFILES/.git/hooks/pre-push"   # проверки перед push в сам dotfiles
link ghostty/config.ghostty          "$HOME/.config/ghostty/config.ghostty"
link ghostty/shaders/cursor_smooth.glsl "$HOME/.config/ghostty/shaders/cursor_smooth.glsl"
link starship/starship.toml          "$HOME/.config/starship.toml"
link btop/btop.conf                  "$HOME/.config/btop/btop.conf"
link eza/theme.yml                   "$HOME/.config/eza/theme.yml"
link fastfetch/config.jsonc          "$HOME/.config/fastfetch/config.jsonc"
link tealdeer/config.toml            "$HOME/.config/tealdeer/config.toml"
link lazygit/config.yml              "$HOME/Library/Application Support/lazygit/config.yml"

link vscode/settings.json            "$HOME/Library/Application Support/Code/User/settings.json"
link vscode/keybindings.json         "$HOME/Library/Application Support/Code/User/keybindings.json"
link atuin/config.toml              "$HOME/.config/atuin/config.toml"
link aerospace/aerospace.toml       "$HOME/.config/aerospace/aerospace.toml"
link btop/themes/rose-pine.theme   "$HOME/.config/btop/themes/rose-pine.theme"
link bat/themes/rose-pine.tmTheme   "$HOME/.config/bat/themes/rose-pine.tmTheme"

link zed/settings.json               "$HOME/.config/zed/settings.json"
link zed/keymap.json                 "$HOME/.config/zed/keymap.json"
link zed/tasks.json                  "$HOME/.config/zed/tasks.json"
link pgcli/config                    "$HOME/.config/pgcli/config"
link zed/debug.json                  "$HOME/.config/zed/debug.json"
link zed/snippets/go.json            "$HOME/.config/zed/snippets/go.json"
# свои темы Dev Night / Dev Day и иконки — два локальных расширения Zed (как в каталоге Zed): ссылки на папки
link zed/dev-night-theme             "$HOME/Library/Application Support/Zed/extensions/installed/dev-night-theme"
link zed/dev-night-icons             "$HOME/Library/Application Support/Zed/extensions/installed/dev-night-icons"

# oh-my-zsh без его установщика (тот переписывает ~/.zshrc) + плагин fzf-tab
clone_pinned https://github.com/ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh" "$OMZ_REV"
clone_pinned https://github.com/Aloxaf/fzf-tab "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" "$FZF_TAB_REV"

# Go-утилиты с закреплёнными версиями (go/tools.txt; brew "air" — это другая программа)
if command -v go >/dev/null; then "$DOTFILES/bin/dot" tools install || echo "внимание: не все Go-утилиты встали — dot tools"
else echo "пропуск Go-утилит: нет go (brew bundle)"; fi

command -v bat >/dev/null && bat cache --build >/dev/null
command -v code >/dev/null && xargs -n1 code --install-extension < "$DOTFILES/vscode/extensions.txt"
if [ -d /Applications/Zed.app ] && [ ! -e /opt/homebrew/bin/zed ] && [ -w /opt/homebrew/bin ]; then
    ln -s /Applications/Zed.app/Contents/MacOS/cli /opt/homebrew/bin/zed
fi

# Тема терминала и обоев (по умолчанию rose-pine; сменить — `theme`)
bash "$DOTFILES/themes/apply.sh"
