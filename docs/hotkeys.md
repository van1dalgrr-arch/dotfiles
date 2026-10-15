# Hotkeys

🇷🇺 [Русская версия](hotkeys.ru.md) · [all docs](README.md)

AeroSpace, Ghostty, `orbstack`, Zed, Rune and Neovim. In the terminal, `?` (or `ctrl+/`) shows all of them plus every function and alias.

## AeroSpace — windows and workspaces

Hotkeys work on any keyboard layout, Russian included.

| Keys | Action |
|---|---|
| `alt-enter` | new terminal |
| `alt-e` | file manager (yazi) |
| `alt-q` | close window |
| `alt-h/j/k/l` | focus left / down / up / right |
| `alt-shift-h/j/k/l` | move window |
| `alt-1…9` | go to workspace |
| `alt-shift-1…9` | send window to workspace (and follow it) |
| `alt-tab` | previous workspace |
| `alt-shift-tab` | move the workspace to the next monitor |
| `alt-/` · `alt-,` | layout: tiles · accordion |
| `alt-shift-f` | fullscreen |
| `alt-shift-space` | floating ↔ tiling |
| `alt-minus` · `alt-equal` | narrower · wider |
| `alt-r` | resize mode: `hjkl`, `enter`/`esc` to leave |
| `alt-shift-;` | service mode: `r` flatten the layout, `f` floating, `backspace` close all but this one, `esc` reload |
| `alt-shift-c` | reload the config |

Workspaces: 2 — code, 3 — browser, 4 — chats, 5 — music; the terminal stays where you open it.

## Ghostty — terminal

| Keys | Action |
|---|---|
| `` ctrl+` `` | drop-down terminal from any app |
| `cmd-t` · `cmd-w` | new tab (in the titlebar) · close |
| `cmd-d` · `cmd-shift-d` | split right · down |
| `cmd-alt-arrows` | move between splits |
| `cmd-shift-enter` | zoom split |
| `cmd-shift-e` | equalize splits |
| `cmd-q` | close windows (Ghostty stays in the background, `` ctrl+` `` keeps working) |
| `cmd-shift-,` | reload the config (rarely needed: `theme`, `wall`, `backdrop` reload it themselves) |

## `orbstack` — containers

| Keys | Action |
|---|---|
| `↑↓` `j k` · wheel · click | pick a container (click again for actions) |
| `g` · `G` | first · last |
| `enter` | actions, each explained, with the docker command |
| `l` · `s` | follow logs · shell inside |
| `r` · `x` · `d` | restart · stop/start · remove |
| `i` · `f` · `c` | inside · Dockerfile · compose file |
| `n` · `t` · `w` | new from a template · live stats · live rebuild |
| `u` · `U` | compose up · down (the project in this folder) |
| `e` · `E` | start · stop the engine |
| `?` · `q` | all keys · quit |

In the viewer (`i`, `f`, `c`): `↑↓` scroll, `g`/`G` top/bottom, `esc` back.

## Zed — editor

| Keys | Action |
|---|---|
| `ctrl-r` | task menu: `up`, `air`, tests, coverage, linter, compose logs, `curl /health` |
| `ctrl-t` | run the test under the cursor |
| `f5` | debug with Delve: `cmd/api`, current package, or the test under the cursor |
| `ctrl-shift-r` | rerun the last task |
| `alt-g` · `alt-d` | lazygit · lazydocker inside Zed |
| `cmd-j` | terminal |
| `cmd-1` · `cmd-2` · `cmd-3` | files · outline · git |
| `cmd-0` · `cmd-9` | left · right dock |
| `cmd-shift-d` | all project diagnostics |
| `cmd-shift-b` · `cmd-alt-b` | git blame · inline blame |
| `alt-up` · `alt-down` | move the line up · down |
| `cmd-alt-l` | center the text |

Go snippets: `iferr`, `iferrw`, `ginh`, `ginbind`, `ginr`, `ginmw`, `ttest`, `htest`, `bench`, `qrow`, `slog`, `jstruct`, `ctxt`.

Also: golangci-lint runs as a language server (warnings right in the code), and `.http` files send requests
to your API like REST Client in VS Code.

## Rune — IDE (GoLand keymap)

| Keys | Action |
|---|---|
| `cmd-B` · `cmd-alt-B` · `alt-F7` · `F1` | definition · implementations · usages · docs |
| `cmd-O` · `cmd-shift-O` · `cmd-E` · `cmd-shift-T` | type · file · recent · test ↔ code |
| `ctrl-T` · `shift-F6` · `ctrl-alt-O` | every refactoring · rename · imports |
| `ctrl-alt-R` · `ctrl-shift-R` · `ctrl-alt-T` | run · test at cursor · all tests |
| `ctrl-alt-D` · `cmd-F8` · `F8` / `F7` / `shift-F8` | debug · breakpoint · stepping |
| `ctrl-alt-L` · `ctrl-alt-E` · `ctrl-alt-W` | linter · build errors · vet and tests in the background |

Everything else is in [rune/README.md](../rune/README.md). F-keys need `fn`.

## Neovim — LazyVim

| Keys | Action |
|---|---|
| `alt-o` · `alt-g` · `alt-p` · `alt-a` · `alt-d` · `alt-t` | orbstack · lazygit · Postman · endpoints · database · tasks — one press |
| `space` | menu of every action with hints |
| `space f f` · `space /` · `space e` | file · text across the project · file tree |
| `gd` · `gr` · `K` · `space c r` · `space c a` | definition · usages · docs · rename · code actions |
| `space t r` · `space d b` · `space d c` | test at cursor · breakpoint · start debugging |
| `space r x` · `space r X` | ▶ run the `func main` / test at the cursor · under the debugger |
| `gpd` · `gpr` · `gpi` · `space c h` | peek definition / usages / implementations · who calls it |
| `space c x` · `space c i` · `space c w` · `S-F6` | extract · inline · rewrite · rename |
| `space G …` | Go: tags, implement an interface, `if err`, tests, coverage |
| `space g v` · `space g m` · `space U` | diffview and conflicts · branch against main · the file's edit history |
| `ctrl-n` · `space a c` · `space h` | multiple cursors · Claude Code · **cheat sheet** |
| `alt-c` · `space a x` · `alt-w` | hide/show Claude · "fix this error" · gw in a popup |
| `alt-s` | theme with a preview, `enter` remembers it |
| `space P` · `space t A` | code screenshot to the clipboard · background tests on/off |

Every key is in the [Neovim cheat sheet](nvim.md) (`space h` in nvim), how it's built — [nvim/README.md](../nvim/README.md).
