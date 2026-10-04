# shellcheck shell=bash
# ============================================================
#   dot secrets — SOPS + age (подробно: docs/secrets.md)
#     dot secrets        где ключ, какой публичный ключ, есть ли .sops.yaml в текущем проекте
#     dot secrets init   положить .sops.yaml в текущую папку (с твоим публичным ключом)
#   Ключи НЕ создаёт: приватный ключ делается один раз руками (age-keygen) и хранится вне git.
# ============================================================

AGE_KEY="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

# публичный ключ из файла с приватным (сам приватный не печатается)
age_recipient() { [ -f "$AGE_KEY" ] && age-keygen -y "$AGE_KEY" 2>/dev/null | head -1; }

secrets_status() {
    section "SOPS + age"
    has sops && pass "sops $(vers sops --version)" || failed "нет sops" "→ brew install sops"
    has age && pass "age $(vers age --version)" || failed "нет age" "→ brew install age"
    local pub
    if [ -f "$AGE_KEY" ]; then
        pub=$(age_recipient)
        if [ -n "$pub" ]; then pass "ключ: ${AGE_KEY/#$HOME/~}"; info "публичный: $pub"
        else failed "файл ключа не читается age-keygen" "→ ${AGE_KEY/#$HOME/~}"; fi
    else
        optional "ключа нет" "→ создать вручную, см. docs/secrets.md"
    fi
    if [ -f .sops.yaml ]; then pass ".sops.yaml в $(basename "$PWD")"
    else optional ".sops.yaml в $(basename "$PWD")" "→ dot secrets init"; fi
    summary
}

secrets_init() {
    if [ -e .sops.yaml ]; then echo ".sops.yaml уже есть — не трогаю" >&2; return 1; fi
    if [ ! -f "$AGE_KEY" ]; then
        printf 'нет ключа %s\nсоздай его сам (один раз, и сохрани копию в менеджере паролей):\n' "${AGE_KEY/#$HOME/~}" >&2
        has age-keygen || echo "  brew install age" >&2
        printf '  mkdir -p "%s" && age-keygen -o "%s" && chmod 600 "%s"\n' "$(dirname "$AGE_KEY")" "$AGE_KEY" "$AGE_KEY" >&2
        return 1
    fi
    has age-keygen || { echo "нет age → brew install age" >&2; return 1; }
    local pub
    pub=$(age_recipient)
    [ -n "$pub" ] || { echo "age-keygen не прочитал ${AGE_KEY/#$HOME/~}" >&2; return 1; }
    sed "s|AGE_PUBLIC_KEY|$pub|g" "$DOTFILES/templates/sops.yaml" > .sops.yaml
    echo "создан .sops.yaml для $pub"
    echo "дальше: sops edit secrets.enc.yaml   (откроется \$EDITOR, на диск попадёт только шифр)"
}

secrets() {
    case "${1:-status}" in
        status) secrets_status ;;
        init)   secrets_init ;;
        *)      echo "dot secrets [status|init]" >&2; return 2 ;;
    esac
}
