# ============================================================
#   gonew myapi — новый Go-проект на Gin в ~/dev, сразу «как надо»:
#   cmd/api + internal, конфиг из env, Postgres (pgx), /health с проверкой базы,
#   graceful shutdown, compose, двухэтапный Dockerfile, Makefile, air, golangci-lint.
#   Потом: up — поднять базу и запустить с hot reload.
# ============================================================

gonew() {
    local name=$1
    [[ -z $name ]] && { echo "usage: gonew <name>"; return 1; }
    [[ -e $DEV/$name ]] && { echo "уже есть: $DEV/$name"; return 1; }
    mkdir -p $DEV/$name && cd $DEV/$name || return
    local gover=$(go env GOVERSION | sed 's/^go//; s/\.[0-9]*$//')   # 1.27
    mkdir -p cmd/api internal/config internal/handler

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
	"github.com/jackc/pgx/v5/pgxpool"
)

func Register(r *gin.Engine, db *pgxpool.Pool) {
	r.GET("/health", health(db))
}

// health — живо ли приложение и доступна ли база (для Docker/Kubernetes healthcheck).
func health(db *pgxpool.Pool) gin.HandlerFunc {
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

    sed -i '' "s|MODULE|$name|g" cmd/api/main.go

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
.PHONY: run dev test lint up down build

run:   ## запустить локально
	go run ./cmd/api
dev:   ## hot reload (air)
	air
test:
	go test -race -count=1 ./...
lint:
	golangci-lint run ./...
up:    ## всё в Docker: база + приложение
	docker compose up -d --build
down:
	docker compose down
build:
	CGO_ENABLED=0 go build -o bin/app ./cmd/api
MAKE

    printf '# %s\n\n```bash\nup            # база в Docker + приложение с hot reload\nmake test     # тесты\nmake up       # всё в Docker\ncurl localhost:8080/health\n```\n' "$name" > README.md

    go mod init $name >/dev/null 2>&1 && go get github.com/gin-gonic/gin github.com/jackc/pgx/v5 >/dev/null 2>&1 && go mod tidy >/dev/null 2>&1 || { echo "go mod: ошибка"; return 1; }
    air init >/dev/null 2>&1 && sed -i '' 's|cmd = "go build -o ./tmp/main ."|cmd = "go build -o ./tmp/main ./cmd/api"|' .air.toml
    git init -q && git add -A && git commit -qm "Initial commit: Gin API skeleton" >/dev/null 2>&1
    print -P "%F{#$T_FOAM}✓%f $name готов → %Bup%b и открой localhost:8080/health"
}
