# Upgrading macOS (a major one, e.g. 26 → 27)

🇷🇺 [Русская версия](macos-upgrade.ru.md) · [all docs](README.md)

A checklist for one evening. Everything that can be checked with a command is checked with a command.

## Before the upgrade

1. **Everything is on GitHub**
   ```bash
   cd ~/dotfiles && git status -sb      # "ahead N" means something isn't pushed
   git push                             # pre-push runs make check and the smoke tests itself
   git -C wallpapers/photos status -sb  # photos live in the private dotfiles-photos
   ```
2. **Backup.** Time Machine on an external disk: Settings → General → Time Machine → Back Up Now.
   `dot doctor` warns when there are no backups.
3. **Update the apps** — fresh versions are more likely to know the new macOS already:
   `update` (brew, Go tools), and separately AeroSpace, OrbStack, Raycast (they have their own updaters).
4. **A "before" snapshot of the system:** `dot snapshot`
5. Quit OrbStack with its containers (`lean on` or by hand) so the VM doesn't get in the way of the installer.

## After the upgrade

1. **Command Line Tools** — they often break after a major upgrade, and without them brew, git and cgo don't work:
   ```bash
   xcode-select --install               # if git complains about an "invalid active developer path"
   ```
2. **An "after" snapshot and the comparison:**
   ```bash
   dot snapshot && dot snapshot diff    # what reset: settings, login items, permissions
   ```
3. **Check everything:** `dot doctor --deep` — every problem with the command that fixes it.
   The macOS section says by itself how many `macos.sh` settings went back to the defaults.
4. **Permissions.** If AeroSpace doesn't move windows or ctrl+` doesn't work: Settings →
   Privacy & Security → Accessibility → turn AeroSpace (and Raycast) off and on again.
5. **macOS settings**, if `snapshot diff` showed drifted ones: `./macos.sh` (plan) → `./macos.sh --yes`.
   Code files in Zed: `./macos.sh --yes apps` (macOS asks about each type, so do it at the screen).
6. **brew:** `brew doctor`, `brew upgrade` — formulae may rebuild for the new system.
7. **Wallpaper and theme:** `theme <current>` rebuilds the icons and sets the wallpaper on every Space.
8. **`orbstack`:** `update` rebuilds it with the new Go — `dot doctor` tells you if the binary is outdated.
9. **Go projects with cgo** (sqlite, some drivers): `go clean -cache` and rebuild.

## If something broke completely

[recovery.md](recovery.md) — how to bring everything up from scratch: `bootstrap.sh` on a clean system.
