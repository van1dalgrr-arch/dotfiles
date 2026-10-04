#!/usr/bin/env bash
# Раскладывает конфиги из этого репозитория по системе через симлинки.
# Если на месте уже лежит обычный файл, он сохраняется как <файл>.bak.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

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
link ghostty/config.ghostty          "$HOME/.config/ghostty/config.ghostty"
link starship/starship.toml          "$HOME/.config/starship.toml"
link btop/btop.conf                  "$HOME/.config/btop/btop.conf"
link eza/theme.yml                   "$HOME/.config/eza/theme.yml"
link fastfetch/config.jsonc          "$HOME/.config/fastfetch/config.jsonc"
link tealdeer/config.toml            "$HOME/.config/tealdeer/config.toml"
link lazygit/config.yml              "$HOME/Library/Application Support/lazygit/config.yml"

# Go-утилиты, которых нет в Homebrew (brew "air" — это другая программа)
command -v go >/dev/null && go install github.com/air-verse/air@latest && echo "installed: air"
link vscode/settings.json            "$HOME/Library/Application Support/Code/User/settings.json"
link vscode/keybindings.json         "$HOME/Library/Application Support/Code/User/keybindings.json"
link borders/bordersrc               "$HOME/.config/borders/bordersrc"
[ -d "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" ] || git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
command -v code >/dev/null && xargs -n1 code --install-extension < "$DOTFILES/vscode/extensions.txt"
link atuin/config.toml              "$HOME/.config/atuin/config.toml"
link aerospace/aerospace.toml       "$HOME/.config/aerospace/aerospace.toml"
link btop/themes/rose-pine.theme   "$HOME/.config/btop/themes/rose-pine.theme"
link bat/themes/rose-pine.tmTheme   "$HOME/.config/bat/themes/rose-pine.tmTheme" && bat cache --build >/dev/null
link ghostty/shaders/cursor_trail.glsl "$HOME/.config/ghostty/shaders/cursor_trail.glsl"

link zed/settings.json               "$HOME/.config/zed/settings.json"
link zed/keymap.json                 "$HOME/.config/zed/keymap.json"
link zed/tasks.json                  "$HOME/.config/zed/tasks.json"
link zed/themes/dev-night.json       "$HOME/.config/zed/themes/dev-night.json"
link zed/snippets/go.json            "$HOME/.config/zed/snippets/go.json"
[ -e /opt/homebrew/bin/zed ] || ln -s /Applications/Zed.app/Contents/MacOS/cli /opt/homebrew/bin/zed   # `zed .` из терминала

# Тема терминала и обоев (по умолчанию rose-pine; сменить — `theme`)
bash "$DOTFILES/themes/apply.sh"
