package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/unstablebuild/rune-go-sdk/api/browserapi"
	"github.com/unstablebuild/rune-go-sdk/api/textapi"
	"github.com/unstablebuild/rune-go-sdk/iterator"
)

// notifier — то, что нужно от browserapi.Notifications (в тестах — фейк)
type notifier interface {
	Notify(level browserapi.NotificationLevel, msg string, args ...any) (string, error)
}

type handler struct {
	dot    runner
	notify notifier
}

func (h *handler) HandleCommand(ctx context.Context, c textapi.Command) error {
	switch c.Name {
	case "work":
		return h.report(h.dot.Run(ctx, "", append([]string{"work"}, c.Args...)...))
	case "projectdoctor":
		dir, _ := os.Getwd() // Rune запускает расширение в корне проекта
		if p := c.URI.Path(); p != "" {
			dir = filepath.Dir(p) // файл в фокусе: dot сам поднимется до go.mod
		}
		return h.report(h.dot.Run(ctx, dir, "project", "doctor", dir))
	}
	return fmt.Errorf("неизвестная команда %q", c.Name)
}

// report: итоговая строка dot и все ✗/! — уведомлением; код 1 → ошибка, 2 → неверный вызов
func (h *handler) report(out string, code int, err error) error {
	if err != nil {
		return fmt.Errorf("dot не запустился: %w", err)
	}
	msg := summarize(out)
	switch code {
	case 0:
		_, err = h.notify.Notify(browserapi.LevelSuccess, "%s", msg)
	case 1:
		_, err = h.notify.Notify(browserapi.LevelError, "%s", msg)
	default:
		return fmt.Errorf("%s", strings.TrimSpace(out))
	}
	return err
}

// summarize оставляет из вывода dot главное: ошибки, предупреждения и последнюю строку-итог
func summarize(out string) string {
	var keep []string
	lines := strings.Split(strings.TrimSpace(out), "\n")
	for _, l := range lines {
		t := strings.TrimSpace(l)
		if strings.HasPrefix(t, "✗") || strings.HasPrefix(t, "!") || strings.HasPrefix(t, "◆") {
			keep = append(keep, t)
		}
	}
	if last := strings.TrimSpace(lines[len(lines)-1]); last != "" && (len(keep) == 0 || keep[len(keep)-1] != last) {
		keep = append(keep, last)
	}
	return strings.Join(keep, "\n")
}

// Complete подсказывает имена режимов из ~/dotfiles/work/*.work и off/list
func (h *handler) Complete(_ context.Context, cmd string, args []string) (iterator.Iterator[string], error) {
	if cmd != "work" || len(args) > 1 {
		return iterator.Empty[string](), nil
	}
	prefix := ""
	if len(args) == 1 {
		prefix = args[0]
	}
	var out []string
	for _, m := range append(h.dot.Modes(), "off", "list") {
		if strings.HasPrefix(m, prefix) {
			out = append(out, m)
		}
	}
	return iterator.FromSlice(out), nil
}
