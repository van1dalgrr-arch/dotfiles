# Иконки и обои

🇬🇧 [English version](README.md)

Генераторы на Swift: живые обои, обои из фото, фон терминала, стеклянные иконки приложений и папок.

| Файл | Что это |
|---|---|
| `wallpaper-*.swift` | 33 живых обоя: 12 кадров в сутки в динамический HEIC (`wall <имя>`) |
| `wallpaper-kit.swift` | общий набор для новых обоев (`runWallpaper { hour in … }`) |
| `terminal-grade.swift` | любые обои или фото → тёмный читаемый фон терминала (`backdrop <имя>`) |
| `photo-wallpaper.swift` | фото → обои под экран без мыла (`wall add`) |
| `backdrop.swift` | фон терминала из цветов обоев (`backdrop`) |
| `icons.swift` | стеклянные иконки приложений в цветах темы (`swift icons.swift apply`) |
| `folder.swift` | стеклянные иконки папок |
| `html2png.swift` | HTML → PNG через WebKit — для скриншотов в docs |

## Новые обои

Создай `wallpaper-<имя>.swift` с `runWallpaper { hour in … }`, потом `wall <имя>`. Галерея — [docs/wallpapers.md](../docs/wallpapers.md).

## Как пользоваться

Руками эти файлы запускать не нужно — их вызывают команды:

```bash
wall                 # выбрать обои (собирает HEIC при первом выборе, ~10–60 с)
wall add фото.jpg имя # своё фото → обои
backdrop             # фон терминала из текущих обоев (по желанию)
theme vesper         # тема перекрашивает и иконки приложений с папками
```

Готовые обои лежат в `~/Pictures/Wallpapers`, превью — в `~/.cache/wallpapers`. Переходы между кадрами делает
сама macOS, поэтому живые обои ничего не тратят в фоне.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
