# Neovim cheat sheet

🇷🇺 [Русская версия](nvim.ru.md) · [all docs](README.md) · [nvim/README](../nvim/README.md)

Inside nvim the Russian version of this page opens with `space h` (and `h` on the start screen).
Press `space` and wait half a second for a menu of every action. `space s k` searches every key.
The Russian layout understands every command: `вв` = `dd`, `о`/`л` = `j`/`k`.

**Learn as you go:** grey marks in the line show where `w` `b` `e` `$` `{` `}` jump (`space u P` turns them off),
and a coach hints at something shorter when you press `jjjjj` (`space u H` turns it off, `space u R` — your most frequent habits). Nothing is blocked.

**Notation:** `space` is the leader, `ctrl-x` is with Ctrl, `S-F6` is Shift+F6 (on the HyperX: `Fn`+`Shift`+`6`).

---

## 1. How to think in vim

Vim is a language. **A command is a verb plus where**, like a phrase: `d` (delete) + `w` (to the next word) = `dw`.
A number in front repeats: `3dd` is three lines. `.` repeats the last change — **the most important key in vim**.

| Mode | Enter with | For |
|---|---|---|
| **normal** | `esc` | moving and commanding — 80% of the time |
| **insert** | `i` `a` `o` … | typing text |
| **visual** | `v` (characters) · `V` (lines) · `ctrl-v` (column) | select a piece and act on it |
| **command** | `:` | `:w`, `:q`, `:%s/…`, any command |

## 2. Moving

| Keys | Where |
|---|---|
| `h` `j` `k` `l` | ← ↓ ↑ → |
| `w` · `b` · `e` | start of the next word · start of the previous one · end of the word |
| `W` · `B` | the same, but a "word" is everything up to a space (`foo.Bar(x)` is one) |
| `0` · `^` · `$` | line start · first character · line end |
| `gg` · `G` · `42G` | file start · end · line 42 |
| `{` · `}` | paragraph (code block) up / down |
| `ctrl-d` · `ctrl-u` | half a screen down / up |
| `zz` · `zt` · `zb` | scroll so the cursor line is in the middle / at the top / at the bottom |
| `f(` · `F(` · `t,` · `T,` | jump **onto** `(` forward / back · **up to** `,` forward / back; `;` `,` repeat |
| `%` | to the matching bracket |
| `s` + 2 letters | **flash**: jump anywhere on screen — type 2 letters, then the label |
| `S` | flash by syntax: select an expression / block / function with one label |
| `ctrl-o` · `ctrl-i` | **back / forward through jumps** (like ⌘[ ⌘] in GoLand) |
| `]f` `[f` · `]c` `[c` | next / previous function · type (class) |
| `]d` `[d` · `]e` `[e` · `F2` `S-F2` | any problem · error · error (like F2 in GoLand) |
| `]h` `[h` | next / previous changed hunk (git) |
| `]]` `[[` | next / previous use of the word under the cursor |
| `ma` · `'a` | set mark `a` · go back to it (capital `mA` works across files) |

## 3. Editing

**Verbs** (they wait for "where"): `d` delete · `c` delete and type · `y` copy · `>` `<` indent ·
`=` re-indent · `gu` `gU` lower / upper case · `gc` comment.
A doubled verb acts on the line: `dd` `cc` `yy` `>>` `gcc`.

**Objects** (`i` — inside, `a` — with the borders):

| Object | What | Example |
|---|---|---|
| `iw` · `aw` | word | `ciw` — replace the word under the cursor |
| `i"` · `i'` · `` i` `` | quoted string | `ci"` — rewrite the string, `yi"` — copy it |
| `i(` · `i{` · `i[` | inside brackets | `di(` — clear the arguments, `ci{` — rewrite the body |
| `if` · `af` | **function** (body / whole) | `daf` — delete the function, `vif` — select the body, `yaf` — copy |
| `ic` · `ac` | **type** (struct, interface) | `yac` — copy the whole type |
| `ia` · `aa` | **argument** | `cia` — replace the argument, `daa` — delete it with the comma |
| `io` · `ao` | block, loop, condition | `dao` — remove the whole `if` |
| `it` · `ip` | tag (HTML) · paragraph | `yip` — copy a block of code |
| `iq` · `ib` | any quotes · any brackets nearby | `ciq` — `"` or `` ` ``, doesn't matter |

Read them aloud: `ci"` — "change inside quotes", `daf` — "delete a function". Your fingers take it from there.

| Keys | What |
|---|---|
| `i` · `a` · `I` · `A` | type before the cursor · after · at line start · at line end |
| `o` · `O` | new line below / above |
| `x` · `r` + letter · `~` | delete a character · replace a character · toggle case |
| `u` · `ctrl-r` | undo · redo |
| `.` | **repeat the last change** (`ciw` new word → `n` → `.` → `n` → `.`) |
| `p` · `P` | paste after / before the cursor |
| `J` | join the next line onto this one |
| `ctrl-a` · `ctrl-x` | number under the cursor +1 / −1 (`10 ctrl-a` is +10) |
| `gcc` · `gc` + object | comment a line · `gcip` — a block |
| `V` … `J` / `K` | move the selected lines down / up |
| `V` … `>` / `<` | shift the selection (`.` once more) |

**Surround:** `gsa` + object + character wraps (`gsaiw"` — the word in quotes, `gsaiw)` — in brackets),
`gsd"` removes the quotes, `gsr"`` ` swaps `"` for `` ` ``, `gsr)]` swaps round brackets for square ones.

**`ctrl-a` / `ctrl-x` beyond numbers:** `true`↔`false`, `&&`↔`||`, and in Go also `:=`↔`=`, `==`↔`!=`, `var`↔`const`,
`t.Error`↔`t.Fatal`, `slog.Debug`→`Info`→`Warn`, `Println`→`Printf`, `GET`→`POST`…, `StatusOK`→`StatusCreated`→…

**Yank history:** `space p` lists everything you copied; after `p`, `[y` / `]y` cycle what got pasted.

**In insert mode:** `ctrl-w` erases a word, `ctrl-u` — to line start, `ctrl-r "` pastes the yank, `ctrl-k` shows the function's parameters.

## 4. Visual mode

| Keys | What |
|---|---|
| `v` · `V` · `ctrl-v` | characters · lines · **column** |
| `viw` · `vi(` · `vaf` | select an object (any from the table above) |
| `gv` | reselect the last selection |
| `o` | jump to the other end of the selection |
| `ctrl-v` … `I` text `esc` | **type at the start of every selected line** (`A` — at the end) |

## 5. Search and replace

| Keys | What |
|---|---|
| `/text` · `?text` → `n` / `N` | find forward / back, next / previous |
| `*` · `#` | the word under the cursor forward / back |
| `:%s/old/new/g` | replace in the whole file (`gc` at the end asks every time) |
| `:s/old/new/g` (after `V`) | replace in the selection |
| `space s r` | **replace across the project** with a preview (grug-far) |
| `space /` · `space s w` | text across the project · the word under the cursor |
| `space s s` · `space s S` | file symbols · project symbols (like ⌘F12 / ⌘⌥O) |
| `esc` | clear the search highlight |

## 6. Registers and macros

| Keys | What |
|---|---|
| `"ayy` · `"ap` | copy into register `a` · paste from it (26 clipboards) |
| `y` / `p` | use the macOS clipboard — ⌘V in another app pastes it |
| `space s "` | every register in a list |
| `qa` … `q` | **record a macro** into `a`: every key until the second `q` |
| `@a` · `@@` · `20@a` | play it · again · 20 times |

Example: struct fields into `json:"…"` by hand — `qa` … edit one line … `j0q`, then `30@a`. (Tags have `space G j`, but macros do anything.)

## 7. Windows, buffers, tabs

| Keys | What |
|---|---|
| `space -` · `space \|` | split down / right |
| `ctrl-h` `ctrl-j` `ctrl-k` `ctrl-l` | go to the window left / below / above / right |
| `ctrl-↑↓←→` | window size (unless macOS took the arrows for Mission Control) |
| `space w d` · `space w m` | close the window · zoom it and back |
| `H` · `L` | previous / next open file (the tabs on top) |
| `space ,` · `space b d` · `space b o` | open files · close this file · close all others |
| `space space` · `space f r` | find a file (like ⇧⇧) · recent files (like ⌘E) |
| `za` · `zR` · `zM` | fold / unfold a block · unfold everything · fold everything |
| `space f y` · `space f Y` | **yazi** at the current file · at the project root |
| in the error / search list (`:copen`) | edit lines as text, `:w` writes the edits to the files |

---

## 8. GoLand → nvim

| GoLand | nvim | What |
|---|---|---|
| ⇧⇧ Search Everywhere | `space space` · `space /` · `space s S` | file · text · symbol |
| ⌘E Recent Files | `space f r` · `space ,` | recent · open |
| ⌘B Go to Declaration | `gd` | definition |
| ⌘⌥B Implementations | `gI` | interface implementations |
| ⌥F7 Find Usages | `gr` | usages |
| ⇧⌘I Quick Definition | `gpd` · `gpr` · `gpi` · `gpt` | **peek in a popup** without leaving: definition · usages · implementations · type |
| ⌃⌥H Call Hierarchy | `space c h` · `space c H` | who calls the function · what it calls |
| ⌘F12 Structure | `space c s` | the Structure window: the file's types and methods |
| ↑↓ "implements" icons | automatic | `реализует: io.Reader` in grey next to a type, `реализуют: …` next to an interface |
| breadcrumbs | on top · `space ;` | `package › Type › method`; click or `space ;` to go to a sibling symbol |
| ⌥Enter Show Context Actions | `space c a` | every fix and refactoring **with a diff preview** before it applies |
| ⇧F6 Rename | `S-F6` · `space c r` | rename everywhere, live preview |
| ⌘⌥M Extract Method / ⌘⌥V Variable | `space c x` (on a `V` selection) | extract a function / variable / constant |
| ⌘⌥N Inline | `space c i` | inline a variable / call |
| Refactor This | `space c w` | fill struct, fill switch, if↔else, parameters, split lines |
| ⌘N Generate → Implement Methods | `space G i` (cursor on the type) | implement an interface: `io.Reader`, `http.Handler`… |
| ⌘N → Test for function | `space G f` · `space G F` | a table test for the function · for every function in the file |
| Add struct tags | `space G j` · `G y` · `G d` · `G t` · `G r` | json · yaml · db · custom · remove |
| Live Template `err` | `space G e` · snippets `ife` · `errw` | `if err != nil { return … }` |
| Postfix `.if` `.for` `.nn` | type `x.` → completions with `!` | `items.range!`, `err.ifnotnil!`, `m.keys!`, `s.sort!`, `x.print!` — from gopls |
| ⌘⌥L Reformat | on write | goimports + gofumpt, imports by themselves |
| Inspections | automatic | gopls + staticcheck + golangci-lint, errors as a badge right of the line |
| F2 Next Error | `F2` · `S-F2` | next / previous error |
| ▶ in the gutter | `space r x` · `space r X` | ▶ left of `func main` and tests: run the function at the cursor · under the debugger |
| ⌃⇧R Run test | `space t r` · `space t t` · `space t s` | test at the cursor · file · test panel |
| Run with Coverage | `space G v` · `G V` · `G s` | run the tests and paint the lines · hide · percentages per file |
| Debug | `F9` · `F8` `F7` `S-F8` · `ctrl-F8` | start/continue · step / into / out · breakpoint |
| Attach to Process (remote) | `space d c` → "Подключиться к dlv в Docker" | dlv in a container on :2345 (below) |
| Endpoints | `space r e` · `alt-a` | Gin routes: enter goes to the handler, ctrl-r sends a request |
| HTTP Client | `space r h` · `alt-p` | `api.http`, enter sends |
| Database | `space D` · `alt-d` | tables and queries |
| Run Configurations | `space r r` · `alt-t` | tasks: `up`, air, tests, lint, compose, **benchmarks + pprof** |
| Local History | `space U` | the tree of every edit to the file, even without git and after a restart |
| Git → Annotate | `space u B` · `space g b` | author and date on each line · the line's history |
| Git → Merge Conflicts | `space g v` | three-way merge: ours · theirs · result |
| Git → Show History | `space g H` · `space g R` | file history · repository history |
| Compare with Branch | `space g m` | the branch against `main`, like the future PR |
| Commit / Push | `space g g` · `alt-g` | lazygit |
| Multiple Carets ⌃G / ⌥-click | `ctrl-n` · `alt`+click · `space m …` | multiple cursors (below) |
| AI Assistant | `space a c` | **Claude Code** in a panel on the right (below) |
| Services → Kubernetes | `space k` | pods, logs, describe, port-forward |

## 9. Go: what's new

**Tests in the background.** Save a Go file and a second later `go test` runs for its package. The status line shows
`󰙨 ✓ 42` (all passed), `󰙨 ✗ 1` (failed) or `✗ сборка` (doesn't compile). The failed check is marked as an error
on its own line in the `_test.go`: `● TestAdd: got -1, want 3`. Fix it and the mark goes away.
Coverage refreshes too: when it's shown (`space G V`), the gutter bars repaint by themselves.
`space t A` turns it off / on.

**▶ next to functions.** Left of `func main()`, `func TestX`, `BenchmarkX`, `FuzzX`, `ExampleX` there's a ▶.
Cursor anywhere inside the function → `space r x`. main runs `go run .` in a terminal at the bottom; a test goes through
neotest (✓/✗ appears next to it); a benchmark runs `go test -bench` with `-benchmem`; fuzzing runs 30 seconds.
`space r X` does the same under the debugger. In a `_test.go` outside any function it runs the whole file.

**Generation — the `space G` group** (Go files only):

| Keys | What |
|---|---|
| `space G j` / `G y` / `G d` | `json` / `yaml` / `db` tags on the struct under the cursor |
| `space G t` | custom tags: `json,validate` |
| `space G r` | remove tags |
| `space G i` | implement an interface — cursor on the type name, type `io.Reader` |
| `space G e` | `if err != nil { return … }` with the right zero values |
| `space G c` | a doc comment for the function / type |
| `space G f` · `space G F` | a test for the function · for the whole file (gotests) |
| `space G m` · `space G g` | `go mod tidy` · `go get a package` |
| `space G p` | **JSON → Go struct**: paste JSON (an API response) and get a struct with tags |
| `space G o` | compiler optimization details in the code: what escapes to the heap, what gets inlined (again to hide) |
| `space G v` · `G V` · `G s` | coverage: run and paint · hide · summary |

**Snippets** — type one and pick it from the completions (`tab` goes to the next field):
`ife` `errw` `tt` (table test) `bench` `gh` (Gin handler) `gbind` (ShouldBindJSON + 400) `hf` (net/http)
`ctxf` `slog` `wg` (WaitGroup.Go) `new` (constructor). Your own go in `nvim/snippets/go.json`.

**Code lenses:** in `go.mod` — "upgrade dependency", `tidy`, `govulncheck`; above `//go:generate` — run it.
`space c c` runs the lens under the cursor.

**Type hints** in grey inside the code (`x := …` → its type) — `space u h` toggles them.
**The function header** sticks to the top while you scroll a long function — `space u t` turns it off.

**Debugging in Docker:** run
`dlv debug ./cmd/api --headless --listen=:2345 --accept-multiclient --api-version=2` in the container, publish port 2345,
then in nvim `space d c` → "Подключиться к dlv в Docker". The code in the container must live in `/app`
(otherwise change `substitutePath` in `nvim/lua/plugins/goland.lua`). Breakpoints work as usual.

**SQL inside strings** (`` `SELECT …` ``, `"INSERT …"`) is highlighted as SQL.

**Go scratch:** `space r g` opens an empty `main.go` in its own module, `space r x` runs it. Like the Go Playground.

**Structural replace:** `space s A` searches and replaces by code structure (ast-grep), like Structural Search in GoLand.
Find `errors.New(fmt.Sprintf($$$A))` → replace with `fmt.Errorf($$$A)` across the project, with a preview.

**Breakpoints persist** across nvim restarts.

**Benchmarks + profile:** `space r r` → "бенчмарки пакета + pprof" opens a browser with a flame graph.

## 10. Git

| Keys | What |
|---|---|
| `space g g` | lazygit — commits, branches, push, rebase |
| `space g v` · `space g V` | **diffview**: every change (and three-way conflicts) · close (`q` too) |
| `space g m` | the branch against `main`, like the future PR's diff |
| `space g H` · `space g R` | file history · repository history, commit by commit with diffs |
| `space u B` | author, date and commit message in grey on the current line |
| `space g b` | the line's history: who changed it, `enter` shows the whole commit |
| `]h` `[h` · `space g h s` · `space g h r` | to a changed hunk · stage the hunk · reset the hunk |
| `space g h p` | show what the hunk was before the edit |
| `space g w` · `alt-w` | **gw** — GitHub in a popup: PR pages with diffs and reviews, Actions, Inbox, search, profile; `alt-w` again hides it |
| `space U` | the file's edit tree (Local History): move through the tree and the file shows that version; leave the tree and it stays |

## 11. Multiple cursors

| Keys | What |
|---|---|
| `ctrl-n` | a cursor on the next same word (like ⌃G); in visual mode, on the next same text |
| `space m a` | cursors on every match |
| `space m s` · `space m N` | skip a match · back |
| `space m j` · `space m k` | a cursor one line below / above |
| `alt` + click | add / remove a cursor with the mouse |
| `←` `→` · `space x` | while there are several: switch between them · remove the current one |
| `esc` | remove every cursor |
| `space m l` | align the cursors into a column |

Then plain vim commands, on every cursor at once: `ciw`, `A;`, `dd`, `.`.

## 12. Claude Code inside nvim

| Keys | What |
|---|---|
| `space a c` | show / hide Claude on the right |
| `space a f` | focus the Claude window |
| `space a b` | add the current file to the context |
| `V` … `space a s` | send the selected code |
| `space a a` · `space a d` | **accept / reject** an edit — Claude shows it as a diff right in nvim |
| `space a r` · `space a C` | resume a past session (pick one) · the last one |
| `alt-c` | **hide / show Claude from anywhere** — even from inside the Claude panel |
| `space a x` | **"fix it"**: the error under the cursor goes to Claude with its place in the file |
| `space a R` · `space a X` | **branch review**: Claude reads the diff against main (and uncommitted work), findings land on their lines like linter errors and in `:copen` · clear them |
| `:ClaudeCodeClose` | close Claude completely |

Claude sees which file is open and what's selected. If Claude runs in a separate Ghostty window, type `/ide` there and it connects to this nvim.

## 13. Look

- **The theme is tokyonight night**, transparent, as before.
- **`alt-s` switches the theme** (or `space u C`): a list on the right with your code under it. Moving through the list
  repaints the whole editor; `enter` applies and **remembers** it (nvim starts with it from then on), `esc` puts it back.
  Type to filter: `dragon`, `dawn`, `fox`. 31 themes: tokyonight, kanagawa, rose-pine, nightfox/carbonfox,
  cyberdream, vesper, gruvbox-material, catppuccin — and light ones: `tokyonight-day`, `rose-pine-dawn`, `kanagawa-lotus`, `dayfox`.
- **`rose-pine` uses the terminal colors:** the dotfiles theme palette (the same as Ghostty, starship, lazygit);
  `theme kanagawa` repaints it too, macOS light mode gets the light Dev Day.
- **Transparent background** like Ghostty; borders on every popup.
- **Code screenshot:** select lines → `space P` (no selection — the function at the cursor). A PNG in a window with a shadow,
  in the current theme, with line numbers — straight to the clipboard (⌘V in Telegram) and into `~/Pictures/code`.
- **Tip of the day** on the start screen — a random line from this cheat sheet, new on every launch.
- **`.env` under asterisks:** passwords and tokens are hidden, only the cursor line is open; `space u e` shows everything.
- `space u w` wrap · `space u l` line numbers · `space u d` diagnostics · `space u z` zen mode.

## 14. When something breaks

| Command | What |
|---|---|
| `:checkhealth` | checks everything: LSP, plugins, tools |
| `:Lazy` | plugins: update `U`, log `L`, startup profile `P` |
| `:Mason` | language servers and tools |
| `:LspInfo` · `space c l` | which LSP is attached to the file |
| `:GoInstallDeps` | reinstall gomodifytags, impl, gotests, iferr |
| `:messages` · `space n` | recent messages and errors |
| `:Tutor` | vim's built-in 30-minute lesson |
