# Читается всеми zsh, даже неинтерактивными (ssh mac 'команда', mosh-server).
# Только PATH к Homebrew — без него по SSH не найдутся mosh-server, go, tmux.
# Своё (DOTFILES_APPEARANCE, NO_REMINDERS…) — в ~/.zshenv.local, он не в git.
[[ -d /opt/homebrew/bin ]] && path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
