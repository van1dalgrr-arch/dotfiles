# Dev Day — светлая палитра терминала, пара к Zed Dev Day. Включается сама, когда macOS в светлом режиме:
# Ghostty переключает тему мгновенно, zsh — в новых окнах (старые: exec zsh).
# Те же роли, что у тёмных тем; акценты на тон глубже, чтобы читались на белом.
T_BASE=fafafb      T_SURFACE=f1f1f5   T_OVERLAY=e8e8ee
T_HL_LOW=f1f1f5    T_HL_MED=e1e1ea    T_HL_HIGH=d2d3dc
T_MUTED=8a8a94     T_SUBTLE=55555f    T_TEXT=1b1e2d
T_LOVE=dc2626      T_GOLD=a16207      T_ROSE=7c3aed
T_PINE=74747e      T_FOAM=2563eb      T_IRIS=3d4262
T_DIFF_ADD=e3ebfd  T_DIFF_ADD_EMPH=c7d7fb
T_DIFF_DEL=fde8ec  T_DIFF_DEL_EMPH=f8c9d3

# Ghostty: тема целиком (~/.config/ghostty/themes/dotfiles-light)
GHOSTTY_LIGHT="background = #fafafb
foreground = #1b1e2d
cursor-color = #7c3aed
cursor-text = #fafafb
selection-background = #e1e1ea
selection-foreground = #1b1e2d
unfocused-split-fill = #f1f1f5
palette = 0=#1b1e2d
palette = 1=#dc2626
palette = 2=#4f46e5
palette = 3=#a16207
palette = 4=#2563eb
palette = 5=#7c3aed
palette = 6=#0284c7
palette = 7=#d2d3dc
palette = 8=#6c7190
palette = 9=#ef4444
palette = 10=#6366f1
palette = 11=#b45309
palette = 12=#3b82f6
palette = 13=#9333ea
palette = 14=#0ea5e9
palette = 15=#ffffff"
