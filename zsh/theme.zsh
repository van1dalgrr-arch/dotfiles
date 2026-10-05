# Тема (theme), обои (wall, wall add), фон терминала (backdrop), palette. Как пользоваться — docs/guide.ru.md

DOTFILES_THEME=$(command cat ~/.config/dotfiles/theme 2>/dev/null || echo rose-pine)
[[ -f ~/dotfiles/themes/$DOTFILES_THEME.sh ]] || DOTFILES_THEME=rose-pine
source ~/dotfiles/themes/$DOTFILES_THEME.sh

# светлый режим macOS → палитра Dev Day (zsh — при старте); вручную: DOTFILES_APPEARANCE=light|dark
if [[ ${DOTFILES_APPEARANCE:-$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo light)} == light ]]; then
    source ~/dotfiles/themes/light/day.sh
    DOTFILES_LIGHT=1
fi

# Ghostty перечитывает конфиг сам (AppleScript-действие reload_config) — без cmd+shift+,
_ghostty_reload() { pgrep -xq ghostty && osascript -e 'tell application "Ghostty" to if (count terminals) > 0 then perform action "reload_config" on first terminal' >/dev/null 2>&1; }

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
    exec zsh
}

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

# wall: живые обои — icons/wallpaper-<имя>.swift, фото — wallpapers/photos/ (в .gitignore).
# Готовые HEIC — ~/Pictures/Wallpapers, превью для fzf — ~/.cache/wallpapers
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
        # резервная копия: папка фото — приватный репозиторий dotfiles-photos; отправляем в фоне
        [[ -d $_wall_photos/.git ]] && ( git -C $_wall_photos add -A && git -C $_wall_photos commit -qm "wall add $nm" && git -C $_wall_photos push -q ) >/dev/null 2>&1 &!
        command rm -f ~/Pictures/Wallpapers/$nm.heic ~/.cache/wallpapers/$nm.png
        name=$nm
    fi
    if [[ -z $name ]]; then
        for n in $(_wall_names); do          # недостающие превью — один раз
            [[ -f ~/.cache/wallpapers/$n.png ]] || { echo "превью: $n…"; _wall_build $n ~/.cache/wallpapers/$n.png 960 624; }
        done
        name=$(for n in $(_wall_names); do
                   [[ -f ~/dotfiles/icons/wallpaper-$n.swift ]] && print "$n\t живые" || print "$n\t фото"
               done | fzf --header="обои · enter — поставить" --height=90% --delimiter='\t' \
            --preview 'chafa --animate=off -s ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} ~/.cache/wallpapers/{1}.png' \
            --preview-window=right:75%) || return
        name=${name%%$'\t'*}
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

# backdrop: фон Ghostty из цветов текущих обоев; тёмное прозрачно — годится и для светлой темы
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
    local out=$dir/$1.png stamp=$dir/.$1.src
    [[ -f $out && $out -nt $wp && $out -nt $dir/backdrop && $(<$stamp 2>/dev/null) == $wp ]] && return 0
    $dir/backdrop $wp $1 $out >/dev/null && print -r -- $wp >| $stamp
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
    _ghostty_reload
    print -P "%F{#$T_FOAM}фон: $style%f"
}
