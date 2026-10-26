#!/usr/bin/env bash
# discord/theme.sh <тема.sh> — тема Discord для Vencord (CSS) из ролей T_* в stdout.
# themes/apply.sh кладёт её в папку тем Vencord, если Vencord стоит; включить: Настройки → Vencord → Themes.
set -eu
# shellcheck source=/dev/null
source "$1"
cat <<CSS
/**
 * @name Dotfiles · ${THEME_TITLE}
 * @author dotfiles
 * @description Цвета текущей темы dotfiles (${THEME_TITLE}). Генерирует discord/theme.sh — не править руками.
 */
.theme-dark, .theme-darker, .theme-midnight, .visual-refresh.theme-dark {
  /* новый интерфейс (2025+) */
  --background-base-lowest: #$T_BASE;
  --background-base-lower: #$T_BASE;
  --background-base-low: #$T_SURFACE;
  --background-surface-high: #$T_OVERLAY;
  --background-surface-higher: #$T_OVERLAY;
  --background-surface-highest: #$T_HL_MED;
  --chat-background-default: #$T_BASE;
  --app-frame-background: #$T_BASE;
  /* старые имена — на случай отката интерфейса */
  --background-primary: #$T_BASE;
  --background-secondary: #$T_SURFACE;
  --background-secondary-alt: #$T_SURFACE;
  --background-tertiary: #$T_BASE;
  --background-floating: #$T_OVERLAY;
  --channeltextarea-background: #$T_OVERLAY;
  --background-modifier-hover: #${T_HL_MED}80;
  --background-modifier-selected: #$T_HL_MED;
  --background-modifier-active: #$T_HL_HIGH;
  /* текст */
  --text-normal: #$T_TEXT;
  --text-default: #$T_TEXT;
  --text-muted: #$T_MUTED;
  --header-primary: #$T_TEXT;
  --header-secondary: #$T_SUBTLE;
  --channels-default: #$T_SUBTLE;
  --interactive-normal: #$T_SUBTLE;
  --interactive-hover: #$T_TEXT;
  --interactive-active: #$T_TEXT;
  --interactive-muted: #$T_MUTED;
  --text-link: #$T_FOAM;
  /* акцент — главный цвет темы */
  --brand-500: #$T_ROSE;
  --brand-560: #$T_ROSE;
  --brand-experiment: #$T_ROSE;
  --control-brand-foreground: #$T_ROSE;
  --mention-foreground: #$T_ROSE;
  --mention-background: #${T_ROSE}26;
  --status-danger: #$T_LOVE;
  --status-warning: #$T_GOLD;
  --border-subtle: #$T_HL_MED;
  --border-faint: #$T_HL_LOW;
}
/* шрифт как в терминале — JetBrains Mono в коде */
code, pre { font-family: "JetBrains Mono", monospace !important; }
CSS
