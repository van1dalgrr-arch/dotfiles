# shellcheck shell=bash
# Вывод dot: ✓ ок · ! предупреждение · ✗ ошибка (exit 1) · ○ необязательное · справка. Только bash 3.2

ok=0 warn=0 fail=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    c_ok=$'\e[38;2;59;130;246m' c_warn=$'\e[38;2;234;179;8m' c_fail=$'\e[38;2;239;68;68m'
    c_dim=$'\e[38;2;110;110;120m' c_head=$'\e[38;2;168;85;247m' r=$'\e[0m'
else
    c_ok='' c_warn='' c_fail='' c_dim='' c_head='' r=''
fi

pass()     { ok=$((ok + 1));     printf '  %s✓%s %s\n' "$c_ok" "$r" "$1"; }
warning()  { warn=$((warn + 1)); printf '  %s!%s %s %s%s%s\n' "$c_warn" "$r" "$1" "$c_dim" "${2:-}" "$r"; }
failed()   { fail=$((fail + 1)); printf '  %s✗%s %s %s%s%s\n' "$c_fail" "$r" "$1" "$c_dim" "${2:-}" "$r"; }
optional() { printf '  %s○ %s %s%s\n' "$c_dim" "$1" "${2:-}" "$r"; }
info()     { printf '  %s·%s %s\n' "$c_dim" "$r" "$1"; }
section()  { printf '\n%s%s%s\n' "$c_head" "$1" "$r"; }

summary() {
    printf '\n%s%d ок%s · %s%d предупреждений%s · %s%d ошибок%s\n' \
        "$c_ok" "$ok" "$r" "$c_warn" "$warn" "$r" "$c_fail" "$fail" "$r"
    [ "$fail" -eq 0 ]
}

has() { command -v "$1" >/dev/null 2>&1; }

# первая похожая на версию строка из вывода команды: vers go version → 1.27.1
vers() { "$@" 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1; }

# ver_ge 1.27.1 1.25 → истина, если первая версия не меньше второй
ver_ge() {
    awk -v a="$1" -v b="$2" 'BEGIN {
        n = split(a, x, "."); m = split(b, y, "."); if (m > n) n = m
        for (i = 1; i <= n; i++) { if (x[i] + 0 > y[i] + 0) exit 0; if (x[i] + 0 < y[i] + 0) exit 1 }
        exit 0 }'
}
