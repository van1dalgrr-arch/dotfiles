package main

import (
	"errors"
	"strings"
)

// Template is a ready-made `docker run` for a common dev dependency.
type Template struct {
	Name   string
	Image  string
	Ports  []string
	Env    []string
	Volume string
	About  string
}

var templates = []Template{
	{"postgres", "postgres:17", []string{"5432:5432"}, []string{"POSTGRES_PASSWORD=postgres"}, "pgdata:/var/lib/postgresql/data", "PostgreSQL на localhost:5432, пользователь postgres / postgres. Данные — в томе pgdata, переживут удаление контейнера."},
	{"redis", "redis:7", []string{"6379:6379"}, nil, "", "Redis на localhost:6379. Данные в памяти: пропадут вместе с контейнером."},
	{"nginx", "nginx:alpine", []string{"8081:80"}, nil, "", "nginx со стартовой страницей на localhost:8081."},
	{"mongo", "mongo:8", []string{"27017:27017"}, nil, "mongodata:/data/db", "MongoDB на localhost:27017, без пароля. Данные — в томе mongodata."},
	{"mysql", "mysql:8", []string{"3306:3306"}, []string{"MYSQL_ROOT_PASSWORD=root"}, "mysqldata:/var/lib/mysql", "MySQL на localhost:3306, пользователь root / root. Данные — в томе mysqldata."},
	{"rabbitmq", "rabbitmq:4-management", []string{"5672:5672", "15672:15672"}, nil, "", "RabbitMQ на localhost:5672, панель — localhost:15672 (guest / guest)."},
}

func findTemplate(name string) (Template, bool) {
	for _, t := range templates {
		if t.Name == name {
			return t, true
		}
	}
	return Template{}, false
}

// Command is the full `docker run` line, shown to the user before it runs.
func (t Template) Command() string {
	parts := []string{"docker", "run", "-d", "--name", t.Name}
	for _, p := range t.Ports {
		parts = append(parts, "-p", p)
	}
	for _, e := range t.Env {
		parts = append(parts, "-e", e)
	}
	if t.Volume != "" {
		parts = append(parts, "-v", t.Volume)
	}
	parts = append(parts, "--restart", "unless-stopped", t.Image)
	return strings.Join(parts, " ")
}

// splitArgs splits a command line the way a shell would for simple cases:
// whitespace separates words, single and double quotes group them.
func splitArgs(s string) ([]string, error) {
	var args []string
	var cur strings.Builder
	var quote rune
	inWord := false
	for _, r := range s {
		switch {
		case quote != 0:
			if r == quote {
				quote = 0
			} else {
				cur.WriteRune(r)
			}
		case r == '\'' || r == '"':
			quote, inWord = r, true
		case r == ' ' || r == '\t':
			if inWord {
				args = append(args, cur.String())
				cur.Reset()
				inWord = false
			}
		default:
			cur.WriteRune(r)
			inWord = true
		}
	}
	if quote != 0 {
		return nil, errors.New("незакрытая кавычка")
	}
	if inWord {
		args = append(args, cur.String())
	}
	return args, nil
}

// dockerArgs validates an edited command: it must still be a docker command.
func dockerArgs(line string) ([]string, error) {
	args, err := splitArgs(strings.TrimSpace(line))
	if err != nil {
		return nil, err
	}
	if len(args) < 2 || args[0] != "docker" {
		return nil, errors.New("команда должна начинаться с docker")
	}
	return args[1:], nil
}
