# Иконки и обои

🇬🇧 [English version](README.md)

Генераторы на Swift: живые обои, обои из фото, фон терминала, стеклянные иконки приложений и папок.

| Файл | Что это |
|---|---|
| `wallpaper-*.swift` | 25 живых обоев: 12 кадров в сутки в динамический HEIC (`wall <имя>`) |
| `wallpaper-kit.swift` | общий набор для новых обоев (`runWallpaper { hour in … }`) |
| `photo-wallpaper.swift` | фото → обои под экран без мыла (`wall add`) |
| `backdrop.swift` | фон терминала из цветов обоев (`backdrop`) |
| `icons.swift` | стеклянные иконки приложений в цветах темы (`swift icons.swift apply`) |
| `folder.swift` | стеклянные иконки папок |
| `html2png.swift` | HTML → PNG через WebKit — для скриншотов в docs |

## Новые обои

Создай `wallpaper-<имя>.swift` с `runWallpaper { hour in … }`, потом `wall <имя>`. Галерея — [docs/wallpapers.md](../docs/wallpapers.md).

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
