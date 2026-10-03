#!/usr/bin/env bash
# «Плавность как в Linux»: убираем медленные анимации macOS. Откат: ./macos-speed.sh --reset
if [ "$1" = "--reset" ]; then
    for k in NSAutomaticWindowAnimationsEnabled NSWindowResizeTime NSScrollAnimationEnabled QLPanelAnimationDuration NSToolbarFullScreenAnimationDuration NSBrowserColumnAnimationSpeedMultiplier; do defaults delete NSGlobalDomain $k 2>/dev/null; done
    for k in expose-animation-duration launchanim springboard-show-duration springboard-hide-duration springboard-page-duration expose-group-apps; do defaults delete com.apple.dock $k 2>/dev/null; done
    defaults delete com.apple.finder DisableAllAnimations 2>/dev/null
    defaults delete com.apple.spaces spans-displays 2>/dev/null
    killall Dock Finder; exit 0
fi

# Окна: без анимации открытия, мгновенный ресайз
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write NSGlobalDomain QLPanelAnimationDuration -float 0
defaults write NSGlobalDomain NSToolbarFullScreenAnimationDuration -float 0
defaults write NSGlobalDomain NSBrowserColumnAnimationSpeedMultiplier -float 0

# Dock / Mission Control / Launchpad
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock springboard-show-duration -float 0.1
defaults write com.apple.dock springboard-hide-duration -float 0.1
defaults write com.apple.dock springboard-page-duration -float 0.2

# Finder без анимаций
defaults write com.apple.finder DisableAllAnimations -bool true

# Рекомендации AeroSpace: окна в Mission Control группируются по приложениям,
# один набор Spaces на все мониторы
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.spaces spans-displays -bool true

killall Dock Finder 2>/dev/null || true
echo "Готово. spans-displays применится после перелогина."
