#!/usr/bin/env bash
# ============================================================
#   Настройки macOS для разработки. БЕЗ --yes НИЧЕГО НЕ МЕНЯЕТ — только показывает план.
#     ./macos.sh                      что изменится: «описание  сейчас → станет»
#     ./macos.sh --yes                применить
#     ./macos.sh [--yes] finder dock  только выбранные группы
#     ./macos.sh -v                   показать и то, что уже настроено
#   Группы: keyboard trackpad finder saving screenshots dock appearance apps
#   Повторный запуск безопасен: совпадающие значения пропускаются.
#   Перезапускаются только Finder / Dock / SystemUIServer. Без logout и reboot —
#   клавиатура, трекпад и тёмная тема вступят в силу после перелогина.
#   Откатить одну настройку: defaults delete <домен> <ключ> (домен и ключ — в этом файле).
# ============================================================
set -uo pipefail

ALL="keyboard trackpad finder saving screenshots dock appearance apps"
apply=0 verbose=0 groups="" changed=0 restart=""

if [ -t 1 ]; then
    c_head=$'\e[38;2;168;85;247m' c_new=$'\e[38;2;59;130;246m' c_dim=$'\e[38;2;110;110;120m' r=$'\e[0m'
else c_head='' c_new='' c_dim='' r=''; fi

for a in "$@"; do
    case $a in
        --yes|-y) apply=1 ;;
        -v|--verbose) verbose=1 ;;
        -h|--help) sed -n '3,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) case " $ALL " in
               *" $a "*) groups="$groups $a" ;;
               *) echo "неизвестно: $a (группы: $ALL)" >&2; exit 2 ;;
           esac ;;
    esac
done
[ "$(uname -s)" = Darwin ] || { echo "только macOS" >&2; exit 2; }

# pref <домен> <ключ> <bool|int|float|string> <значение> <описание>
pref() {
    local domain=$1 key=$2 type=$3 want=$4 desc=$5 cur norm=$4
    cur=$(defaults read "$domain" "$key" 2>/dev/null) || cur="—"
    if [ "$type" = bool ]; then [ "$want" = true ] && norm=1 || norm=0; fi
    if [ "$cur" = "$norm" ]; then
        [ "$verbose" = 1 ] && printf '  %s✓ %s%s\n' "$c_dim" "$desc" "$r"
        return 0
    fi
    changed=$((changed + 1)); group_changed=1
    # для bool показываем true/false, а не 1/0; «—» — ключ не задан (действует системное значение)
    if [ "$type" = bool ]; then case $cur in 1) cur=true ;; 0) cur=false ;; esac; fi
    # выравнивание по символам, а не байтам (printf %-Ns в bash 3.2 считает байты кириллицы)
    local pad=$((46 - $(printf '%s' "$desc" | wc -m)))
    [ "$pad" -lt 1 ] && pad=1
    printf '  %s~%s %s%*s%s%s →%s %s%s%s\n' "$c_new" "$r" "$desc" "$pad" '' "$c_dim" "$cur" "$r" "$c_new" "$want" "$r"
    if [ "$apply" = 1 ] && ! defaults write "$domain" "$key" "-$type" "$want" 2>/dev/null; then
        printf '    %s↳ не записалось (защищённый домен?)%s\n' "$c_dim" "$r"
    fi
    return 0
}

keyboard() {
    pref NSGlobalDomain KeyRepeat int 2                                "повтор клавиш: быстрый"
    pref NSGlobalDomain InitialKeyRepeat int 15                        "задержка до повтора: короткая"
    pref NSGlobalDomain ApplePressAndHoldEnabled bool false            "зажатие = повтор, не меню акцентов"
    pref NSGlobalDomain NSAutomaticSpellingCorrectionEnabled bool false "без автокоррекции"
    pref NSGlobalDomain NSAutomaticCapitalizationEnabled bool false    "без авто-заглавных"
    pref NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled bool false "прямые кавычки (код!)"
    pref NSGlobalDomain NSAutomaticDashSubstitutionEnabled bool false  "без замены -- на тире"
    pref NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled bool false "без точки по двойному пробелу"
}

trackpad() {
    pref com.apple.AppleMultitouchTrackpad Clicking bool true                    "касание = клик"
    pref com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking bool true   "касание = клик (Magic Trackpad)"
}

finder() {
    pref NSGlobalDomain AppleShowAllExtensions bool true               "Finder: показывать расширения"
    pref com.apple.finder FXEnableExtensionChangeWarning bool false    "Finder: не спрашивать при смене расширения"
    pref com.apple.finder AppleShowAllFiles bool true                  "Finder: скрытые файлы (⌘⇧. — переключить)"
    pref com.apple.finder ShowPathbar bool true                        "Finder: строка пути"
    pref com.apple.finder ShowStatusBar bool true                      "Finder: строка состояния"
    pref com.apple.finder FXPreferredViewStyle string Nlsv             "Finder: вид списком"
    pref com.apple.finder _FXSortFoldersFirst bool true                "Finder: папки сверху"
    pref com.apple.finder FXDefaultSearchScope string SCcf             "Finder: поиск в текущей папке"
    pref com.apple.finder NewWindowTarget string PfLo                  "Finder: новое окно — в папке…"
    pref com.apple.finder NewWindowTargetPath string "file://$HOME/dev/" "… ~/dev"
    pref com.apple.desktopservices DSDontWriteNetworkStores bool true  "без .DS_Store на сетевых дисках"
    pref com.apple.desktopservices DSDontWriteUSBStores bool true      "без .DS_Store на флешках"
}

saving() {
    pref NSGlobalDomain NSDocumentSaveNewDocumentsToCloud bool false   "сохранять на диск, а не в iCloud"
    pref NSGlobalDomain NSNavPanelExpandedStateForSaveMode bool true   "диалог сохранения развёрнут"
    pref NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 bool true  "диалог сохранения развёрнут (2)"
    # TextEdit (простой текст, UTF-8) отсюда не настроить: он в песочнице, а в чужой контейнер
    # macOS не пускает без Full Disk Access — TextEdit → Настройки → «Простой текст».
}

screenshots() {
    pref com.apple.screencapture location string "$HOME/Pictures/Screenshots" "скриншоты в ~/Pictures/Screenshots"
    pref com.apple.screencapture type string png                       "скриншоты в PNG"
    pref com.apple.screencapture disable-shadow bool true              "скриншоты окон без тени"
    pref com.apple.screencapture show-thumbnail bool false             "без превью в углу (файл сразу)"
    [ "$apply" = 1 ] && mkdir -p "$HOME/Pictures/Screenshots"
    return 0
}

dock() {
    pref com.apple.dock autohide bool true                             "Dock: скрывать (место под AeroSpace)"
    pref com.apple.dock autohide-delay float 0                         "Dock: появляется без задержки"
    pref com.apple.dock show-recents bool false                        "Dock: без недавних приложений"
    pref com.apple.dock minimize-to-application bool true              "Dock: сворачивать в иконку приложения"
    pref com.apple.dock mineffect string scale                         "Dock: простая анимация сворачивания"
    pref com.apple.dock mru-spaces bool false                          "не переставлять рабочие столы (AeroSpace)"
}

# файлы кода (.go .md .json .yaml .sh .sql .env …) открываются в Zed — macos/default-apps.swift
# macOS 26 спрашивает подтверждение на каждое расширение — применять, сидя за Mac
apps() {
    local out n
    out=$(swift "$(dirname "$0")/macos/default-apps.swift" "$([ "$apply" = 1 ] && echo apply || echo check)" 2>&1)
    [ -n "$out" ] && printf '%s\n' "$out"
    n=$(grep -c '^  ~' <<<"$out")
    changed=$((changed + n)); [ "$n" -gt 0 ] && group_changed=1
    return 0
}

appearance() {
    pref NSGlobalDomain AppleInterfaceStyle string Dark                "тёмная тема"
    pref NSGlobalDomain NSWindowShouldDragOnGesture bool true          "⌃⌘ + тянуть — двигать окно за любое место"
    pref NSGlobalDomain NSAutomaticWindowAnimationsEnabled bool false  "без анимации открытия окон"
}

[ "$apply" = 1 ] && echo "применяю:" || echo "план (ничего не меняется):"
for g in ${groups:-$ALL}; do
    group_changed=0
    printf '%s%s%s\n' "$c_head" "$g" "$r"
    "$g"
    if [ "$group_changed" = 1 ]; then
        case $g in
            finder) restart="$restart Finder" ;;
            dock) restart="$restart Dock" ;;
            screenshots) restart="$restart SystemUIServer" ;;
        esac
    elif [ "$verbose" = 0 ]; then
        printf '  %s✓ уже настроено%s\n' "$c_dim" "$r"
    fi
done

echo
if [ "$changed" -eq 0 ]; then echo "всё уже настроено"
elif [ "$apply" = 0 ]; then echo "изменений: $changed · применить: ./macos.sh --yes$groups"
else
    # shellcheck disable=SC2086  # список имён процессов
    [ -n "$restart" ] && killall $restart 2>/dev/null
    echo "готово: $changed изменений${restart:+ · перезапущены:$restart}"
    echo "клавиатура, трекпад и тема — после перелогина (сам не перелогиниваю)"
fi
