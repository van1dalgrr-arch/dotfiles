package main

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"sort"
	"strings"
	"time"
)

// Everything goes through the docker CLI rather than the Engine API: it follows the
// current docker context (OrbStack, Colima, Docker Desktop) with zero extra setup.

type Container struct {
	ID      string
	Name    string
	Image   string
	State   string // running, exited, created, restarting, paused, dead
	Status  string // "Up 2 hours (healthy)"
	Ports   string // shortened: "5432→5432 8080→80"
	Project string // compose project, if any
}

func (c Container) Running() bool { return c.State == "running" }

type Stat struct {
	CPU     string
	Mem     string
	MemPerc string
	Net     string
}

type Event struct {
	Time   time.Time
	Action string
	Name   string
}

type Engine struct {
	Up      bool
	Context string
	Version string
}

func docker(ctx context.Context, args ...string) ([]byte, error) {
	out, err := exec.CommandContext(ctx, "docker", args...).CombinedOutput()
	if err != nil {
		msg := strings.TrimSpace(string(out))
		if msg == "" {
			msg = err.Error()
		}
		return out, errors.New(firstLine(msg))
	}
	return out, nil
}

func dockerQuick(args ...string) ([]byte, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	return docker(ctx, args...)
}

func engineInfo() Engine {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	e := Engine{}
	if out, err := exec.CommandContext(ctx, "docker", "context", "show").Output(); err == nil {
		e.Context = strings.TrimSpace(string(out))
	}
	out, err := exec.CommandContext(ctx, "docker", "version", "--format", "{{.Server.Version}}").Output()
	if err == nil && len(strings.TrimSpace(string(out))) > 0 {
		e.Up = true
		e.Version = strings.TrimSpace(string(out))
	}
	return e
}

// engineName turns a docker context into a product name for the status line.
func engineName(ctx string) string {
	switch {
	case strings.Contains(ctx, "orbstack"):
		return "OrbStack"
	case strings.Contains(ctx, "colima"):
		return "Colima"
	case strings.Contains(ctx, "desktop"):
		return "Docker Desktop"
	case ctx == "" || ctx == "default":
		return "Docker"
	}
	return ctx
}

// startEngine launches whatever backs the current context and waits until it answers.
func startEngine(ctxName string) error {
	switch {
	case strings.Contains(ctxName, "orbstack"):
		if _, err := exec.LookPath("orb"); err == nil {
			_ = exec.Command("orb", "start").Start()
		} else {
			_ = exec.Command("open", "-ga", "OrbStack").Run()
		}
	case strings.Contains(ctxName, "colima"):
		_ = exec.Command("colima", "start").Start()
	default:
		_ = exec.Command("open", "-ga", "Docker").Run()
	}
	for i := 0; i < 60; i++ {
		if engineInfo().Up {
			return nil
		}
		time.Sleep(time.Second)
	}
	return errors.New("движок не запустился за минуту")
}

func stopEngine(ctxName string) error {
	if strings.Contains(ctxName, "orbstack") {
		if _, err := exec.LookPath("orb"); err == nil {
			return exec.Command("orb", "stop").Run()
		}
	}
	if strings.Contains(ctxName, "colima") {
		return exec.Command("colima", "stop").Run()
	}
	return errors.New("выключать умею только OrbStack и Colima")
}

type psRow struct {
	ID     string `json:"ID"`
	Names  string `json:"Names"`
	Image  string `json:"Image"`
	State  string `json:"State"`
	Status string `json:"Status"`
	Ports  string `json:"Ports"`
	Labels string `json:"Labels"`
}

func listContainers() ([]Container, error) {
	out, err := dockerQuick("ps", "-a", "--format", "{{json .}}")
	if err != nil {
		return nil, err
	}
	return parseContainers(out), nil
}

func parseContainers(out []byte) []Container {
	var cs []Container
	sc := bufio.NewScanner(strings.NewReader(string(out)))
	sc.Buffer(make([]byte, 1024*1024), 1024*1024)
	for sc.Scan() {
		var r psRow
		if json.Unmarshal(sc.Bytes(), &r) != nil || r.Names == "" {
			continue
		}
		cs = append(cs, Container{
			ID: r.ID, Name: r.Names, Image: r.Image, State: r.State, Status: r.Status,
			Ports: shortPorts(r.Ports), Project: label(r.Labels, "com.docker.compose.project"),
		})
	}
	// running first, then by project and name: related containers sit together
	sort.SliceStable(cs, func(i, j int) bool {
		if cs[i].Running() != cs[j].Running() {
			return cs[i].Running()
		}
		if cs[i].Project != cs[j].Project {
			return cs[i].Project < cs[j].Project
		}
		return cs[i].Name < cs[j].Name
	})
	return cs
}

func label(labels, key string) string {
	for _, kv := range strings.Split(labels, ",") {
		if k, v, ok := strings.Cut(kv, "="); ok && k == key {
			return v
		}
	}
	return ""
}

var portRe = regexp.MustCompile(`(\d+)->(\d+)`)

// shortPorts: "0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp" → "5432→5432"
func shortPorts(s string) string {
	seen := map[string]bool{}
	var out []string
	for _, m := range portRe.FindAllStringSubmatch(s, -1) {
		p := m[1] + "→" + m[2]
		if !seen[p] {
			seen[p] = true
			out = append(out, p)
		}
	}
	return strings.Join(out, " ")
}

type statRow struct {
	Name     string `json:"Name"`
	CPUPerc  string `json:"CPUPerc"`
	MemUsage string `json:"MemUsage"`
	MemPerc  string `json:"MemPerc"`
	NetIO    string `json:"NetIO"`
}

// fetchStats takes about two seconds: docker samples CPU over an interval.
func fetchStats() map[string]Stat {
	out, err := dockerQuick("stats", "--no-stream", "--format", "{{json .}}")
	if err != nil {
		return nil
	}
	return parseStats(out)
}

func parseStats(out []byte) map[string]Stat {
	stats := map[string]Stat{}
	sc := bufio.NewScanner(strings.NewReader(string(out)))
	for sc.Scan() {
		var r statRow
		if json.Unmarshal(sc.Bytes(), &r) != nil || r.Name == "" {
			continue
		}
		mem, _, _ := strings.Cut(r.MemUsage, " /")
		stats[r.Name] = Stat{CPU: r.CPUPerc, Mem: mem, MemPerc: r.MemPerc, Net: r.NetIO}
	}
	return stats
}

func tailLogs(name string, n int) []string {
	out, err := dockerQuick("logs", "--tail", fmt.Sprint(n), name)
	if err != nil && len(out) == 0 {
		return []string{err.Error()}
	}
	text := strings.TrimRight(stripANSI(string(out)), "\n")
	if text == "" {
		return nil
	}
	return strings.Split(text, "\n")
}

var eventActions = map[string]bool{
	"start": true, "stop": true, "die": true, "kill": true, "oom": true,
	"restart": true, "destroy": true, "create": true, "pause": true, "unpause": true,
}

type eventRow struct {
	Action string `json:"Action"`
	Time   int64  `json:"time"`
	Actor  struct {
		Attributes map[string]string `json:"Attributes"`
	} `json:"Actor"`
}

// streamEvents follows docker events until ctx is cancelled or the engine goes away.
func streamEvents(ctx context.Context) <-chan Event {
	ch := make(chan Event, 32)
	go func() {
		defer close(ch)
		cmd := exec.CommandContext(ctx, "docker", "events", "--filter", "type=container", "--format", "{{json .}}")
		out, err := cmd.StdoutPipe()
		if err != nil || cmd.Start() != nil {
			return
		}
		sc := bufio.NewScanner(out)
		for sc.Scan() {
			if e, ok := parseEvent(sc.Bytes()); ok {
				select {
				case ch <- e:
				case <-ctx.Done():
					return
				}
			}
		}
		_ = cmd.Wait()
	}()
	return ch
}

func parseEvent(b []byte) (Event, bool) {
	var r eventRow
	if json.Unmarshal(b, &r) != nil {
		return Event{}, false
	}
	action := r.Action
	if strings.HasPrefix(action, "health_status") {
		action = strings.TrimSpace(strings.TrimPrefix(action, "health_status:"))
		if action == "" {
			action = "health"
		}
	} else if !eventActions[action] {
		return Event{}, false
	}
	return Event{Time: time.Unix(r.Time, 0), Action: action, Name: r.Actor.Attributes["name"]}, true
}

var ansiRe = regexp.MustCompile(`\x1b\[[0-9;?]*[ -/]*[@-~]`)

func stripANSI(s string) string { return ansiRe.ReplaceAllString(s, "") }

func firstLine(s string) string {
	line, _, _ := strings.Cut(s, "\n")
	return line
}

// composeFile returns the compose file in the current directory, if any.
func composeFile() string {
	for _, f := range []string{"compose.yaml", "compose.yml", "docker-compose.yml", "docker-compose.yaml"} {
		if _, err := os.Stat(f); err == nil {
			return f
		}
	}
	return ""
}
