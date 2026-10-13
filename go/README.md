# Go tools

🇷🇺 [Русская версия](README.ru.md)

Go tools installed with `go install` at **pinned versions**, so a new Mac gets exactly these.

| File | What |
|---|---|
| `tools.txt` | gopls (language server for Zed), air (restart on save), golangci-lint-langserver (the linter in the editor), govulncheck (vulnerabilities), gofumpt (strict format), gw (`github` — GitHub in the terminal, code written by an AI) |
| `tools.devops.txt` | optional: tflint (Homebrew dropped it) |

## Usage

`dot tools` shows installed vs pinned, `dot tools install` installs the pinned ones (`dot tools install devops` for the optional list). To upgrade a tool, change its version here first. `update` runs the install too.

## Why not Homebrew

Some of these aren't in Homebrew, and `brew "air"` is a different program with the same name. `go install` with an exact
version gives the same thing on any Mac. Rune and Neovim install their own gopls — these versions don't affect them.

[← dotfiles](../README.md)
