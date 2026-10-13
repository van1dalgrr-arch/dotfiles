# pgcli

🇷🇺 [Русская версия](README.ru.md)

Config for [pgcli](https://www.pgcli.com), the Postgres client with autocompletion (`db` opens it for the current project).

| File | What |
|---|---|
| `config` | pager, table style, colors |

**Installed by `install.sh` as symlinks:**

- `config` → `~/.config/pgcli/config`

## Using it

`db` in a project folder finds the database itself: `DATABASE_URL` from the environment or `.env`, otherwise it builds
the address from `DB_PASSWORD` and the folder name (`postgres://postgres:…@localhost:5432/<folder>`). The password is hidden in the output.
Or explicitly: `db postgres://user:pass@host/db`. Multi-line queries are on — run with `;` and `enter`.
`\dt` — tables, `\d name` — structure, `\q` — quit.

[← dotfiles](../README.md)
