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

# Go-утилиты, которых нет в Homebrew (brew "air" — это другая программа)
command -v go >/dev/null && go install github.com/air-verse/air@latest && echo "installed: air"
link vscode/settings.json            "$HOME/Library/Application Support/Code/User/settings.json"
link vscode/keybindings.json         "$HOME/Library/Application Support/Code/User/keybindings.json"
link borders/bordersrc               "$HOME/.config/borders/bordersrc"
[ -d "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" ] || git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
command -v code >/dev/null && xargs -n1 code --install-extension < "$DOTFILES/vscode/extensions.txt"
link atuin/config.toml              "$HOME/.config/atuin/config.toml"
