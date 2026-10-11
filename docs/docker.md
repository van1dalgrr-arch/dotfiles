# Containers from the terminal

🇷🇺 [Русская версия](docker.ru.md) · [all docs](README.md)

A cheatsheet: `orbstack guide` opens the Russian version right in the terminal. Docker runs on OrbStack —
any `docker` command starts it if it's off.

The easiest way is **`orbstack`**: a live dashboard where everything below is one key, and every action
shows the docker command behind it. The keys are in the [guide](guide.md#5-docker-and-kubernetes).
This document is about what happens under the hood and how to do the same by hand.

## In two words

- **An image** — a template: `postgres:17`, `redis:7`. Downloaded once.
- **A container** — a running copy of an image. You can run as many as you like from one image.
- **A volume** — a folder that outlives the container. Without one, a database's data is gone with the container.

## Run a container

```bash
docker run -d --name pg -p 5432:5432 -e POSTGRES_PASSWORD=postgres -v pgdata:/var/lib/postgresql/data postgres:17
```

| Flag | What it means |
|---|---|
| `-d` | in the background: the terminal stays free |
| `--name pg` | a name to refer to it later: `docker logs pg` |
| `-p 5432:5432` | port **on the Mac** : port **in the container** — `localhost:5432` reaches the container |
| `-e KEY=value` | an environment variable (passwords, settings) |
| `-v pgdata:/var/…` | the `pgdata` volume mounted into the container's folder — the data survives |
| `--rm` | delete the container as soon as it stops (for one-off runs) |
| `-it` | interactive, with a terminal: `docker run --rm -it alpine sh` |

The easiest is `orbstack run`: templates for postgres, redis, nginx, mongo, mysql, rabbitmq. It shows
the ready `docker run` command, and you can edit it before it runs.

## Look

```bash
docker ps              # what's running                · orbstack — the table on the main screen
docker inspect pg      # everything about it (JSON)    · orbstack: key i — the same, readable
docker ps -a           # everything, stopped ones too
docker logs -f pg      # the log, live (ctrl+c to quit) · orbstack logs
docker stats           # CPU, memory, network, live     · orbstack top
docker events          # what starts and what crashes   · orbstack events
```

## Manage

```bash
docker exec -it pg sh  # get inside                     · orbstack sh
docker restart pg      # restart                        · orbstack restart
docker stop pg         # stop (the data stays)          · orbstack stop
docker start pg        # start again                    · orbstack start
docker rm -f pg        # delete the container (the volume stays) · orbstack rm
```

## Several services at once — compose

A `compose.yaml` file in the project:

```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: postgres
    ports: ["5432:5432"]
    volumes: [pgdata:/var/lib/postgresql/data]
volumes:
  pgdata:
```

```bash
docker compose up -d     # bring everything up         · orbstack up
docker compose logs -f   # logs of every service
docker compose down      # stop and remove the containers (volumes stay)  · orbstack down
```

`up` (without orbstack) starts only the dependencies from compose and runs the Go app with `.env`.

## Live rebuild — no more typing build

```bash
docker compose watch     # save the code — the image rebuilds, the container restarts · orbstack watch
```

Docker watches the project files. For that, a service with `build:` in compose needs a block
(`orbstack watch` offers to add it):

```yaml
  app:
    build: .
    develop:
      watch:
        - action: rebuild          # rebuild the image and restart the container
          path: .                  # the folder to watch
          ignore: [.git/, tmp/, "*_test.go", "*.md"]
```

For Go, `rebuild` is the right action: the code is compiled, so files can't simply be synced in.
To make a rebuild take seconds rather than starting from scratch, give `go build` a cache in the Dockerfile:

```dockerfile
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 go build -o /bin/app ./cmd/api
```

Without Docker, `air` does the same (`up` runs the app through it): the database in a container, Go on the Mac.

## Clean up

```bash
docker system df         # how much images, containers and volumes take
docker image prune -f    # dangling images                · orbstack clean
docker volume ls         # volumes: delete only deliberately — that's where the data is
```

## Memory on 8 GB

OrbStack takes memory as needed. Done for the day — `orbstack off`: the engine stops and the memory
goes back to the system. The next `docker` command starts it again (~4 s).
