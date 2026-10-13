# Tests

🇷🇺 [Русская версия](README.ru.md)

Smoke tests for `dot` and integration tests for the installer. No network, nothing installed, the real HOME is never touched.

| File | What |
|---|---|
| `smoke.sh` | `make test`; also runs in CI (Linux: portable parts, macOS: all) and before every push |
| `install.sh` | `install.sh` / `uninstall.sh` on a copy of the repo with a temp HOME: re-runs, backups (`.bak`, `.bak.1`), broken and foreign symlinks, restore byte for byte |

## Run

```bash
make test        # both suites
make check       # the CI checks (shellcheck, syntax, shaders, Go tests, gitleaks)
```

The installer tests already caught three real bugs: a second file in place of a link overwrote the first `.bak`,
and foreign or broken links were deleted without a backup. A new bug gets a test that catches it first.

[← dotfiles](../README.md)
