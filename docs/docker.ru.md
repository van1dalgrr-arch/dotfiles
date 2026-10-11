# Контейнеры из терминала

Шпаргалка: `orbstack guide` открывает её прямо в терминале. Docker работает на OrbStack —
любая команда `docker` сама его запустит, если он выключен.

## Два слова

- **Образ** (image) — шаблон: `postgres:17`, `redis:7`. Скачивается один раз.
- **Контейнер** — запущенная копия образа. Их можно запустить сколько угодно из одного образа.
- **Том** (volume) — папка, которая переживает удаление контейнера. Без тома данные базы пропадут вместе с ним.

## Запустить контейнер

```bash
docker run -d --name pg -p 5432:5432 -e POSTGRES_PASSWORD=postgres -v pgdata:/var/lib/postgresql/data postgres:17
```

| Флаг | Что значит |
|---|---|
| `-d` | в фоне: терминал свободен |
| `--name pg` | имя, по нему потом обращаешься: `docker logs pg` |
| `-p 5432:5432` | порт **на Mac** : порт **в контейнере** — `localhost:5432` попадёт в контейнер |
| `-e KEY=value` | переменная окружения (пароли, настройки) |
| `-v pgdata:/var/…` | том `pgdata` смонтирован в папку контейнера — данные сохранятся |
| `--rm` | удалить контейнер сразу после остановки (для разовых запусков) |
| `-it` | интерактивно, с терминалом: `docker run --rm -it alpine sh` |

Проще всего — `orbstack run`: шаблоны postgres, redis, nginx, mongo, mysql, rabbitmq. Он покажет
готовую команду `docker run`, её можно поправить перед запуском.

## Посмотреть

```bash
docker ps              # что работает          · orbstack — то же на главном экране
docker ps -a           # всё, и остановленное
docker logs -f pg      # лог вживую (ctrl+c — выйти)  · orbstack logs
docker stats           # CPU, память, сеть вживую     · orbstack top
docker events          # что запускается и падает     · orbstack events
```

## Управлять

```bash
docker exec -it pg sh  # зайти внутрь                  · orbstack sh
docker restart pg      # перезапустить                 · orbstack restart
docker stop pg         # остановить (данные на месте)  · orbstack stop
docker start pg        # запустить снова               · orbstack start
docker rm -f pg        # удалить контейнер (том останется) · orbstack rm
```

## Несколько сервисов сразу — compose

В проекте файл `compose.yaml`:

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
docker compose up -d     # поднять всё              · orbstack up
docker compose logs -f   # логи всех сервисов
docker compose down      # остановить и убрать контейнеры (тома останутся)  · orbstack down
```

`up` (без orbstack) поднимает только зависимости из compose и запускает Go-приложение с `.env`.

## Живая сборка — без постоянного build

```bash
docker compose watch     # сохранил код — образ пересобрался, контейнер перезапустился · orbstack watch
```

Docker следит за файлами проекта. Для этого у сервиса с `build:` в compose нужен блок
(`orbstack watch` предложит добавить его сам):

```yaml
  app:
    build: .
    develop:
      watch:
        - action: rebuild          # пересобрать образ и перезапустить контейнер
          path: .                  # за какой папкой следить
          ignore: [.git/, tmp/, "*_test.go", "*.md"]
```

Для Go `rebuild` — правильный режим: код компилируется, просто подложить файлы нельзя.
Чтобы пересборка шла секунды, а не с нуля, дай `go build` в Dockerfile кэш:

```dockerfile
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 go build -o /bin/app ./cmd/api
```

Без Docker то же делает `air` (`up` запускает приложение через него): база в контейнере, Go — на Mac.

## Уборка

```bash
docker system df         # сколько занимают образы, контейнеры, тома
docker image prune -f    # висячие образы                · orbstack clean
docker volume ls         # тома: удалять только осознанно — там данные
```

## Память на 8 ГБ

OrbStack берёт память по мере надобности. Закончил работу — `orbstack off`: движок остановится,
память вернётся системе. Следующая команда `docker` поднимет его снова (~4 с).
