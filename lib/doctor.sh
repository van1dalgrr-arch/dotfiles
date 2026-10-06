# shellcheck shell=bash
# dot doctor [--deep] — только читает. Нет обязательного (Brewfile) → ✗ и exit 1, необязательного → ○

# brew в doctor не должен ходить в сеть и обновлять себя
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ENV_HINTS=1

# tool <req|opt> <команда> <подсказка> [команда версии…] — версия печатается только в --deep
tool() {
    local level=$1 name=$2 hint=$3; shift 3
    if has "$name"; then
        if [ "$deep" = 1 ] && [ $# -gt 0 ]; then pass "$name $(vers "$@")"; else pass "$name"; fi
    elif [ "$level" = req ]; then failed "$name не найден" "$hint"
    else optional "$name" "$hint"; fi
}

brewfile_names() { grep -E '^(brew|cask) ' "$1" | sed -E 's/^(brew|cask) "([^"]+)".*/\2/; s|.*/||'; }

# пакет считается установленным, если он есть в brew, в /Applications (cask visual-studio-code ↔
# «Visual Studio Code.app») или в PATH (kubectl от OrbStack)
pkg_present() {
    local name=$1
    grep -qx "$name" <<<"$installed" || grep -qiE "^(${name}|${name//-/ })" <<<"$apps" || has "$name"
}

doc_links() {
    section "Симлинки (install.sh)"
    local src dst broken=0 total=0
    while read -r src dst; do
        dst=$(eval echo "$dst")
        total=$((total + 1))
        if [ "$(readlink "$dst" 2>/dev/null)" != "$DOTFILES/$src" ]; then
            failed "$dst" "→ должно указывать на $src · ./install.sh"; broken=$((broken + 1))
        fi
    done < <(grep -E '^link ' "$DOTFILES/install.sh" | sed -E 's/^link +([^ ]+) +"?([^"]+)"?.*/\1 \2/')
    [ "$broken" -eq 0 ] && pass "все $total ссылок на месте"
}

doc_brew() {
    section "Homebrew"
    if ! has brew; then failed "brew не найден" "→ https://brew.sh"; return; fi
    if [ "$(uname -m)" = arm64 ] && [ "$(brew --prefix)" = /opt/homebrew ]; then pass "brew $(brew --version | vers cat) · arm64, /opt/homebrew"
    else warning "brew не в /opt/homebrew или терминал под Rosetta" "→ uname -m должен быть arm64"; fi

    local installed apps name missing=""
    installed=$(brew list --formula -1 2>/dev/null; brew list --cask -1 2>/dev/null)
    apps=$(ls /Applications 2>/dev/null)
    for name in $(brewfile_names "$DOTFILES/Brewfile"); do pkg_present "$name" || missing="$missing $name"; done
    if [ -z "$missing" ]; then pass "Brewfile: всё установлено"
    else failed "Brewfile: не установлено:$missing" "→ brew bundle"; fi

    missing=""
    for name in $(brewfile_names "$DOTFILES/Brewfile.devops"); do pkg_present "$name" || missing="$missing $name"; done
    if [ -z "$missing" ]; then pass "Brewfile.devops: всё установлено"
    else optional "Brewfile.devops, не установлено:$missing" "→ brew bundle --file Brewfile.devops"; fi

    [ "$deep" = 1 ] || return 0
    # что стоит, но не описано ни в одном Brewfile (только явно поставленное, без зависимостей)
    local extra leaves
    leaves=$(brew leaves 2>/dev/null; brew list --cask -1 2>/dev/null)
    extra=$(cat "$DOTFILES/Brewfile" "$DOTFILES/Brewfile.devops" | brew bundle cleanup --file=- 2>/dev/null \
        | grep -vE '^(Would|Run)' | grep -Fxf <(printf '%s\n' "$leaves") | tr '\n' ' ' | sed 's/ $//')
    if [ -z "$extra" ]; then pass "нет пакетов вне Brewfile"
    else warning "стоит, но нет в Brewfile: $extra" "→ добавь в Brewfile или brew uninstall"; fi
    local outdated
    outdated=$(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
    if [ "$outdated" -eq 0 ]; then pass "всё свежее (по локальному индексу brew)"
    else info "$outdated пакетов можно обновить → dot update"; fi
    if brew doctor >/dev/null 2>&1; then pass "brew doctor: чисто"
    else warning "brew doctor нашёл замечания" "→ brew doctor"; fi
}

doc_go() {
    section "Go"
    if ! has go; then failed "go не найден" "→ brew install go"; return; fi
    pass "go $(go env GOVERSION | sed 's/^go//') · $(go env GOARCH)"
    case ":$PATH:" in
        *":$(gobin):"*) pass "$(gobin) в PATH" ;;
        *) warning "$(gobin) нет в PATH" "→ Go-утилиты не найдутся; см. PATH в .zshrc" ;;
    esac
    if [ "$deep" = 1 ]; then
        local tc
        tc=$(go env GOTOOLCHAIN)
        case $tc in
            local) warning "GOTOOLCHAIN=local" "→ проект с go 1.N новее установленного не соберётся; unset GOTOOLCHAIN" ;;
            *) pass "GOTOOLCHAIN=$tc · версия из go.mod скачается сама" ;;
        esac
        tools_status
    else
        local name missing=""
        while read -r name _ _; do
            [ -x "$(gobin)/$name" ] || has "$name" || missing="$missing $name"
        done < <(tools_list)
        if [ -z "$missing" ]; then pass "Go-утилиты из go/tools.txt"
        else warning "нет Go-утилит:$missing" "→ dot tools install"; fi
    fi
    if has mise; then
        info "mise $(vers mise --version) активен в zsh"
        if [ "$deep" = 1 ] && mise which go >/dev/null 2>&1; then
            warning "mise тоже управляет Go: $(mise which go)" "→ два Go в PATH; оставь один (см. README → Версии)"
        fi
    fi
}

doc_docker() {
    section "Docker"
    if ! has docker; then failed "docker CLI не найден" "→ brew install --cask orbstack"; return; fi
    if docker compose version >/dev/null 2>&1; then
        pass "docker compose $(vers docker compose version)"
    else failed "нет плагина docker compose" "→ OrbStack ставит его сам; ls ~/.docker/cli-plugins"; fi
    if docker info >/dev/null 2>&1; then pass "движок работает ($(docker context show 2>/dev/null))"
    else warning "Docker не запущен" "→ откроется сам при up или: open -a OrbStack"; fi
    if [ "$deep" = 1 ]; then
        docker buildx version >/dev/null 2>&1 && pass "buildx $(vers docker buildx version)" \
            || warning "нет buildx" "→ ls ~/.docker/cli-plugins"
        tool opt hadolint "" hadolint --version
        tool opt dive "" dive --version
    fi
}

doc_k8s() {
    section "Kubernetes"
    tool req kubectl "→ brew install kubernetes-cli" kubectl version --client
    tool req helm "→ brew install helm" helm version --short
    tool opt kind "кластер в Docker → brew bundle --file Brewfile.devops" kind version
    if has kustomize; then tool opt kustomize "" kustomize version
    else optional "kustomize" "(встроенный есть: kubectl kustomize) → Brewfile.devops"; fi
    if [ "$deep" = 1 ] && has kubectl; then
        local ctx
        ctx=$(kubectl config current-context 2>/dev/null)
        if [ -n "$ctx" ]; then info "контекст kubectl: $ctx"; else info "контекст kubectl не выбран"; fi
        if has kind && docker info >/dev/null 2>&1; then
            local clusters
            clusters=$(kind get clusters 2>/dev/null | tr '\n' ' ')
            info "кластеры kind: ${clusters:-нет}"
        fi
    fi
}

doc_iac() {
    section "Infrastructure as Code"
    tool opt tofu "→ brew bundle --file Brewfile.devops" tofu version
    tool opt tflint "→ dot tools install devops" tflint --version
    tool opt terraform-docs "→ brew bundle --file Brewfile.devops" terraform-docs --version
}

doc_git() {
    section "Git"
    tool req git "→ xcode-select --install" git --version
    [ -n "$(git config --global user.email)" ] && pass "git user: $(git config --global user.name) <$(git config --global user.email)>" \
        || warning "не задан git user.email" "→ git config --global user.email …"
    local hooks f bad=""
    hooks=$(git config --global core.hooksPath)
    if [ "${hooks/#\~/$HOME}" = "$DOTFILES/git/hooks" ]; then pass "глобальные хуки: git/hooks"
    else failed "глобальные хуки не подключены" "→ core.hooksPath в git/.gitconfig, ./install.sh"; fi
    for f in "$DOTFILES"/git/hooks/*; do [ -x "$f" ] || bad="$bad ${f##*/}"; done
    if [ -z "$bad" ]; then pass "хуки исполняемые"
    else failed "хуки без +x:$bad" "→ chmod +x git/hooks/*"; fi
    has gitleaks && pass "gitleaks проверяет каждый коммит" \
        || failed "нет gitleaks — pre-commit молча пропустит проверку" "→ brew install gitleaks"
    if git -C "$DOTFILES" diff --quiet && git -C "$DOTFILES" diff --cached --quiet; then pass "в dotfiles нет незакоммиченного"
    else warning "в dotfiles есть изменения" "→ git -C ~/dotfiles status"; fi
    if [ "$deep" = 1 ] && has gitleaks; then
        if gitleaks git --no-banner --redact --log-level error "$DOTFILES" >/dev/null 2>&1; then pass "история dotfiles: секретов нет (gitleaks)"
        else failed "gitleaks нашёл секрет в истории dotfiles" "→ gitleaks git -v ~/dotfiles"; fi
    fi
}

# JSON с комментариями и висячими запятыми, как его читает Zed
jsonc_ok() {
    python3 - "$1" <<'EOF' 2>/dev/null
import json, re, sys
s = open(sys.argv[1]).read()
s = re.sub(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*.*?\*/', lambda m: m.group(0) if m.group(0)[0] == '"' else '', s, flags=re.S)
json.loads(re.sub(r',(\s*[}\]])', r'\1', s))
EOF
}

doc_editors() {
    section "Терминал и редактор"
    if compgen -G "$HOME/Library/Fonts/JetBrainsMonoNerdFont*" >/dev/null || compgen -G "/Library/Fonts/JetBrainsMonoNerdFont*" >/dev/null; then
        pass "шрифт JetBrainsMono Nerd Font"
    else failed "нет шрифта JetBrainsMono Nerd Font" "→ brew install --cask font-jetbrains-mono-nerd-font"; fi
    local theme
    theme=$(cat "$HOME/.config/dotfiles/theme" 2>/dev/null || echo "")
    if [ -n "$theme" ] && [ -f "$DOTFILES/themes/$theme.sh" ]; then pass "тема: $theme"
    else warning "тема не применена" "→ dot theme vesper"; fi
    if [ -f "$HOME/.cache/dotfiles-theme/starship.toml" ] && [ -f "$HOME/.config/ghostty/theme.ghostty" ]; then
        pass "сгенерированные конфиги темы"
    else warning "нет сгенерированных конфигов темы" "→ dot theme"; fi

    local ghostty=/Applications/Ghostty.app/Contents/MacOS/ghostty
    if [ ! -x "$ghostty" ]; then failed "Ghostty не установлен" "→ brew install --cask ghostty"
    elif "$ghostty" +validate-config >/dev/null 2>&1; then pass "конфиг Ghostty валиден"
    else failed "в конфиге Ghostty ошибка" "→ ghostty +validate-config"; fi

    grep -q '^ctrl-backtick' "$DOTFILES/aerospace/aerospace.toml" && pass "выпадающий терминал: ctrl+\` через AeroSpace" \
        || warning "нет хоткея выпадающего терминала" "→ ctrl-backtick в aerospace.toml"
    if [ -d /Applications/Zed.app ]; then pass "Zed"
    else failed "Zed не установлен" "→ brew install --cask zed"; fi
    has zed || warning "нет команды zed" "→ ./install.sh создаст /opt/homebrew/bin/zed"
    if [ "$deep" = 1 ]; then
        local f bad=""
        if has python3; then
            for f in "$DOTFILES"/zed/*.json; do jsonc_ok "$f" || bad="$bad ${f##*/}"; done
        fi
        for f in "$DOTFILES"/zed/dev-night-theme/themes/*.json "$DOTFILES"/zed/dev-night-icons/icon_themes/*.json; do
            jq empty "$f" 2>/dev/null || bad="$bad ${f##*/}"
        done
        if [ -z "$bad" ]; then pass "конфиги и темы Zed разбираются"
        else failed "Zed не прочитает:$bad" "→ проверь запятые и скобки"; fi
        [ -f "$HOME/.config/ghostty/fx.ghostty" ] && pass "эффекты Ghostty: $(cat "$HOME/.config/dotfiles/fx" 2>/dev/null)" \
            || warning "эффекты Ghostty не настроены" "→ dot fx apply"
    fi
}

doc_shell() {
    section "Shell"
    [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ] && pass "oh-my-zsh" || failed "нет oh-my-zsh" "→ ./install.sh"
    [ -d "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" ] && pass "fzf-tab" || warning "нет fzf-tab" "→ ./install.sh"
    local t
    t=$(perl -MTime::HiRes=time -e '$s=time; system("zsh -i -c exit >/dev/null 2>&1"); printf "%.2f", time-$s')
    if awk "BEGIN{exit !($t < 0.35)}"; then pass "zsh стартует за ${t} с"
    else warning "zsh стартует за ${t} с" "→ медленно, что-то тяжёлое в .zshrc (первый запуск после ребута всегда дольше)"; fi
    [ "$deep" = 1 ] || return 0

    # закреплённые ревизии из install.sh совпадают с тем, что стоит
    local var dir want got
    for var in OMZ_REV:"$HOME/.oh-my-zsh" FZF_TAB_REV:"$HOME/.oh-my-zsh/custom/plugins/fzf-tab"; do
        dir=${var#*:}; var=${var%%:*}
        want=$(grep -E "^$var=" "$DOTFILES/install.sh" | cut -d= -f2)
        got=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
        if [ "$got" = "$want" ]; then pass "${dir##*/} на закреплённой ревизии ${want:0:7}"
        else info "${dir##*/}: ${got:0:7}, закреплено ${want:0:7} (обновился сам — ок, или ./install.sh на новом Mac)"; fi
    done
    local dups
    dups=$(zsh -ic 'print -l $path' 2>/dev/null | sort | uniq -d | tr '\n' ' ')
    if [ -z "$dups" ]; then pass "в PATH нет повторов"
    else warning "повторы в PATH: $dups" "→ typeset -U path в .zshrc"; fi
}

doctor() {
    local deep=0 a
    for a in "$@"; do
        case $a in
            --deep) deep=1 ;;
            *) echo "dot doctor [--deep]" >&2; return 2 ;;
        esac
    done
    [ "$(uname -s)" = Darwin ] || { echo "dot doctor — только для macOS" >&2; return 2; }
    doc_links; doc_brew; doc_go; doc_docker; doc_k8s; doc_iac; doc_git; doc_editors; doc_shell
    summary
}
