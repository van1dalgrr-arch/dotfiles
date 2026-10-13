# pgcli

🇬🇧 [English version](README.md)

Конфиг [pgcli](https://www.pgcli.com) — клиент Postgres с автодополнением (`db` открывает его для текущего проекта).

| Файл | Что это |
|---|---|
| `config` | пейджер, вид таблиц, цвета |

**`install.sh` ставит симлинками:**

- `config` → `~/.config/pgcli/config`

## Как пользоваться

`db` в папке проекта сам находит базу: `DATABASE_URL` из окружения или `.env`, иначе собирает адрес из
`DB_PASSWORD` и имени папки (`postgres://postgres:…@localhost:5432/<папка>`). Пароль в выводе скрыт.
Можно и явно: `db postgres://user:pass@host/db`. Многострочные запросы включены — выполнить: `;` и `enter`.
`\dt` — таблицы, `\d имя` — структура, `\q` — выйти.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
