package main

import (
	"os"
	"strings"
	"testing"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/muesli/termenv"
)

func TestParseContainers(t *testing.T) {
	out := `{"ID":"a1","Names":"pg","Image":"postgres:17","State":"exited","Status":"Exited (0) 3 days ago","Ports":"","Labels":""}
{"ID":"b2","Names":"api","Image":"api","State":"running","Status":"Up 2 hours","Ports":"0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp","Labels":"com.docker.compose.project=shop,com.docker.compose.service=api"}
not json`
	cs := parseContainers([]byte(out))
	if len(cs) != 2 {
		t.Fatalf("want 2 containers, got %d", len(cs))
	}
	if cs[0].Name != "api" || !cs[0].Running() {
		t.Errorf("running containers go first, got %+v", cs[0])
	}
	if cs[0].Ports != "8080→8080" {
		t.Errorf("ports: %q", cs[0].Ports)
	}
	if cs[0].Project != "shop" {
		t.Errorf("project: %q", cs[0].Project)
	}
}

func TestParseStats(t *testing.T) {
	st := parseStats([]byte(`{"Name":"api","CPUPerc":"0.19%","MemUsage":"964KiB / 3.893GiB","MemPerc":"0.02%","NetIO":"1kB / 0B"}`))
	if st["api"].Mem != "964KiB" || st["api"].CPU != "0.19%" {
		t.Errorf("stats: %+v", st["api"])
	}
}

func TestParseEvent(t *testing.T) {
	e, ok := parseEvent([]byte(`{"Action":"die","time":1700000000,"Actor":{"Attributes":{"name":"api"}}}`))
	if !ok || e.Action != "die" || e.Name != "api" {
		t.Errorf("event: %+v %v", e, ok)
	}
	if _, ok := parseEvent([]byte(`{"Action":"exec_create: sh","time":1}`)); ok {
		t.Error("exec events are noise and should be skipped")
	}
	e, ok = parseEvent([]byte(`{"Action":"health_status: unhealthy","time":1,"Actor":{"Attributes":{"name":"db"}}}`))
	if !ok || e.Action != "unhealthy" {
		t.Errorf("health: %+v", e)
	}
}

func TestTemplateCommand(t *testing.T) {
	tpl, _ := findTemplate("mongo")
	got := tpl.Command()
	want := "docker run -d --name mongo -p 27017:27017 -v mongodata:/data/db --restart unless-stopped mongo:8"
	if got != want {
		t.Errorf("\n got %s\nwant %s", got, want)
	}
	args, err := dockerArgs(got)
	if err != nil || args[0] != "run" || args[len(args)-1] != "mongo:8" {
		t.Errorf("args: %v %v", args, err)
	}
}

func TestSplitArgs(t *testing.T) {
	args, err := splitArgs(`docker run -e "A=b c" --name 'x y' img`)
	if err != nil || len(args) != 7 || args[3] != "A=b c" || args[5] != "x y" {
		t.Errorf("%q %v", args, err)
	}
	if _, err := dockerArgs("rm -rf /"); err == nil {
		t.Error("only docker commands may run")
	}
	if _, err := splitArgs(`docker "oops`); err == nil {
		t.Error("unclosed quote must fail")
	}
}

func TestWatch(t *testing.T) {
	compose := `services:
  postgres:
    image: postgres:18 # db
  app:
    build: .
    ports:
      - "8080:8080"
  worker:
    build:
      context: ./worker
`
	missing, err := missingWatch([]byte(compose))
	if err != nil || strings.Join(missing, ",") != "app,worker" {
		t.Fatalf("missing: %v %v", missing, err)
	}
	out, err := addWatch([]byte(compose), missing)
	if err != nil {
		t.Fatal(err)
	}
	s := string(out)
	for _, want := range []string{"action: rebuild", "path: ./worker", "# db", `"8080:8080"`} {
		if !strings.Contains(s, want) {
			t.Errorf("result has no %q:\n%s", want, s)
		}
	}
	if again, _ := missingWatch(out); len(again) != 0 {
		t.Errorf("still missing after adding: %v", again)
	}
}

// The dashboard renders without panicking at common sizes, with and without data.
func TestView(t *testing.T) {
	m := newModel()
	m.loaded = true
	m.engine = Engine{Up: true, Context: "orbstack", Version: "29.4.0"}
	m.cs = parseContainers([]byte(`{"Names":"api","State":"running","Status":"Up 1 minute","Ports":"0.0.0.0:8080->8080/tcp"}
{"Names":"db","State":"exited","Status":"Exited (0) 2 days ago"}`))
	m.stats = map[string]Stat{"api": {CPU: "1.5%", Mem: "12MiB"}}
	m.logs, m.logsFor = []string{"listening on :8080"}, "api"
	m.events = []Event{{Time: time.Now(), Action: "start", Name: "api"}}
	for _, size := range [][2]int{{80, 24}, {120, 40}, {200, 60}} {
		mm, _ := m.Update(tea.WindowSizeMsg{Width: size[0], Height: size[1]})
		v := mm.View()
		if !strings.Contains(v, "api") {
			t.Errorf("%dx%d: no container in view", size[0], size[1])
		}
		for _, md := range []mode{modeActions, modeTemplates, modeHelp} {
			x := mm.(model)
			x.mode, x.acts = md, containerActions(x.cs[0])
			_ = x.View()
		}
	}
	empty := newModel()
	mm, _ := empty.Update(tea.WindowSizeMsg{Width: 100, Height: 30})
	_ = mm.View()
}

// BERTH_RENDER=out.ansi go test -run TestRender — снимок панели с живыми данными для README/скриншота.
func TestRender(t *testing.T) {
	out := os.Getenv("BERTH_RENDER")
	if out == "" {
		t.Skip("BERTH_RENDER не задан")
	}
	lipgloss.SetColorProfile(termenv.TrueColor)
	m := newModel()
	msg := fetchPS().(psMsg)
	m.engine, m.cs, m.loaded = msg.engine, msg.cs, true
	m.stats = fetchStats()
	if len(m.cs) > 0 {
		m.logs, m.logsFor = tailLogs(m.cs[0].Name, 40), m.cs[0].Name
	}
	m.events = []Event{
		{Time: time.Now().Add(-3 * time.Minute), Action: "create", Name: "berth-demo"},
		{Time: time.Now().Add(-3 * time.Minute), Action: "start", Name: "berth-demo"},
		{Time: time.Now().Add(-1 * time.Minute), Action: "die", Name: "berth-demo"},
		{Time: time.Now().Add(-1 * time.Minute), Action: "start", Name: "berth-demo"},
	}
	mm, _ := m.Update(tea.WindowSizeMsg{Width: 118, Height: 40})
	// BERTH_RENDER_VIEW=inspect|dockerfile|compose BERTH_RENDER_NAME=<контейнер> — снимок просмотрщика
	if name := os.Getenv("BERTH_RENDER_NAME"); name != "" {
		open := map[string]tea.Cmd{"inspect": openInspect(name), "dockerfile": openDockerfile(name, 118), "compose": openCompose(name, 118)}
		mm, _ = mm.Update(open[os.Getenv("BERTH_RENDER_VIEW")]())
	}
	if err := os.WriteFile(out, []byte(mm.View()), 0o644); err != nil {
		t.Fatal(err)
	}
}

func TestDockerfileFromCompose(t *testing.T) {
	dir := t.TempDir()
	os.MkdirAll(dir+"/api", 0o755)
	os.WriteFile(dir+"/api/Dockerfile.dev", []byte("FROM alpine\n"), 0o644)
	os.WriteFile(dir+"/Dockerfile", []byte("FROM alpine\n"), 0o644)
	compose := []byte(`services:
  web:
    build: .
  api:
    build:
      context: ./api
      dockerfile: Dockerfile.dev
  db:
    image: postgres:17
`)
	if p, err := dockerfileFromCompose(compose, dir, "web"); err != nil || p != dir+"/Dockerfile" {
		t.Errorf("web: %q %v", p, err)
	}
	if p, err := dockerfileFromCompose(compose, dir, "api"); err != nil || p != dir+"/api/Dockerfile.dev" {
		t.Errorf("api: %q %v", p, err)
	}
	if _, err := dockerfileFromCompose(compose, dir, "db"); err == nil {
		t.Error("db is built from an image and has no Dockerfile")
	}
}

func TestInspectSummaryHidesSecrets(t *testing.T) {
	var d inspectData
	d.Config.Image = "postgres:17"
	d.Config.Env = []string{"POSTGRES_PASSWORD=hunter2", "API_TOKEN=abc", "PGDATA=/var/lib/postgresql/data"}
	d.State.Status = "running"
	s := inspectSummary(d)
	for _, leak := range []string{"hunter2", "abc"} {
		if strings.Contains(s, leak) {
			t.Errorf("secret %q is shown:\n%s", leak, s)
		}
	}
	if !strings.Contains(s, "/var/lib/postgresql/data") {
		t.Error("ordinary variables should be shown")
	}
}

func TestViewerAndMouse(t *testing.T) {
	m := newModel()
	m.loaded = true
	m.engine = Engine{Up: true, Context: "orbstack", Version: "29"}
	m.cs = parseContainers([]byte(`{"Names":"a","State":"running","Status":"Up"}
{"Names":"b","State":"running","Status":"Up"}
{"Names":"c","State":"exited","Status":"Exited"}`))
	mm, _ := m.Update(tea.WindowSizeMsg{Width: 120, Height: 40})
	// клик по третьей строке таблицы выбирает контейнер c
	header, _, _, _ := mm.(model).layout()
	y := lipgloss.Height(header) + 1 + 2
	mm, _ = mm.Update(tea.MouseMsg{X: 5, Y: y, Button: tea.MouseButtonLeft, Action: tea.MouseActionPress})
	if got := mm.(model).cs[mm.(model).cur].Name; got != "c" {
		t.Errorf("click selected %q, want c", got)
	}
	mm, _ = mm.Update(viewMsg{title: "Dockerfile · test", content: "FROM alpine\nRUN echo hi"})
	if mm.(model).mode != modeView || !strings.Contains(mm.View(), "FROM alpine") {
		t.Error("viewer should open and show the content")
	}
	mm, _ = mm.Update(tea.KeyMsg{Type: tea.KeyEsc})
	if mm.(model).mode != modeList {
		t.Error("esc should close the viewer")
	}
}
