# Backend: база (db), уязвимости (vuln), нагрузка (load), Kubernetes

# db: DATABASE_URL из окружения или .env, иначе Postgres из compose (база = имя папки)
db() {
    local url=${1:-$DATABASE_URL}
    if [[ -z $url && -f .env ]]; then
        url=$(command grep -E '^DATABASE_URL=' .env | cut -d= -f2-)
        local pass=$(command grep -E '^DB_PASSWORD=' .env | cut -d= -f2-)
        [[ -z $url ]] && url="postgres://postgres:${pass:-postgres}@localhost:5432/${PWD:t}?sslmode=disable"
    fi
    url=${url:-postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable}
    print -P "%F{#$T_MUTED}→ ${url//:[^:@\/]*@/:***@}%f"      # пароль не печатаем
    pgcli "$url"
}

vuln() {
    [[ -f go.mod ]] && { print -P "%F{#$T_ROSE}󰚰  govulncheck%f"; govulncheck ./...; }
    print -P "\n%F{#$T_ROSE}󰚰  trivy%f"
    trivy fs --quiet --scanners vuln,secret,misconfig .
}

# load [url] [секунд] [соединений] — по умолчанию /health, 10 с, 50
load() {
    oha -z ${2:-10}s -c ${3:-50} ${1:-http://localhost:${PORT:-8080}/health}
}

# Kubernetes: переключить кластер / namespace, логи всех подов по имени
alias kx='kubectx'
alias kn='kubens'
alias klogs='stern'
alias j='fx'

alias pd='dot project doctor'
# OpenTofu (Brewfile.devops): tf plan / tf apply — только вручную
alias tf='tofu'   # j file.json или curl … | j — интерактивный просмотр JSON
