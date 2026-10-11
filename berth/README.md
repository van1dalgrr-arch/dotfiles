# berth

🇷🇺 [Русская версия](README.ru.md)

The `orbstack` command: containers in the terminal, written in Go with [Bubble Tea](https://github.com/charmbracelet/bubbletea).
`install.sh` and `update` build it into `~/go/bin/berth`; `.zshrc` aliases `orbstack` to it.

```bash
orbstack                 # live dashboard
orbstack run postgres    # start from a template: shows the docker run command first
orbstack watch           # live rebuild for the compose project here
orbstack help            # everything else
```

The dashboard is one live screen: a table of containers with CPU and memory, the selected container's log,
and an event feed (start, stop, crash, out of memory). Everything is on keys; `enter` lists the actions for
a container, each with an explanation and the docker command behind it. `?` shows all keys.

| Key | What |
|---|---|
| `↑↓` `j k` · wheel · click | pick a container (click again for actions) |
| `enter` | actions, explained |
| `l` `s` | follow logs · shell inside |
| `r` `x` `d` | restart · stop/start · remove (volumes stay) |
| `i` | inside: image, ports, mounts, networks, env (secrets hidden) |
| `f` | the Dockerfile from the compose project, or the image layers for a prebuilt image |
| `c` | the project's compose file |
| `n` `t` `w` | new from a template · stats · live rebuild |

| File | What |
|---|---|
| `main.go` | subcommands (`orbstack ps`, `logs`, `run`, `watch`…) |
| `ui.go` | the dashboard: model, keys, layout |
| `docker.go` | talks to the docker CLI (follows the current context: OrbStack, Colima, Docker Desktop) |
| `templates.go` | postgres, redis, nginx, mongo, mysql, rabbitmq |
| `inspect.go` | inside a container: inspect summary, its compose file and Dockerfile, image layers |
| `watch.go` | adds a `develop.watch` block to the compose file, comments preserved |
| `style.go` | colors and the gradient logo |
| `berth_test.go` | parsing, templates, compose editing, rendering at several sizes |

```bash
cd berth && go test ./...                               # also part of make check and CI
BERTH_RENDER=/tmp/b.ansi go test -run TestRender .      # snapshot of the dashboard with live data
```

[← dotfiles](../README.md)
