# ============================================================
#   Тема терминала: палитра T_* из ~/dotfiles/themes/<тема>.sh
#   theme            — выбрать тему (fzf с превью цветов)
#   theme kanagawa   — сразу применить
# ============================================================

DOTFILES_THEME=$(command cat ~/.config/dotfiles/theme 2>/dev/null || echo rose-pine)
[[ -f ~/dotfiles/themes/$DOTFILES_THEME.sh ]] || DOTFILES_THEME=rose-pine
source ~/dotfiles/themes/$DOTFILES_THEME.sh

# _c ROLE_HEX — ANSI-цвет текста из hex (для своих функций: ram, pl, шпаргалка)
_c() { printf '\e[38;2;%d;%d;%dm' 0x${1[1,2]} 0x${1[3,4]} 0x${1[5,6]}; }

# Перекрашенные apply.sh копии конфигов (если тему ещё не применяли — эталонные)
_tg=~/.cache/dotfiles-theme
[[ -f $_tg/starship.toml ]] && export STARSHIP_CONFIG=$_tg/starship.toml
[[ -f $_tg/eza/theme.yml ]] && export EZA_CONFIG_DIR=$_tg/eza || export EZA_CONFIG_DIR=~/.config/eza
[[ -f $_tg/lazygit.yml ]] && export LG_CONFIG_FILE=$_tg/lazygit.yml
[[ -f ~/.config/bat/themes/dotfiles.tmTheme ]] && export BAT_THEME=dotfiles || export BAT_THEME=rose-pine
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
