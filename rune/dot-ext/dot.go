package main

import (
	"context"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// runner — запуск bin/dot (в тестах — фейк)
type runner interface {
	Run(ctx context.Context, dir string, args ...string) (out string, code int, err error)
	Modes() []string
}

type dotCLI struct{ root string }

// корень dotfiles: $DOTFILES или ~/dotfiles
func newDot() dotCLI {
	root := os.Getenv("DOTFILES")
	if root == "" {
		home, _ := os.UserHomeDir()
		root = filepath.Join(home, "dotfiles")
	}
	return dotCLI{root: root}
}

func (d dotCLI) Run(ctx context.Context, dir string, args ...string) (string, int, error) {
	cmd := exec.CommandContext(ctx, filepath.Join(d.root, "bin", "dot"), args...)
	cmd.Dir = dir
	cmd.Env = append(os.Environ(), "NO_COLOR=1", "DOTFILES="+d.root)
	out, err := cmd.CombinedOutput()
	var exit *exec.ExitError
	if errors.As(err, &exit) {
		return string(out), exit.ExitCode(), nil // dot отработал, но вернул 1/2 — это не сбой запуска
	}
	return string(out), 0, err
}

func (d dotCLI) Modes() []string {
	files, _ := filepath.Glob(filepath.Join(d.root, "work", "*.work"))
	modes := make([]string, 0, len(files))
	for _, f := range files {
		modes = append(modes, strings.TrimSuffix(filepath.Base(f), ".work"))
	}
	return modes
}
