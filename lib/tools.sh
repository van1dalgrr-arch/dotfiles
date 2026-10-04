# shellcheck shell=bash disable=SC2154  # цвета — из lib/ui.sh
# ============================================================
#   dot tools — Go-утилиты с закреплёнными версиями из go/tools.txt
#     dot tools            что стоит и совпадает ли с закреплённым
#     dot tools install    поставить недостающее / не той версии (остальное не трогает)
#     dot tools [install] devops   то же для необязательного go/tools.devops.txt (tflint)
# ============================================================

TOOLS_FILE="$DOTFILES/go/tools.txt"
gobin() { printf '%s' "${GOBIN:-${GOPATH:-$HOME/go}/bin}"; }

# строки «имя пакет версия»
tools_list() {
    local spec pkg
    grep -vE '^[[:space:]]*(#|$)' "${1:-$TOOLS_FILE}" | while IFS= read -r spec; do
        pkg=${spec%@*}
        printf '%s %s %s\n' "${pkg##*/}" "$pkg" "${spec##*@}"
    done
}

# версия модуля, из которого собран бинарник (пусто — не установлен или не Go).
# tool_version <имя> [strict] — strict: только $(gobin), без поиска в PATH (для install)
tool_version() {
    local bin
    bin="$(gobin)/$1"
    if [ ! -x "$bin" ]; then
        [ "${2:-}" = strict ] && return 0
        bin=$(command -v "$1") || return 0
    fi
    go version -m "$bin" 2>/dev/null | awk '$1 == "mod" { print $3; exit }'
}

tools_status() {
    has go || { failed "go не установлен" "→ brew install go"; return 1; }
    local name pkg want got hint="→ dot tools install"
    [ "${1:-$TOOLS_FILE}" = "$TOOLS_FILE" ] || hint="$hint devops"
    while read -r name pkg want; do
        got=$(tool_version "$name")
        if [ -z "$got" ]; then warning "$name не установлен" "$hint"
        elif [ "$got" = "$want" ]; then pass "$name $got"
        else warning "$name $got, закреплено $want" "$hint"; fi
    done < <(tools_list "${1:-}")
}

tools_install() {
    has go || { failed "go не установлен" "→ brew install go"; return 1; }
    local name pkg want got
    while read -r name pkg want; do
        got=$(tool_version "$name" strict)
        if [ "$got" = "$want" ]; then pass "$name $want"; continue; fi
        printf '  %s↓%s %s %s\n' "$c_head" "$r" "$name" "$want"
        if go install "$pkg@$want"; then pass "$name $want"
        else failed "$name: go install не прошёл"; fi
    done < <(tools_list "${1:-}")
}

tools() {
    local action=status file=$TOOLS_FILE
    case "${1:-}" in status|install) action=$1; shift ;; esac
    case "${1:-}" in
        "") ;;
        devops) file="$DOTFILES/go/tools.devops.txt" ;;
        *) echo "dot tools [status|install] [devops]" >&2; return 2 ;;
    esac
    section "Go-утилиты (${file#"$DOTFILES"/})"
    "tools_$action" "$file"
    summary
}
