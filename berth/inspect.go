package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"

	"gopkg.in/yaml.v3"
)

// Внутренности контейнера: сводка docker inspect, его compose-файл и Dockerfile.
// Compose-проект узнаём по меткам, которые compose ставит каждому контейнеру.

const (
	lblFiles   = "com.docker.compose.project.config_files"
	lblDir     = "com.docker.compose.project.working_dir"
	lblService = "com.docker.compose.service"
)

type inspectData struct {
	Name   string `json:"Name"`
	Config struct {
		Image       string            `json:"Image"`
		Env         []string          `json:"Env"`
		Cmd         []string          `json:"Cmd"`
		Entrypoint  []string          `json:"Entrypoint"`
		WorkingDir  string            `json:"WorkingDir"`
		Labels      map[string]string `json:"Labels"`
		Healthcheck *struct {
			Test []string `json:"Test"`
		} `json:"Healthcheck"`
	} `json:"Config"`
	State struct {
		Status    string `json:"Status"`
		StartedAt string `json:"StartedAt"`
		ExitCode  int    `json:"ExitCode"`
		OOMKilled bool   `json:"OOMKilled"`
		Health    *struct {
			Status string `json:"Status"`
		} `json:"Health"`
	} `json:"State"`
	HostConfig struct {
		RestartPolicy struct {
			Name string `json:"Name"`
		} `json:"RestartPolicy"`
	} `json:"HostConfig"`
	Mounts []struct {
		Type        string `json:"Type"`
		Name        string `json:"Name"`
		Source      string `json:"Source"`
		Destination string `json:"Destination"`
	} `json:"Mounts"`
	NetworkSettings struct {
		Ports    map[string][]struct{ HostPort string } `json:"Ports"`
		Networks map[string]struct{ IPAddress string }  `json:"Networks"`
	} `json:"NetworkSettings"`
}

func inspect(name string) (inspectData, error) {
	out, err := dockerQuick("inspect", name)
	if err != nil {
		return inspectData{}, err
	}
	var list []inspectData
	if err := json.Unmarshal(out, &list); err != nil || len(list) == 0 {
		return inspectData{}, errors.New("docker inspect вернул непонятное")
	}
	return list[0], nil
}

// inspectSummary — то, что обычно ищут в docker inspect, по-человечески.
func inspectSummary(d inspectData) string {
	var b strings.Builder
	row := func(k, v string) {
		if v != "" {
			fmt.Fprintf(&b, "%s %s\n", sMuted.Render(fmt.Sprintf("%-12s", k)), v)
		}
	}
	head := func(s string) { b.WriteString("\n" + sAccent.Render(s) + "\n") }

	row("образ", d.Config.Image)
	state := d.State.Status
	if d.State.Status == "exited" {
		state += fmt.Sprintf(" (код %d)", d.State.ExitCode)
	}
	if d.State.OOMKilled {
		state += sRed.Render(" — убит: кончилась память")
	}
	row("состояние", state)
	if d.State.Health != nil {
		row("здоровье", d.State.Health.Status)
	}
	row("запущен", strings.Replace(strings.SplitN(d.State.StartedAt, ".", 2)[0], "T", " ", 1))
	row("перезапуск", d.HostConfig.RestartPolicy.Name)
	row("команда", strings.Join(append(append([]string{}, d.Config.Entrypoint...), d.Config.Cmd...), " "))
	row("папка", d.Config.WorkingDir)
	if hc := d.Config.Healthcheck; hc != nil && len(hc.Test) > 0 {
		row("проверка", strings.Join(hc.Test, " "))
	}
	if svc := d.Config.Labels[lblService]; svc != "" {
		row("compose", svc+" · "+d.Config.Labels[lblFiles])
	}

	if len(d.NetworkSettings.Ports) > 0 {
		head("порты  (Mac → контейнер)")
		var ports []string
		for p, binds := range d.NetworkSettings.Ports {
			if len(binds) == 0 {
				ports = append(ports, fmt.Sprintf("  %-14s не проброшен", p))
				continue
			}
			ports = append(ports, fmt.Sprintf("  localhost:%-5s → %s", binds[0].HostPort, p))
		}
		sort.Strings(ports)
		b.WriteString(strings.Join(ports, "\n") + "\n")
	}
	if len(d.Mounts) > 0 {
		head("тома и папки")
		for _, m := range d.Mounts {
			src := m.Name
			if src == "" {
				src = m.Source
			}
			fmt.Fprintf(&b, "  %s %s → %s\n", sMuted.Render(fmt.Sprintf("%-6s", m.Type)), src, m.Destination)
		}
	}
	if len(d.NetworkSettings.Networks) > 0 {
		head("сети")
		for n, s := range d.NetworkSettings.Networks {
			fmt.Fprintf(&b, "  %s %s\n", n, sMuted.Render(s.IPAddress))
		}
	}
	if len(d.Config.Env) > 0 {
		head("переменные окружения")
		env := append([]string{}, d.Config.Env...)
		sort.Strings(env)
		for _, e := range env {
			k, v, _ := strings.Cut(e, "=")
			if looksSecret(k) {
				v = sMuted.Render("•••••• (скрыто)")
			}
			fmt.Fprintf(&b, "  %s=%s\n", sBlue.Render(k), v)
		}
	}
	return strings.TrimRight(b.String(), "\n")
}

func looksSecret(key string) bool {
	k := strings.ToUpper(key)
	for _, s := range []string{"PASSWORD", "SECRET", "TOKEN", "KEY", "PASS"} {
		if strings.Contains(k, s) {
			return true
		}
	}
	return false
}

// composeFileOf — первый compose-файл проекта, из которого запущен контейнер.
func composeFileOf(d inspectData) (string, error) {
	files := d.Config.Labels[lblFiles]
	if files == "" {
		return "", errors.New("контейнер запущен не из compose (docker run) — compose-файла нет")
	}
	first, _, _ := strings.Cut(files, ",")
	if !filepath.IsAbs(first) {
		first = filepath.Join(d.Config.Labels[lblDir], first)
	}
	if _, err := os.Stat(first); err != nil {
		return "", fmt.Errorf("compose-файл %s больше не существует", first)
	}
	return first, nil
}

// dockerfileOf находит Dockerfile сервиса: build.context + build.dockerfile из compose.
func dockerfileOf(d inspectData) (string, error) {
	file, err := composeFileOf(d)
	if err != nil {
		return "", err
	}
	data, err := os.ReadFile(file)
	if err != nil {
		return "", err
	}
	return dockerfileFromCompose(data, filepath.Dir(file), d.Config.Labels[lblService])
}

func dockerfileFromCompose(data []byte, dir, service string) (string, error) {
	var doc yaml.Node
	if err := yaml.Unmarshal(data, &doc); err != nil {
		return "", err
	}
	svc := mapValue(mapValue(docRoot(&doc), "services"), service)
	if svc == nil {
		return "", fmt.Errorf("в compose нет сервиса %s", service)
	}
	build := mapValue(svc, "build")
	if build == nil {
		return "", errors.New("сервис запущен из готового образа (image:), своего Dockerfile у него нет")
	}
	ctx, name := buildContext(build), "Dockerfile"
	if df := mapValue(build, "dockerfile"); df != nil && df.Value != "" {
		name = df.Value
	}
	path := filepath.Join(dir, ctx, name)
	if filepath.IsAbs(ctx) {
		path = filepath.Join(ctx, name)
	}
	if _, err := os.Stat(path); err != nil {
		return "", fmt.Errorf("Dockerfile не найден: %s", path)
	}
	return path, nil
}

// imageHistory — слои образа сверху вниз: так образ был собран, даже без Dockerfile.
func imageHistory(image string) (string, error) {
	out, err := dockerQuick("history", "--no-trunc", "--format", "{{.Size}}\t{{.CreatedBy}}", image)
	if err != nil {
		return "", err
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	var b strings.Builder
	for i := len(lines) - 1; i >= 0; i-- { // docker отдаёт от последнего слоя к первому
		size, step, _ := strings.Cut(lines[i], "\t")
		step = strings.TrimSpace(strings.TrimPrefix(step, "/bin/sh -c #(nop) "))
		step = strings.TrimPrefix(step, "/bin/sh -c ")
		step = strings.Replace(step, "RUN /bin/sh -c ", "RUN ", 1)
		step = strings.TrimSuffix(step, " # buildkit")
		if step == "" {
			continue
		}
		fmt.Fprintf(&b, "%s %s\n", sMuted.Render(fmt.Sprintf("%8s", size)), step)
	}
	return strings.TrimRight(b.String(), "\n"), nil
}

// highlight раскрашивает файл через bat, если он есть; иначе — как есть.
func highlight(path, lang string, width int) string {
	data, err := os.ReadFile(path)
	if err != nil {
		return err.Error()
	}
	if _, err := exec.LookPath("bat"); err == nil {
		out, err := exec.Command("bat", "--color=always", "--style=numbers", "--paging=never",
			"--wrap=character", fmt.Sprintf("--terminal-width=%d", width), "-l", lang, path).Output()
		if err == nil {
			return strings.TrimRight(string(out), "\n")
		}
	}
	return strings.TrimRight(string(data), "\n")
}
