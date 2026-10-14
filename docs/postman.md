# Postman in nvim — in 5 steps

🇷🇺 [Русская версия](postman.ru.md) · [all docs](README.md)

**What it is:** send a request to your API and see the answer without leaving the editor.
Requests live in a plain text file, `api.http`. Nothing to install.

---

## Step 1. Start your API

In the terminal, in the project folder:

```bash
up            # or: go run ./cmd/api
curl localhost:8080/health      # an answer should come back, not silence
```

## Step 2. Open the project in nvim

```bash
nvim .
```

## Step 3. Press `space` `r` `h`

Three keys one after another: **space**, then **r**, then **h**.
An `api.http` file appears with **every** request of your API already written. Each piece between `###` is **one request**:

```http
@host = http://localhost:8080

### POST /auth/login → h.Login
# @name login
POST {{host}}/auth/login
Content-Type: application/json

{}

### GET /api/me → h.Me
GET {{host}}/api/me
Authorization: Bearer {{login.response.body.$.access_token}}
```

## Step 4. Put the cursor on a request and press `Enter`

The answer opens on the right. Its first line is **method, address → status · time**.
`200` — fine, `400` — you sent something wrong, `401` — log in first, `404` — no such address, `500` — the server crashed.
Close the answer with `Esc`.

## Step 5. Change the request and send it again

The body is what comes after the empty line. It was `{}`, write your own:

```http
POST {{host}}/auth/login
Content-Type: application/json

{"email": "me@example.com", "password": "secret"}
```

`Enter` sends it. The file saves itself.

---

## How login (the token) works

1. Send the **login** request (first in the file, it has the `# @name login` line).
2. That's it. The other requests take the token from its answer through
   `Authorization: Bearer {{login.response.body.$.access_token}}`.
   If the token field is called differently (say `token`), change the end: `$.token`.

## Every key

| Keys | What |
|---|---|
| `space r h` | create `api.http` (if it exists, just open it) |
| `Enter` | send the request under the cursor |
| `space R r` | send the last request again |
| `space R c` | copy the request as a `curl` command |
| `space R n` · `space R p` | next · previous request |
| `Esc` | close the answer |

## If something's off

| You see | Do this |
|---|---|
| `→ нет ответа` (no answer) | the API isn't running — step 1. It runs but `curl localhost:8080/health` hangs — the VPN (Happ) grabs localhost: switch it off TUN mode or exclude localhost |
| `→ 401` | send login first, then this request |
| `→ 404` | wrong address — compare with `space r e` (every endpoint) |
| wrong port | first line of the file: `@host = http://localhost:YOUR_PORT` |
| `Enter` does nothing | the cursor isn't on a request — put it on the `GET` / `POST` line |
| want a fresh file | delete `api.http` and `space r h` again |

Also: `space r e` lists every endpoint, `ctrl-r` there sends a request right away.
How it works inside — [nvim/README.md](../nvim/README.md#postman-in-a-file).
