# Safari

🇷🇺 [Русская версия](README.ru.md)

Safari stays the browser: on an 8 GB M2 it uses the least memory and battery. Here it gets a start page
with the current wallpaper and theme colors, bookmarks from a text file, and JetBrains Mono for code on every site.

| File | What |
|---|---|
| `start.html` | start page template: clock, date, bookmarks on keys `1`–`9`, the wallpaper behind them |
| `links` | bookmarks, one per line: `name  url` |
| `user.css` | style sheet for every site: JetBrains Mono in `code`/`pre`, selection in the accent color |
| `build.sh` | fills in the theme colors, bookmarks and wallpaper → `~/.cache/dotfiles/safari/` |

`theme` and `wall` rebuild it on their own. After editing `links`: `safari/build.sh`.

## Setup, once

`./macos.sh safari` shows the plan, `./macos.sh --yes safari` applies it (quits Safari first). Safari's settings are
sandboxed: the terminal needs **Full Disk Access** (System Settings → Privacy & Security), otherwise the script says so
and stops. Without it, by hand:

1. **Safari → Settings → General.** New windows and New tabs open with: **Homepage**.
   Homepage: `file:///Users/<you>/.cache/dotfiles/safari/start.html`
2. **Settings → Advanced.** Style sheet → Other… → `⌘⇧G` → `~/.cache/dotfiles/safari/user.css`.
   While there: turn on **Show full website address** and **Show features for web developers**.

Optional: **uBlock Origin Lite** from the App Store (free).
Pages without ads and trackers are lighter, so it saves memory.

[← dotfiles](../README.md)
