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
link btop/themes/catppuccin_mocha.theme "$HOME/.config/btop/themes/catppuccin_mocha.theme"
link eza/theme.yml                   "$HOME/.config/eza/theme.yml"
link fastfetch/config.jsonc          "$HOME/.config/fastfetch/config.jsonc"
link tealdeer/config.toml            "$HOME/.config/tealdeer/config.toml"
link lazygit/config.yml              "$HOME/Library/Application Support/lazygit/config.yml"
