# ============================================================
#   Тема терминала: палитра T_* из ~/dotfiles/themes/<тема>.sh
#   theme            — выбрать тему (fzf с превью цветов)
#   theme kanagawa   — сразу применить
# ============================================================

DOTFILES_THEME=$(command cat ~/.config/dotfiles/theme 2>/dev/null || echo rose-pine)
[[ -f ~/dotfiles/themes/$DOTFILES_THEME.sh ]] || DOTFILES_THEME=rose-pine
source ~/dotfiles/themes/$DOTFILES_THEME.sh

# Светлый режим macOS → светлая палитра Dev Day (Ghostty переключается сам, zsh — при старте).
# Вручную: DOTFILES_APPEARANCE=light|dark в ~/.zshenv
if [[ ${DOTFILES_APPEARANCE:-$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo light)} == light ]]; then
    source ~/dotfiles/themes/light/day.sh
    DOTFILES_LIGHT=1
fi

# _c ROLE_HEX — ANSI-цвет текста из hex (для своих функций: ram, pl, шпаргалка)
_c() { printf '\e[38;2;%d;%d;%dm' 0x${1[1,2]} 0x${1[3,4]} 0x${1[5,6]}; }

# Перекрашенные apply.sh копии конфигов (если тему ещё не применяли — эталонные)
_tg=~/.cache/dotfiles-theme
(( DOTFILES_LIGHT )) && [[ -d $_tg/light ]] && { _tg=$_tg/light; export DELTA_FEATURES=+day; }
[[ -f $_tg/starship.toml ]] && export STARSHIP_CONFIG=$_tg/starship.toml
[[ -f $_tg/eza/theme.yml ]] && export EZA_CONFIG_DIR=$_tg/eza || export EZA_CONFIG_DIR=~/.config/eza
[[ -f $_tg/lazygit.yml ]] && export LG_CONFIG_FILE=$_tg/lazygit.yml
[[ -f ~/.config/bat/themes/dotfiles.tmTheme ]] && export BAT_THEME=dotfiles || export BAT_THEME=rose-pine
(( DOTFILES_LIGHT )) && [[ -f ~/.config/bat/themes/dotfiles-light.tmTheme ]] && export BAT_THEME=dotfiles-light
unset _tg

theme() {
    local pick=$1
    if [[ -z $pick ]]; then
        # превью: полоса из цветов палитры каждой темы
        pick=$(command ls ~/dotfiles/themes/*.sh | xargs -n1 basename | sed 's/\.sh$//' | grep -vx apply | \
            fzf --header="тема · сейчас: $DOTFILES_THEME" --height=40% --preview-window=right:60% \
                --preview 'source ~/dotfiles/themes/{}.sh; echo "  $THEME_TITLE"; echo;
                    for c in $T_BASE $T_OVERLAY $T_MUTED $T_TEXT $T_LOVE $T_GOLD $T_ROSE $T_PINE $T_FOAM $T_IRIS; do
                        printf "\e[48;2;%d;%d;%dm      \e[0m" 0x${c:0:2} 0x${c:2:2} 0x${c:4:2}; done; echo; echo;
                    printf "\e[38;2;%d;%d;%dm  ❯ \e[38;2;%d;%d;%dmgit status\e[0m\n" \
                        0x${T_ROSE:0:2} 0x${T_ROSE:2:2} 0x${T_ROSE:4:2} 0x${T_FOAM:0:2} 0x${T_FOAM:2:2} 0x${T_FOAM:4:2}') || return
    fi
    ~/dotfiles/themes/apply.sh "$pick" || return
    # тема поставила свои обои — фон терминала пересобрать под их цвета
    local bd=$(command cat ~/.config/dotfiles/backdrop 2>/dev/null)
    [[ -n $bd && $bd != off ]] && backdrop $bd >/dev/null
    print -P "%F{8}Ghostty: cmd+shift+, — перечитать конфиг%f"
    exec zsh
}

# palette — цвета текущей темы: роли T_* и 16 цветов терминала (для скриншотов и чтобы подобрать цвет)
palette() {
    local r=$'\e[0m' role hex
    print "\n  ${THEME_TITLE:-$DOTFILES_THEME}${DOTFILES_LIGHT:+ · Dev Day (светлый режим)}\n"
    for role in BASE SURFACE OVERLAY MUTED SUBTLE TEXT LOVE GOLD ROSE PINE FOAM IRIS; do
        hex=${(P)${:-T_$role}}
        printf '  \e[48;2;%d;%d;%dm      %s  %s%-8s %s#%s%s\n' 0x${hex[1,2]} 0x${hex[3,4]} 0x${hex[5,6]} "$r" "$(_c $T_TEXT)" "$role" "$(_c $T_MUTED)" "$hex" "$r"
    done
    print
    local i; for i in {0..7}; do print -n "  %K{$i}    %k" | print -P -n -- "$(cat)"; done; print
    for i in {8..15}; do print -P -n -- "  %K{$i}    %k"; done; print "\n"
}

# wall — сменить обои: wall (выбор с превью-картинкой) · wall eclipse · wall sakura …
#   wall add <фото> [имя] — своё фото: увеличивается под экран без мыла (icons/photo-wallpaper.swift)
# Живые обои — icons/wallpaper-<имя>.swift (новые с runWallpaper собираются вместе с wallpaper-kit.swift).
# Фото — ~/dotfiles/wallpapers/photos/<имя>.jpg (в .gitignore: на GitHub не уходят).
# Готовые HEIC — ~/Pictures/Wallpapers/<имя>.heic, превью — ~/.cache/wallpapers/<имя>.png
_wall_photos=~/dotfiles/wallpapers/photos
_wall_names() {
    command ls ~/dotfiles/icons/wallpaper-*.swift | sed 's|.*/wallpaper-||; s|\.swift$||' | grep -vx kit
    print -l $_wall_photos/*.(jpg|jpeg|png|heic|webp)(N:t:r)
}
_wall_photo() { local f=($_wall_photos/$1.(jpg|jpeg|png|heic|webp)(N)); print -r -- ${f[1]}; }
# _wall_build <имя> <выход> [ширина высота] — собрать HEIC (или PNG-превью)
_wall_build() {
    local src=~/dotfiles/icons/wallpaper-$1.swift out=$2 photo=$(_wall_photo $1); shift 2
    if [[ ! -f $src && -n $photo ]]; then         # фото: генератор компилируется один раз
        local gen=~/.cache/wallpapers/photo-wallpaper
        [[ -x $gen && $gen -nt ~/dotfiles/icons/photo-wallpaper.swift ]] || \
            swiftc -O ~/dotfiles/icons/photo-wallpaper.swift -o $gen 2>/dev/null || return
        $gen $photo $out "$@" >/dev/null
    elif grep -q runWallpaper $src; then
        local tmp=~/.cache/wallpapers/build-$1.swift
        command cat ~/dotfiles/icons/wallpaper-kit.swift $src >| $tmp
        swift $tmp $out "$@" >/dev/null 2>&1
    elif [[ $out == *.png ]]; then          # старые генераторы: кадр 13:00 из папки превью
        local dir=$(mktemp -d)
        swift $src $dir/ "$@" >/dev/null 2>&1 && command cp -f $dir/4-*.png $out
        command rm -rf $dir
    else
        swift $src $out "$@" >/dev/null 2>&1
    fi
}
wall() {
    mkdir -p ~/.cache/wallpapers ~/Pictures/Wallpapers $_wall_photos
    local name=$1 n
    if [[ $name == add ]]; then                 # wall add <фото> [имя]
        local file=$2 nm=${3:-${2:t:r}}
        [[ -f $file ]] || { echo "usage: wall add <фото> [имя]"; return 1; }
        nm=${nm:l}; nm=${nm// /-}
        command cp -f $file $_wall_photos/$nm.${file:e:l} && echo "добавлено: $nm"
        command rm -f ~/Pictures/Wallpapers/$nm.heic ~/.cache/wallpapers/$nm.png
        name=$nm
    fi
    if [[ -z $name ]]; then
        for n in $(_wall_names); do          # недостающие превью — один раз
            [[ -f ~/.cache/wallpapers/$n.png ]] || { echo "превью: $n…"; _wall_build $n ~/.cache/wallpapers/$n.png 960 624; }
        done
        name=$(_wall_names | fzf --header="обои · enter — поставить" --height=90% \
            --preview 'chafa --animate=off -s ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} ~/.cache/wallpapers/{}.png' \
            --preview-window=right:75%) || return
    fi
    local src=~/dotfiles/icons/wallpaper-$name.swift heic=~/Pictures/Wallpapers/$name.heic photo=$(_wall_photo $name)
    [[ -f $src || -n $photo ]] || { echo "нет обоев: $name (есть: $(_wall_names | tr '\n' ' '))"; return 1; }
    [[ -f $src ]] || src=$photo
    if [[ ! -f $heic || $src -nt $heic || ( $src == *.swift && ~/dotfiles/icons/wallpaper-kit.swift -nt $heic ) || ( $src != *.swift && ~/dotfiles/icons/photo-wallpaper.swift -nt $heic ) ]]; then
        echo "рисую $name…"; _wall_build $name $heic || return
    fi
    python3 ~/dotfiles/themes/set-wallpaper.py $heic
    print -r -- $heic >| ~/.config/dotfiles/wall-path
    # фон терминала берёт цвета из обоев — пересобрать под новые
    local bd=$(command cat ~/.config/dotfiles/backdrop 2>/dev/null)
    [[ -n $bd && $bd != off ]] && backdrop $bd
}

# backdrop — фон Ghostty из текущих обоев (как wall, только за текстом терминала):
#   backdrop (выбор с превью) · backdrop glow · backdrop off
#   haze — облака света обоев · glow — свет из углов · aurora — сияние снизу · glass — обои сквозь стекло
#   Цвета берутся из обоев, тёмное прозрачно — фон подходит и тёмной теме, и светлой Dev Day.
_backdrop_styles=(glow aurora haze glass)
_backdrop_build() {     # стиль → ~/.cache/dotfiles-theme/backdrop/<стиль>.png
    local dir=~/.cache/dotfiles-theme/backdrop src=~/dotfiles/icons/backdrop.swift
    local wp=$(command cat ~/.config/dotfiles/wall-path 2>/dev/null)
    [[ -f $wp ]] || wp=$(osascript -e 'tell application "System Events" to get picture of current desktop' 2>/dev/null)
    [[ -f $wp ]] || { echo "не нашёл текущие обои — сначала wall"; return 1; }
    mkdir -p $dir
    if [[ ! -x $dir/backdrop || $src -nt $dir/backdrop ]]; then
        echo "собираю генератор фона (один раз)…"; swiftc -O $src -o $dir/backdrop 2>/dev/null || return
    fi
    $dir/backdrop $wp $1 $dir/$1.png >/dev/null
}
backdrop() {
    local style=$1 cfg=~/.config/ghostty/backdrop.ghostty s
    if [[ -z $style ]]; then
        for s in $_backdrop_styles; do _backdrop_build $s || return; done
        style=$(print -l $_backdrop_styles off | fzf --header="фон терминала · сейчас: $(command cat ~/.config/dotfiles/backdrop 2>/dev/null || echo off)" \
            --height=90% --preview-window=right:75% \
            --preview '[[ {} == off ]] && echo "без фона" || chafa --animate=off -s ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} ~/.cache/dotfiles-theme/backdrop/{}.png') || return
    fi
    if [[ $style == off ]]; then
        print "# фон выключен (backdrop off)" >| $cfg
    else
        (( ${_backdrop_styles[(Ie)$style]} )) || { echo "стили: $_backdrop_styles off"; return 1; }
        _backdrop_build $style || return
        print -l "# сгенерировано backdrop ($style) — не править руками" \
            "background-image = $HOME/.cache/dotfiles-theme/backdrop/$style.png" \
            "background-image-fit = cover" "background-image-repeat = false" >| $cfg
    fi
    print $style >| ~/.config/dotfiles/backdrop
    print -P "%F{#$T_FOAM}фон: $style%f %F{#$T_MUTED}· Ghostty: cmd+shift+, — перечитать конфиг%f"
}
