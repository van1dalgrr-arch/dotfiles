# Обязательное: без этого dotfiles не работают как задумано. `brew bundle` / `dot install`.
# Необязательный DevOps-набор — в Brewfile.devops (brew bundle --file Brewfile.devops).
# Версии пакетов Homebrew не закрепляет (только последние); Go-утилиты закреплены в go/tools.txt.
# `dot doctor` сверяет установленное с обоими файлами, `dot doctor --deep` — ещё и лишнее.

# Терминал
cask "ghostty"
brew "starship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
cask "font-jetbrains-mono"
cask "font-jetbrains-mono-nerd-font"

# CLI
brew "eza"
brew "bat"
brew "fd"
brew "fzf"
brew "ripgrep"
brew "zoxide"
brew "btop"
brew "duf"
brew "fastfetch"
brew "tealdeer"
brew "httpie"

# Git
brew "git"
brew "gh"
brew "git-delta"
brew "lazygit"

# Go (версию проекта задаёт go.mod: нужный тулчейн Go скачает сам)
brew "go"
brew "goimports"
brew "golangci-lint"
brew "delve"
brew "gotestsum"

# Backend
brew "pgcli"
brew "golang-migrate"
brew "sqlc"
brew "grpcurl"
brew "buf"
brew "oha"
brew "fx"
brew "watchexec"
brew "scc"
brew "mkcert"

cask "yaak"              # API-клиент вместо Postman (Tauri, лёгкий)
cask "tableplus"         # GUI для Postgres/MySQL/Redis, нативный

# Docker / DevOps
brew "act"
brew "trivy"
brew "helm"
brew "kubectx"
brew "stern"
cask "orbstack"          # вместо Docker Desktop: память по требованию
brew "lazydocker"
brew "dive"
brew "hadolint"
brew "kubectl"
brew "k9s"
brew "jq"
brew "yq"
brew "direnv"
brew "git-lfs"

# Секреты: шифрование файлов в git (docs/secrets.md)
brew "sops"
brew "age"

# Python
brew "uv"

# Приложения
# Zed и VS Code часто ставят с сайта — тогда brew их не трогает (иначе bundle падает на «уже есть»)
cask "zed" unless File.exist?("/Applications/Zed.app")
cask "visual-studio-code" unless File.exist?("/Applications/Visual Studio Code.app")
cask "raycast"
brew "yazi"
brew "glow"
brew "chafa"            # картинки в терминале (превью в wall)
brew "atuin"
brew "shellcheck"
brew "shfmt"
brew "gitleaks"
tap "nikitabobko/tap"
cask "nikitabobko/tap/aerospace"
