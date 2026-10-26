#!/usr/bin/env bash
# telegram/palette.sh <тема.sh> — тема Telegram для macOS (.palette) из ролей T_* в stdout.
# Поставить: открыть файл в Telegram (themes/apply.sh кладёт его в ~/.cache/dotfiles-theme/telegram/).
# Ключи, которых здесь нет, Telegram берёт из родителя — тёмной темы Night.
set -eu
# shellcheck source=/dev/null
source "$1"
cat <<P
name = Dotfiles · ${THEME_TITLE}
isDark = 1
tinted = 1
parent = 3
copyright = dotfiles
accentList = $T_ROSE
basicAccent = #$T_ROSE
background = #$T_BASE
text = #$T_TEXT
grayText = #$T_SUBTLE
link = #$T_FOAM
accent = #$T_ROSE
redUI = #$T_LOVE
greenUI = #$T_FOAM
grayUI = #$T_OVERLAY
darkGrayText = #$T_MUTED
accentSelect = #$T_ROSE
selectText = #$T_HL_HIGH
blueIcon = #$T_ROSE
accentIcon = #$T_ROSE
grayIcon = #$T_SUBTLE
badgeMuted = #$T_MUTED
badge = #$T_ROSE
indicatorColor = #$T_ROSE
selectMessage = #$T_HL_MED
border = #$T_HL_MED
grayBackground = #$T_SURFACE
grayForeground = #$T_OVERLAY
listBackground = #$T_BASE
listGrayText = #$T_SUBTLE
chatBackground = #$T_BASE
bubbleBackground_incoming = #$T_OVERLAY
bubbleBackground_outgoing = #$T_ROSE
bubbleBorder_incoming = #$T_OVERLAY
bubbleBorder_outgoing = #$T_ROSE
textBubble_incoming = #$T_TEXT
textBubble_outgoing = #$T_BASE
linkBubble_incoming = #$T_FOAM
linkBubble_outgoing = #$T_BASE
grayTextBubble_incoming = #$T_SUBTLE
grayTextBubble_outgoing = #$T_HL_MED
P
