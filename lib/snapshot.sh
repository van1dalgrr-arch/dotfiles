# shellcheck shell=bash disable=SC2154  # цвета — из lib/ui.sh
# dot snapshot [save|diff|list] — снимок системы до/после обновления macOS: что установлено, какие настройки,
# что стартует само. Только читает. Снимки: ~/.local/state/dotfiles/snapshots/<дата-время>/

SNAP_DIR="$HOME/.local/state/dotfiles/snapshots"

# версия .app из Info.plist (без Spotlight: mdls после обновления может ещё индексировать)
app_version() { /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$1/Contents/Info.plist" 2>/dev/null || echo '?'; }

snapshot_save() {
    local d f
    d="$SNAP_DIR/$(date +%Y-%m-%d_%H%M)"
    mkdir -p "$d"
    {
        sw_vers
        uname -m
        xcode-select -p 2>/dev/null && pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null | awk '/^version/ { print "CLT " $2 }'
    } > "$d/system.txt"
    if has brew; then
        brew list --formula --versions > "$d/brew-formulae.txt" 2>/dev/null
        brew list --cask --versions > "$d/brew-casks.txt" 2>/dev/null
    fi
    for f in /Applications/*.app; do
        printf '%s %s\n' "$(basename "$f" .app)" "$(app_version "$f")"
    done > "$d/apps.txt"
    # настройки macos.sh: «✓ описание» — совпадает, «~ описание  было → станет» — разъехалось
    NO_COLOR=1 "$DOTFILES/macos.sh" -v keyboard trackpad finder saving screenshots dock appearance login security 2>/dev/null \
        | sed -E 's/\x1b\[[0-9;]*m//g' > "$d/macos-settings.txt"
    osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | tr ',' '\n' | sed 's/^ //' > "$d/login-items.txt"
    launchctl list | awk 'NR > 1 && $3 !~ /^(com\.apple\.|application\.)/ { print $3 }' | sort > "$d/agents.txt"
    {
        has go && go version
        has docker && docker --version 2>/dev/null
        has aerospace && aerospace --version 2>/dev/null | tail -1
        /Applications/Ghostty.app/Contents/MacOS/ghostty +version 2>/dev/null | head -1
    } > "$d/tools.txt"
    # разрешения, которые macOS любит сбрасывать: AeroSpace без Универсального доступа не видит окна
    {
        if has aerospace && aerospace list-windows --all >/dev/null 2>&1; then echo "AeroSpace: окна видит"
        else echo "AeroSpace: окон не видит (Универсальный доступ?)"; fi
    } > "$d/permissions.txt"
    pass "снимок сохранён: ~${d#"$HOME"}"
    info "$(wc -l < "$d/apps.txt" | tr -d ' ') приложений · $(cat "$d"/brew-*.txt 2>/dev/null | wc -l | tr -d ' ') пакетов brew · $(grep -c '^  ~' "$d/macos-settings.txt") настроек macos.sh разъехалось"
}

snapshot_list() { ls -1 "$SNAP_DIR" 2>/dev/null; }

# diff [старый [новый]] — по умолчанию два последних снимка
snapshot_diff() {
    local -a snaps
    local a b f changes
    while IFS= read -r f; do snaps+=("$f"); done < <(snapshot_list)
    a=${1:-${snaps[${#snaps[@]}-2]:-}}; b=${2:-${snaps[${#snaps[@]}-1]:-}}
    if [ -z "$a" ] || [ -z "$b" ] || [ "$a" = "$b" ]; then
        echo "нужно два снимка: dot snapshot (до) … dot snapshot (после) → dot snapshot diff" >&2; return 2
    fi
    section "$a → $b"
    for f in system tools apps brew-formulae brew-casks macos-settings login-items agents permissions; do
        [ -f "$SNAP_DIR/$a/$f.txt" ] && [ -f "$SNAP_DIR/$b/$f.txt" ] || continue
        changes=$(diff "$SNAP_DIR/$a/$f.txt" "$SNAP_DIR/$b/$f.txt" | grep -E '^[<>]' | sed 's/^</  − /; s/^>/  + /')
        if [ -z "$changes" ]; then pass "$f: без изменений"
        else
            case $f in
                macos-settings|login-items|permissions) warning "$f: изменилось" ;;
                *) info "$f:" ;;
            esac
            printf '%s\n' "$changes" | head -40
        fi
    done
    echo
    info "настройки сбросились → ./macos.sh --yes · разрешения → Настройки → Конфиденциальность → Универсальный доступ"
}

snapshot() {
    case "${1:-save}" in
        save) snapshot_save ;;
        diff) shift; snapshot_diff "$@" ;;
        list) snapshot_list ;;
        *) echo "dot snapshot [save|diff [старый новый]|list]" >&2; return 2 ;;
    esac
}
