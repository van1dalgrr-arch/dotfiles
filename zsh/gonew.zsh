# gonew myapi [--gh] — новый Go-проект в ~/dev со всем нужным (состав — docs/guide.ru.md); --gh — сразу на GitHub

gonew() {
    local name=$1 gh=0
    [[ $2 == --gh || $1 == --gh ]] && gh=1
    [[ $name == --gh ]] && name=$2
    [[ -z $name ]] && { echo "usage: gonew <name> [--gh]"; return 1; }
    [[ -e $DEV/$name ]] && { echo "уже есть: $DEV/$name"; return 1; }
    mkdir -p $DEV/$name && cd $DEV/$name || return
    local gover=$(go env GOVERSION | sed 's/^go//; s/\.[0-9]*$//')   # 1.27
    mkdir -p cmd/api internal/config internal/handler migrations .github/workflows

    command cat > cmd/api/main.go <<'GO'
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"MODULE/internal/config"
	"MODULE/internal/handler"
)

func main() {
	cfg := config.Load()
	log := slog.New(slog.NewTextHandler(os.Stdout, nil))

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	db, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Error("database", "err", err)
		os.Exit(1)
	}
	defer db.Close()

	r := gin.Default()
	handler.Register(r, db)

	srv := &http.Server{Addr: ":" + cfg.Port, Handler: r, ReadHeaderTimeout: 5 * time.Second}
	go func() {
		log.Info("server started", "addr", srv.Addr)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Error("server", "err", err)
			stop()
		}
	}()

	<-ctx.Done() // Ctrl+C или SIGTERM от Docker — дать запросам доработать
	shutdown, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = srv.Shutdown(shutdown)
	log.Info("server stopped")
}
GO

    command cat > internal/config/config.go <<'GO'
package config

import "os"

// Config — всё, что приложение берёт из окружения (.env локально, environment в compose).
type Config struct {
	Port        string
	DatabaseURL string
}

func Load() Config {
	return Config{
		Port:        env("PORT", "8080"),
		DatabaseURL: env("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/app?sslmode=disable"),
	}
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
GO

    command cat > internal/handler/handler.go <<'GO'
package handler

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// Pinger — всё, что нужно handler-у от базы. *pgxpool.Pool подходит, а в тестах — заглушка.
type Pinger interface {
	Ping(ctx context.Context) error
}

func Register(r *gin.Engine, db Pinger) {
	r.GET("/health", health(db))
}

// health — живо ли приложение и доступна ли база (для Docker/Kubernetes healthcheck).
func health(db Pinger) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
		defer cancel()
		if err := db.Ping(ctx); err != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{"status": "db unavailable"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	}
}
GO

    command cat > internal/handler/handler_test.go <<'GOTEST'
package handler

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

// fakeDB — база-заглушка: Ping возвращает заданную ошибку, Postgres не нужен.
type fakeDB struct{ err error }

func (f fakeDB) Ping(context.Context) error { return f.err }

func TestHealth(t *testing.T) {
	gin.SetMode(gin.TestMode)
	tests := []struct {
		name string
		err  error
		want int
	}{
		{"база доступна", nil, http.StatusOK},
		{"база недоступна", errors.New("connection refused"), http.StatusServiceUnavailable},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := gin.New()
			Register(r, fakeDB{tt.err})
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/health", nil))
			if w.Code != tt.want {
				t.Fatalf("status = %d, want %d", w.Code, tt.want)
			}
		})
	}
}
GOTEST

    sed -i '' "s|MODULE|$name|g" cmd/api/main.go

    # миграции golang-migrate: make migrate-up / migrate-down
    printf -- '-- первая миграция: создать таблицы\n-- CREATE TABLE items (id BIGSERIAL PRIMARY KEY, name TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now());\n' > migrations/000001_init.up.sql
    printf -- '-- откат первой миграции\n-- DROP TABLE IF EXISTS items;\n' > migrations/000001_init.down.sql

    command cat > .github/workflows/ci.yml <<'CIYML'
# CI: на каждый push в main и на каждый pull request (подробно — в logsence/.github/workflows/ci.yml)
name: ci

on:
  push:
    branches: [main]
  pull_request:

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-go@v7
        with:
          go-version-file: go.mod
      - name: gofmt
        run: test -z "$(gofmt -l .)" || { gofmt -l .; exit 1; }
      - run: go vet ./...
      - run: go test -race ./...

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-go@v7
        with:
          go-version-file: go.mod
      - uses: golangci/golangci-lint-action@v9
        with:
          version: v2.14.0

  vuln:
    runs-on: ubuntu-latest
    steps:
      - uses: golang/govulncheck-action@v1
        with:
          go-version-file: go.mod

  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: hadolint/hadolint-action@v3.5.0
        with:
          failure-threshold: warning
      - uses: docker/setup-buildx-action@v4
      - uses: docker/build-push-action@v7
        with:
          context: .
          push: false
          cache-from: type=gha
          cache-to: type=gha,mode=max
CIYML

    command cat > docker-compose.yml <<YML
services:
  postgres:
    image: postgres:18-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: \${DB_PASSWORD:-postgres}
      POSTGRES_DB: app
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d app"]
      interval: 3s
      retries: 10

  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgres://postgres:\${DB_PASSWORD:-postgres}@postgres:5432/app?sslmode=disable
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  pgdata:
YML

    command cat > Dockerfile <<DOCKER
# сборка
FROM golang:$gover-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /app ./cmd/api

# запуск: только бинарник, без shell и пакетов (~15 МБ)
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
DOCKER

    printf 'tmp/\nbin/\n.env\n' > .dockerignore
    printf 'tmp/\nbin/\n.env\n*.test\n*.out\n' > .gitignore
    printf 'PORT=8080\nDB_PASSWORD=postgres\nDATABASE_URL=postgres://postgres:postgres@localhost:5432/app?sslmode=disable\n' > .env.example
    command cp .env.example .env

    command cat > .golangci.yml <<'YML'
version: "2"
linters:
  enable: [errcheck, govet, staticcheck, unused, ineffassign, bodyclose, errorlint, gosec]
YML

    command cat > Makefile <<'MAKE'
.PHONY: help run dev test lint up down build migrate-up migrate-down
DATABASE_URL ?= postgres://postgres:postgres@localhost:5432/app?sslmode=disable

help:  ## эта справка
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[35m%-13s\033[0m %s\n", $$1, $$2}'
run:   ## запустить локально
	go run ./cmd/api
dev:   ## hot reload (air)
	air
test:  ## тесты с детектором гонок
	go test -race -count=1 ./...
lint:  ## golangci-lint
	golangci-lint run ./...
up:    ## всё в Docker: база + приложение
	docker compose up -d --build
down:  ## остановить
	docker compose down
build: ## бинарник в bin/
	CGO_ENABLED=0 go build -o bin/app ./cmd/api
migrate-up:   ## применить миграции
	migrate -path migrations -database "$(DATABASE_URL)" up
migrate-down: ## откатить последнюю
	migrate -path migrations -database "$(DATABASE_URL)" down 1
MAKE

    local owner=$(gh api user -q .login 2>/dev/null)
    {
        print "# $name"
        print
        [[ -n $owner ]] && print "![ci](https://github.com/$owner/$name/actions/workflows/ci.yml/badge.svg)\n"
        print "Go + Gin + Postgres. \`/health\` проверяет и приложение, и базу."
        print
        print '```bash'
        print 'up               # база в Docker + приложение с hot reload'
        print 'make help        # все команды'
        print 'make test        # тесты'
        print 'make migrate-up  # миграции'
        print 'make up          # всё в Docker'
        print 'curl localhost:8080/health'
        print '```'
    } > README.md

    go mod init $name >/dev/null 2>&1 && go get github.com/gin-gonic/gin github.com/jackc/pgx/v5 >/dev/null 2>&1 && go mod tidy >/dev/null 2>&1 || { echo "go mod: ошибка"; return 1; }
    air init >/dev/null 2>&1 && sed -i '' 's|cmd = "go build -o ./tmp/main ."|cmd = "go build -o ./tmp/main ./cmd/api"|' .air.toml
    gofmt -w . && go vet ./... && go test ./... >/dev/null || { echo "шаблон не прошёл проверки — см. вывод выше"; return 1; }
    git init -q && git add -A && git commit -qm "Initial commit: Gin API skeleton" >/dev/null 2>&1
    if (( gh )); then
        gh repo create "$name" --private --source=. --push >/dev/null && print -P "%F{#$T_FOAM}✓%f github.com/$owner/$name (приватный) · CI уже запущен"
    fi
    print -P "%F{#$T_FOAM}✓%f $name готов → %Bup%b и открой localhost:8080/health · %Bmake help%b — все команды"
}
