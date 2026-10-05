#!/usr/bin/env bash
# Смоук-тесты dot (make test): коды выхода и ключевой вывод. Без сети и установки; на Linux — только переносимое.
set -uo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
DOT="$DOTFILES/bin/dot"
export NO_COLOR=1 DOTFILES
# без глобального git-конфига: его ignore/хуки влияли бы на результат
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
passed=0 failed=0

# check <имя> <ожидаемый код> <ожидаемая строка или ""> -- команда…
check() {
    local name=$1 want=$2 needle=$3 out code; shift 4
    out=$("$@" 2>&1); code=$?
    if [ "$code" = "$want" ] && { [ -z "$needle" ] || grep -qF -- "$needle" <<<"$out"; }; then
        passed=$((passed + 1)); echo "ok   $name"
    else
        failed=$((failed + 1)); echo "FAIL $name (код $code, ждали $want${needle:+, строку «${needle}»})"
        sed 's/^/     /' <<<"$out" | grep -E "✗|!" | head -10
    fi
}

check "help"                 0 "dot doctor"        -- "$DOT" help
check "неизвестная команда"  2 ""                  -- "$DOT" nope
check "doctor: плохой флаг"  2 "--deep"            -- "$DOT" doctor --bogus
check "tools: плохой арг."   2 ""                  -- "$DOT" tools bogus
check "project без doctor"   2 ""                  -- "$DOT" project
check "project: нет папки"   2 "нет папки"         -- "$DOT" project doctor "$TMP/none"

# Go-проект: всё на месте, .env игнорируется
p="$TMP/api"
mkdir -p "$p/cmd/api" "$p/migrations"
printf 'module example.com/api\n\ngo 1.21\n' > "$p/go.mod"
printf 'package main\nfunc main() {}\n' > "$p/cmd/api/main.go"
printf 'package main\nimport "testing"\nfunc TestX(t *testing.T) {}\n' > "$p/cmd/api/main_test.go"
touch "$p/migrations/0001_init.up.sql" "$p/Makefile" "$p/.env.example" "$p/.env"
printf '.env\n' > "$p/.gitignore"
git -C "$p" init -q && git -C "$p" add -A && git -C "$p" -c user.email=t@t -c user.name=t commit -qm init --no-verify
check "Go-проект: ок"        0 "go.mod: example.com/api" -- "$DOT" project doctor "$p"
check "Go-проект: тесты"     0 "1 файлов с тестами"      -- "$DOT" project doctor "$p"
check "Go-проект: миграции"  0 "миграции: migrations"    -- "$DOT" project doctor "$p"
check "из подпапки"          0 "go.mod: example.com/api" -- "$DOT" project doctor "$p/cmd/api"

# .env не в .gitignore → ошибка и exit 1
: > "$p/.gitignore"
check ".env попадёт в git"   1 ".env не в .gitignore"    -- "$DOT" project doctor "$p"

# не Go-проект: только общие проверки, exit 0
mkdir -p "$TMP/notes"
check "не Go-проект"         0 "не Go-проект"            -- "$DOT" project doctor "$TMP/notes"

# go/tools.txt разбирается: имя, пакет, версия
check "tools.txt разбор"     0 "gopls golang.org/x/tools/gopls v" -- bash -c ". '$DOTFILES/lib/ui.sh'; . '$DOTFILES/lib/tools.sh'; tools_list"

if [ "$(uname -s)" = Darwin ]; then
    check "macos.sh: план"       0 "finder"    -- "$DOTFILES/macos.sh" finder
    check "macos.sh: группа"     2 "неизвестно" -- "$DOTFILES/macos.sh" bogus
    check "bootstrap: план"      0 "make install" -- env DOTFILES="$TMP/fresh" "$DOTFILES/bootstrap.sh" --dry-run
fi

echo
echo "$passed ok · $failed fail"
[ "$failed" -eq 0 ]
