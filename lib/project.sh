# shellcheck shell=bash disable=SC2154  # цвета — из lib/ui.sh
# dot project doctor [папка] — только читает. Нет необязательного → ○; ✗ — только .env в git или Go не соберёт

# ближайшая вверх папка с go.mod, но не выше корня git-репозитория
find_go_root() {
    local dir=$1 top
    top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo /)
    while :; do
        [ -f "$dir/go.mod" ] && { printf '%s' "$dir"; return 0; }
        [ "$dir" = "$top" ] || [ "$dir" = / ] && return 1
        dir=$(dirname "$dir")
    done
}

# первый существующий файл из списка
first_of() { local f; for f in "$@"; do [ -e "$f" ] && { printf '%s' "$f"; return 0; }; done; return 1; }

# поиск без vendor/node_modules/.git
pfind() { find . \( -name vendor -o -name node_modules -o -name .git \) -prune -o "$@" -print 2>/dev/null; }

proj_go() {
    section "Go"
    local mod want tc have
    mod=$(awk '$1 == "module" { print $2; exit }' go.mod)
    want=$(awk '$1 == "go" { print $2; exit }' go.mod)
    tc=$(awk '$1 == "toolchain" { print $2; exit }' go.mod)
    pass "go.mod: ${mod:-без module} · go ${want:-?}${tc:+ · toolchain $tc}"
    if ! has go; then failed "go не установлен" "→ brew install go"
    else
        have=$(go env GOVERSION | sed 's/^go//')
        if [ -z "$want" ] || ver_ge "$have" "$want"; then pass "установлен go $have"
        elif [ "$(go env GOTOOLCHAIN)" = local ]; then failed "нужен go $want, есть $have, GOTOOLCHAIN=local" "→ unset GOTOOLCHAIN или brew upgrade go"
        else info "нужен go $want, есть $have — Go скачает тулчейн сам при первой сборке"; fi
    fi
    if grep -qE '^require' go.mod; then
        [ -f go.sum ] && pass "go.sum" || warning "есть зависимости, но нет go.sum" "→ go mod tidy"
    fi
    [ -d vendor ] && info "vendor/ — зависимости лежат в репозитории"
    local entry
    entry=$(first_of cmd/*/main.go main.go) && info "точка входа: $entry"
}

proj_tests() {
    section "Тесты"
    local n
    n=$(pfind -name '*_test.go' | wc -l | tr -d ' ')
    if [ "$n" -gt 0 ]; then pass "$n файлов с тестами · got — запустить"
    else warning "тестов нет" "→ *_test.go рядом с кодом; got / gotw"; fi
    has gotestsum && pass "gotestsum" || optional "gotestsum" "→ brew install gotestsum"
}

proj_quality() {
    section "Качество и безопасность"
    has golangci-lint && pass "golangci-lint $(vers golangci-lint --version)" || warning "нет golangci-lint" "→ brew install golangci-lint"
    local cfg
    cfg=$(first_of .golangci.yml .golangci.yaml .golangci.toml .golangci.json) && pass "конфиг линтера: $cfg" \
        || optional ".golangci.yml" "(линтер работает и с настройками по умолчанию)"
    if has govulncheck || [ -x "$(gobin)/govulncheck" ]; then pass "govulncheck · vuln — проверить зависимости"
    else warning "нет govulncheck" "→ dot tools install"; fi
}

proj_build() {
    section "Сборка и запуск"
    local f targets
    if [ -f Makefile ]; then
        targets=$(grep -oE '^[a-zA-Z0-9_.-]+:' Makefile | tr -d ':' | grep -v '^\.' | head -8 | tr '\n' ' ' | sed 's/ $//')
        pass "Makefile${targets:+: $targets}"
    else optional "Makefile" "(удобно: make run / test / lint)"; fi
    if f=$(first_of Dockerfile build/Dockerfile deploy/Dockerfile); then
        pass "$f"
        [ -f .dockerignore ] && pass ".dockerignore" || warning "нет .dockerignore" "→ в образ попадут .git, .env и мусор"
        grep -qiE '^FROM .* AS ' "$f" && info "многоэтапная сборка" || info "одноэтапная сборка — образ будет с компилятором Go"
    else optional "Dockerfile"; fi
    if f=$(first_of compose.yaml compose.yml docker-compose.yaml docker-compose.yml \
            deploy/compose.yaml deploy/compose.yml deploy/docker-compose.yaml deploy/docker-compose.yml); then
        pass "$f · up — поднять зависимости и приложение"
    else optional "compose.yaml"; fi
    [ -f .air.toml ] && pass ".air.toml (горячая перезагрузка)" || optional ".air.toml" "→ air init"
}

proj_data() {
    section "База данных"
    local dirs n
    dirs=$(pfind -type d \( -name migrations -o -name migrate \) | head -3 | sed 's|^\./||' | tr '\n' ' ')
    if [ -n "$dirs" ]; then
        n=$(pfind -path '*migrat*' -name '*.sql' | wc -l | tr -d ' ')
        pass "миграции: $dirs($n .sql)"
    else optional "миграции" "(migrations/ — для golang-migrate)"; fi
    first_of sqlc.yaml sqlc.yml sqlc.json >/dev/null && pass "sqlc"
    return 0
}

proj_config() {
    section "Конфиг и секреты"
    local in_git=0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 && in_git=1
    if [ -f .env.example ] || [ -f .env.sample ]; then pass ".env.example"
    elif [ -f .env ]; then warning "есть .env, но нет .env.example" "→ без него другим не понять, какие переменные нужны"
    else optional ".env.example"; fi
    if [ -f .env ] && [ "$in_git" = 1 ]; then
        if git ls-files --error-unmatch .env >/dev/null 2>&1; then failed ".env уже в git" "→ git rm --cached .env и смени секреты"
        elif git check-ignore -q .env; then pass ".env игнорируется git"
        else failed ".env не в .gitignore — уйдёт в коммит" "→ echo .env >> .gitignore"; fi
    fi
}

proj_git() {
    section "Git"
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        warning "не git-репозиторий" "→ git init"; return
    fi
    local branch dirty remote f
    branch=$(git branch --show-current 2>/dev/null)
    dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    remote=$(git remote get-url origin 2>/dev/null)
    pass "ветка ${branch:-(detached)}${remote:+ · $remote}"
    [ "$dirty" -eq 0 ] && pass "нет незакоммиченного" || info "$dirty изменённых файлов"
    [ -f .gitignore ] && pass ".gitignore" || warning "нет .gitignore" "→ хотя бы бинарники и .env"
    if f=$(first_of .github/workflows/*.yml .github/workflows/*.yaml .gitlab-ci.yml); then pass "CI: $f"
    else optional "CI" "(.github/workflows)"; fi
}

project_doctor() {
    local dir=${1:-$PWD} root
    [ -d "$dir" ] || { echo "нет папки: $dir" >&2; return 2; }
    dir=$(cd "$dir" && pwd)
    if root=$(find_go_root "$dir"); then
        cd "$root" || return 2
        printf '%s󰟓  %s%s  %s%s%s\n' "$c_head" "${root##*/}" "$r" "$c_dim" "${root/#$HOME/~}" "$r"
        proj_go; proj_tests; proj_quality; proj_build; proj_data; proj_config; proj_git
    else
        cd "$dir" || return 2
        printf '%s%s%s  %s%s — не Go-проект (нет go.mod), только общие проверки%s\n' \
            "$c_head" "${dir##*/}" "$r" "$c_dim" "${dir/#$HOME/~}" "$r"
        proj_build; proj_config; proj_git
    fi
    summary
}

project() {
    case "${1:-}" in
        doctor) shift; project_doctor "$@" ;;
        *) echo "dot project doctor [папка]" >&2; return 2 ;;
    esac
}
