#!/usr/bin/env bash
# Интеграционные тесты install.sh / uninstall.sh (make test): копия репозитория + временный HOME.
# Настоящий HOME и сам репозиторий не трогаются; сети нет (LINKS_ONLY=1 — только симлинки).
set -uo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
passed=0 failed=0

ok()   { passed=$((passed + 1)); echo "ok   $1"; }
fail() { failed=$((failed + 1)); echo "FAIL $1${2:+ — $2}"; }
# expect <имя> <условие…>
expect() { local name=$1; shift; if "$@"; then ok "$name"; else fail "$name"; fi; }

# свежая песочница: копия рабочего дерева без .git (pre-push ссылка ляжет в её .git/hooks) и пустой HOME
fresh() {
    rm -rf "${TMP:?}/repo" "${TMP:?}/home"
    mkdir -p "$TMP/repo/.git/hooks" "$TMP/home"
    (cd "$SRC" && tar --exclude ./.git -cf - .) | (cd "$TMP/repo" && tar -xf -)
    D="$TMP/repo" H="$TMP/home"
}
install()   { HOME=$H LINKS_ONLY=1 "$D/install.sh" > "$TMP/out" 2>&1; }
uninstall() { HOME=$H "$D/uninstall.sh" "$@" > "$TMP/out" 2>&1; }
# все пары «источник цель» из install.sh, цель уже с подставленным HOME
links() {
    grep -E '^link ' "$D/install.sh" | sed -E 's/^link +([^ ]+) +"?([^"]+)"?.*/\1 \2/' \
        | while read -r src dst; do printf '%s\t%s\n' "$src" "$(HOME=$H DOTFILES=$D eval echo "$dst")"; done
}
all_linked() {
    local src dst
    while IFS=$'\t' read -r src dst; do [ "$(readlink "$dst")" = "$D/$src" ] || { echo "     не так: $dst"; return 1; }; done < <(links)
}
none_linked() {
    local src dst
    while IFS=$'\t' read -r src dst; do [ -L "$dst" ] && [ "$(readlink "$dst")" = "$D/$src" ] && return 1; done < <(links)
    return 0
}
count_bak() { find "$H" -name '*.bak*' | wc -l | tr -d ' '; }

# 1. чистый HOME: все ссылки, ни одного бэкапа
fresh
install; expect "чистый HOME: install без ошибок" test $? = 0
expect "чистый HOME: все ссылки на месте" all_linked
expect "чистый HOME: бэкапов нет" test "$(count_bak)" = 0

# 2. повторный запуск ничего не портит и не плодит бэкапы
install; expect "повтор: без ошибок" test $? = 0
expect "повтор: ссылки те же" all_linked
expect "повтор: бэкапов всё так же нет" test "$(count_bak)" = 0

# 3. существующий .zshrc уходит в .bak, uninstall возвращает его байт в байт
fresh
echo 'export MINE=1' > "$H/.zshrc"
install
expect "свой .zshrc → .zshrc.bak" grep -qx 'export MINE=1' "$H/.zshrc.bak"
expect ".zshrc теперь ссылка" test "$(readlink "$H/.zshrc")" = "$D/zsh/.zshrc"
install
expect "повтор не затирает .zshrc.bak" grep -qx 'export MINE=1' "$H/.zshrc.bak"

# 4. uninstall без --yes — только план, ничего не меняет
uninstall
expect "uninstall без --yes: план" grep -q 'это план' "$TMP/out"
expect "uninstall без --yes: ссылки целы" all_linked
uninstall --yes; expect "uninstall --yes: без ошибок" test $? = 0
expect "uninstall: ссылок не осталось" none_linked
expect "uninstall: .zshrc вернулся" grep -qx 'export MINE=1' "$H/.zshrc"
expect "uninstall: .zshrc обычный файл" test ! -L "$H/.zshrc"
expect "uninstall: .bak убран" test ! -e "$H/.zshrc.bak"

# 5. файл снова занял место ссылки, а .bak ещё хранит первый оригинал → .bak.1, оригинал цел
fresh
echo first > "$H/.gitconfig"
install
rm "$H/.gitconfig"; echo second > "$H/.gitconfig"
install
expect "второй файл → .bak.1" grep -qx second "$H/.gitconfig.bak.1"
expect "первый оригинал в .bak цел" grep -qx first "$H/.gitconfig.bak"
uninstall --yes
expect "uninstall вернул первый оригинал" grep -qx first "$H/.gitconfig"

# 6. битая ссылка на месте конфига
fresh
mkdir -p "$H/.config/ghostty"
ln -s "$TMP/nowhere" "$H/.config/ghostty/config.ghostty"
install
expect "битая чужая ссылка: install без ошибок" test $? = 0
expect "битая чужая ссылка → .bak (ссылкой)" test -L "$H/.config/ghostty/config.ghostty.bak"
expect "битая чужая ссылка: конфиг на месте" all_linked

# 7. своя ссылка со старого места репозитория заменяется без бэкапа
fresh
ln -s "$TMP/old/dotfiles/zsh/.zshrc" "$H/.zshrc"
install
expect "старая ссылка dotfiles: заменена" test "$(readlink "$H/.zshrc")" = "$D/zsh/.zshrc"
expect "старая ссылка dotfiles: без бэкапа" test ! -e "$H/.zshrc.bak" -a ! -L "$H/.zshrc.bak"

# 8. чужая рабочая ссылка (например, на Dropbox) не удаляется, а уходит в .bak и возвращается
fresh
echo 'dropbox' > "$TMP/dropbox-zshrc"
ln -s "$TMP/dropbox-zshrc" "$H/.zshrc"
install
expect "чужая ссылка → .bak" test "$(readlink "$H/.zshrc.bak")" = "$TMP/dropbox-zshrc"
uninstall --yes
expect "uninstall вернул чужую ссылку" test "$(readlink "$H/.zshrc")" = "$TMP/dropbox-zshrc"

# 9. ссылки на папки (расширения Zed): повтор не создаёт ссылку внутри ссылки
fresh
install; install
ext="$H/Library/Application Support/Zed/extensions/installed/dev-night-theme"
expect "папка-расширение: ссылка" test "$(readlink "$ext")" = "$D/zed/dev-night-theme"
expect "папка-расширение: без вложенной ссылки" test ! -L "$D/zed/dev-night-theme/dev-night-theme"

# 10. путь с пробелами (Application Support) переживает весь цикл
uninstall --yes
expect "Application Support: убрано" test ! -L "$H/Library/Application Support/lazygit/config.yml"

echo
echo "$passed ok · $failed fail"
[ "$failed" -eq 0 ]
