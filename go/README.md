# Go tools

🇷🇺 [Русская версия](README.ru.md)

Go tools installed with `go install` at **pinned versions**, so a new Mac gets exactly these.

| File | What |
|---|---|
| `tools.txt` | gopls, air, golangci-lint-langserver, govulncheck, gofumpt |
| `tools.devops.txt` | optional: tflint (Homebrew dropped it) |

## Usage

`dot tools` shows installed vs pinned, `dot tools install` installs the pinned ones (`dot tools install devops` for the optional list). To upgrade a tool, change its version here first. `update` runs the install too.

[← dotfiles](../README.md)
