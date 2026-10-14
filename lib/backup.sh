# shellcheck shell=bash disable=SC2154  # цвета — из lib/ui.sh
# dot backup [status] — бэкап без Time Machine: то, что пропадёт при сбросе Mac и чего нет на GitHub.
# Кладёт в приватный репозиторий dotfiles-backup (создаётся при первом запуске, клон — в BACKUP_DIR):
#   repos/<проект>/unpushed.bundle   коммиты, которых нет ни на одном remote (git bundle, все ветки)
#   repos/<проект>/uncommitted.patch незакоммиченные правки в отслеживаемых файлах (+ список новых файлов, без содержимого)
#   system/                          снимок dot snapshot: brew, приложения, настройки macOS, агенты, версии
#   state/                           состояние dotfiles вне git: тема, обои, fx, backdrop, режим work, ~/.ssh/config
# Удалённые репозитории проектов не трогает: ничего не пушит в чужой origin. Перед коммитом — глобальный хук gitleaks.

BACKUP_REPO=${BACKUP_REPO:-dotfiles-backup}
BACKUP_DIR=${BACKUP_DIR:-$HOME/.local/share/dotfiles/backup}
BACKUP_STAMP=${BACKUP_STAMP:-$HOME/.cache/dotfiles/last-backup}
BACKUP_DEV=${BACKUP_DEV:-${DEV:-$HOME/dev}}

# дней с последнего бэкапа; пусто — не было ни разу
backup_age() {
    [ -f "$BACKUP_STAMP" ] || return 1
    echo $(( ($(date +%s) - $(date -r "$BACKUP_STAMP" +%s)) / 86400 ))
}

# репозитории в ~/dev и на уровень глубже, как pl: без sandbox и *.worktrees
backup_repos() {
    local d
    for d in "$BACKUP_DEV"/* "$BACKUP_DEV"/*/*; do
        [ -e "$d/.git" ] || continue
        case ${d#"$BACKUP_DEV"/} in sandbox* | *.worktrees*) continue ;; esac
        echo "$d"
    done
}

backup_clone() {
    [ -d "$BACKUP_DIR/.git" ] && return 0
    has gh || { failed "нет gh" "→ brew install gh && gh auth login"; return 1; }
    local owner; owner=$(gh api user --jq .login 2>/dev/null) || { failed "gh не залогинен" "→ gh auth login"; return 1; }
    if ! gh repo view "$owner/$BACKUP_REPO" >/dev/null 2>&1; then
        gh repo create "$owner/$BACKUP_REPO" --private --description "dot backup: незапушенное, снимок системы, состояние" >/dev/null \
            || { failed "не удалось создать $owner/$BACKUP_REPO" "→ gh repo create $BACKUP_REPO --private"; return 1; }
        pass "создан приватный репозиторий $owner/$BACKUP_REPO"
    fi
    mkdir -p "$(dirname "$BACKUP_DIR")"
    gh repo clone "$owner/$BACKUP_REPO" "$BACKUP_DIR" -- -q 2>/dev/null \
        || { failed "не удалось склонировать $BACKUP_REPO" "→ gh repo clone $BACKUP_REPO $BACKUP_DIR"; return 1; }
}

# один проект → repos/<имя>/; печатает «N коммитов, M файлов» или ничего
backup_repo() {
    local src=$1 name out ahead dirty new
    name=${src#"$BACKUP_DEV"/}; out="$BACKUP_DIR/repos/$name"
    rm -rf "$out"
    ahead=$(git -C "$src" rev-list --count --branches --not --remotes 2>/dev/null) || return 0
    dirty=$(git -C "$src" diff HEAD --name-only 2>/dev/null | wc -l | tr -d ' ')
    new=$(git -C "$src" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    [ "$ahead" -eq 0 ] && [ "$dirty" -eq 0 ] && [ "$new" -eq 0 ] && return 0
    mkdir -p "$out"
    if [ "$ahead" -gt 0 ]; then
        # все ветки, но только коммиты, которых нет на remote: маленький файл, восстанавливается git fetch
        git -C "$src" bundle create "$out/unpushed.bundle" --branches --not --remotes >/dev/null 2>&1
        git -C "$src" log --branches --not --remotes --format='%h %ad %s' --date=short > "$out/unpushed.txt"
    fi
    [ "$dirty" -gt 0 ] && git -C "$src" diff HEAD --binary > "$out/uncommitted.patch"
    # новые файлы — только имена: в них бывают .env и ключи, а им в бэкапе на GitHub не место
    [ "$new" -gt 0 ] && git -C "$src" ls-files --others --exclude-standard > "$out/untracked.txt"
    {
        echo "src=$src"
        echo "branch=$(git -C "$src" branch --show-current)"
        echo "head=$(git -C "$src" rev-parse HEAD 2>/dev/null)"
        echo "remote=$(git -C "$src" remote get-url origin 2>/dev/null)"
    } > "$out/info.txt"
    echo "$name ⇡$ahead !$dirty ?$new"
}

backup_state() {
    local s="$BACKUP_DIR/state" f
    rm -rf "$s"; mkdir -p "$s"
    for f in theme wall backdrop fx work wall-path; do
        [ -f "$HOME/.config/dotfiles/$f" ] && cp "$HOME/.config/dotfiles/$f" "$s/$f"
    done
    [ -f "$HOME/.ssh/config" ] && cp "$HOME/.ssh/config" "$s/ssh-config"          # только хосты, без ключей
    ls -1 "$HOME/Library/LaunchAgents" > "$s/launch-agents.txt" 2>/dev/null
    crontab -l > "$s/crontab.txt" 2>/dev/null || rm -f "$s/crontab.txt"
    git -C "$DOTFILES" log -1 --format='%h %s' > "$s/dotfiles-head.txt"
}

backup_run() {
    section "Бэкап → $BACKUP_REPO"
    backup_clone || return 1
    git -C "$BACKUP_DIR" pull -q --rebase 2>/dev/null

    section "Незапушенное в ~/dev"
    local d line n=0
    rm -rf "$BACKUP_DIR/repos"
    while IFS= read -r d; do
        line=$(backup_repo "$d")
        [ -n "$line" ] && { info "$line"; n=$((n + 1)); }
    done < <(backup_repos)
    [ "$n" -eq 0 ] && pass "всё запушено, сохранять нечего" || pass "сохранено проектов: $n"

    section "Система и состояние"
    if [ -z "${BACKUP_NO_SYSTEM:-}" ]; then          # тесты: без снимка (macos.sh, osascript, brew)
        local tmp; tmp=$(mktemp -d)
        SNAP_DIR=$tmp snapshot_save >/dev/null
        rm -rf "$BACKUP_DIR/system"; mv "$tmp"/* "$BACKUP_DIR/system"; rmdir "$tmp"
        pass "снимок системы: brew, приложения, настройки macOS, агенты"
    fi
    backup_state
    pass "тема, обои, эффекты, режим work, ~/.ssh/config"

    section "Отправка"
    git -C "$BACKUP_DIR" add -A
    if git -C "$BACKUP_DIR" diff --cached --quiet; then
        pass "с прошлого бэкапа ничего не поменялось"
    elif ! git -C "$BACKUP_DIR" commit -qm "backup $(date '+%Y-%m-%d %H:%M')"; then
        # чаще всего — gitleaks нашёл секрет: в бэкап он не уйдёт
        failed "коммит не прошёл (gitleaks?)" "→ git -C $BACKUP_DIR status"; return 1
    fi
    if git -C "$BACKUP_DIR" push -q 2>/dev/null; then
        mkdir -p "$(dirname "$BACKUP_STAMP")"; touch "$BACKUP_STAMP"
        pass "отправлено на GitHub (приватный $BACKUP_REPO)"
    else
        failed "push не прошёл" "→ сеть / VPN? потом снова dot backup"; return 1
    fi
}

backup_status() {
    local age
    if age=$(backup_age); then
        [ "$age" -le 7 ] && pass "последний бэкап: $age дн. назад" || warning "последний бэкап: $age дн. назад" "→ dot backup"
    else
        warning "бэкапа ещё не было" "→ dot backup"
    fi
    [ -d "$BACKUP_DIR/.git" ] && info "клон: ~${BACKUP_DIR#"$HOME"}"
}

backup() {
    case "${1:-}" in
        "") backup_run ;;
        status) backup_status ;;
        *) echo "dot backup [status]" >&2; return 2 ;;
    esac
    local code=$?
    [ "$code" = 2 ] && return 2
    summary
}
