# Troubleshooting

<details>
<summary>An app icon went back to the default</summary>

macOS resets custom icons when an app updates. Bring it back with `theme vesper`
(or `swift ~/.cache/dotfiles-theme/icons.swift apply`). Apps installed as root (VS Code, Telegram) need `sudo`.
</details>

<details>
<summary>The terminal didn't change colors after <code>theme</code></summary>

Ghostty reads its config on launch — press `cmd-shift-,` and open a new window.
</details>

<details>
<summary>The drop-down terminal doesn't open</summary>

Ghostty has to be running in the background (AeroSpace starts it at login) and needs Accessibility
permission — global hotkeys don't work without it.
</details>

<details>
<summary>I want starship back</summary>

Put `export PROMPT_ENGINE=starship` in `~/.zshenv` — the config is in `starship/`.
</details>
