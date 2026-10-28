# Icons & wallpapers

🇷🇺 [Русская версия](README.ru.md)

Swift generators: live wallpapers, photo wallpapers, the terminal backdrop, glass app and folder icons.

| File | What |
|---|---|
| `wallpaper-*.swift` | 33 live wallpapers: 12 frames a day into a dynamic HEIC (`wall <name>`) |
| `wallpaper-kit.swift` | shared kit for new wallpapers (`runWallpaper { hour in … }`) |
| `terminal-grade.swift` | any wallpaper or photo → dark, readable terminal background (`backdrop <name>`) |
| `photo-wallpaper.swift` | photo → screen-sized wallpaper without blur (`wall add`) |
| `backdrop.swift` | terminal background from the wallpaper's colors (`backdrop`) |
| `icons.swift` | glass app icons in theme colors (`swift icons.swift apply`) |
| `apps.swift` | ready-made app icons from `apps/` — TablePro, Telegram, OrbStack, Bruno (`swift apps.swift apply`) |
| `folder.swift` | glass folder icons |
| `html2png.swift` | HTML → PNG with WebKit, for the screenshots in docs |

## New wallpaper

Create `wallpaper-<name>.swift` with `runWallpaper { hour in … }`, then `wall <name>`. Gallery: [docs/wallpapers.md](../docs/wallpapers.md).

## Using it

You don't run these by hand — commands call them:

```bash
wall                   # pick a wallpaper (builds the HEIC on first pick, ~10–60 s)
wall add photo.jpg name # your photo → wallpaper
backdrop               # terminal background from the current wallpaper (opt-in)
theme vesper           # the theme recolors app and folder icons too
```

Built wallpapers live in `~/Pictures/Wallpapers`, previews in `~/.cache/wallpapers`. macOS itself moves between frames,
so live wallpapers cost nothing in the background.

[← dotfiles](../README.md)
