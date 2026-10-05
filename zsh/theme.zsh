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
    print -P "%F{8}Ghostty: cmd+shift+, — перечитать конфиг%f"
    exec zsh
}

# wall — сменить живые обои: wall (выбор с превью-картинкой) · wall eclipse · wall orbit …
# Обои — icons/wallpaper-<имя>.swift. Новые (с runWallpaper) собираются вместе с wallpaper-kit.swift.
# Готовые HEIC — ~/Pictures/Wallpapers/<имя>.heic, превью — ~/.cache/wallpapers/<имя>.png
_wall_names() {
    command ls ~/dotfiles/icons/wallpaper-*.swift | sed 's|.*/wallpaper-||; s|\.swift$||' | grep -vx kit
}
# _wall_build <имя> <выход> [ширина высота] — собрать HEIC (или PNG-превью)
_wall_build() {
    local src=~/dotfiles/icons/wallpaper-$1.swift out=$2; shift 2
    if grep -q runWallpaper $src; then
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
    mkdir -p ~/.cache/wallpapers ~/Pictures/Wallpapers
    local name=$1 n
    if [[ -z $name ]]; then
        for n in $(_wall_names); do          # недостающие превью — один раз
            [[ -f ~/.cache/wallpapers/$n.png ]] || { echo "превью: $n…"; _wall_build $n ~/.cache/wallpapers/$n.png 960 624; }
        done
        name=$(_wall_names | fzf --header="обои · enter — поставить" --height=90% \
            --preview 'chafa --animate=off -s ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} ~/.cache/wallpapers/{}.png' \
            --preview-window=right:75%) || return
    fi
    local src=~/dotfiles/icons/wallpaper-$name.swift heic=~/Pictures/Wallpapers/$name.heic
    [[ -f $src ]] || { echo "нет обоев: $name (есть: $(_wall_names | tr '\n' ' '))"; return 1; }
    if [[ ! -f $heic || $src -nt $heic || ~/dotfiles/icons/wallpaper-kit.swift -nt $heic ]]; then
        echo "рисую $name…"; _wall_build $name $heic || return
    fi
    python3 ~/dotfiles/themes/set-wallpaper.py $heic
}
