package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/textinput"
	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type mode int

const (
	modeList mode = iota
	modeActions
	modeTemplates
	modeEdit
	modeConfirm
	modeHelp
	modeView // просмотр: внутренности, Dockerfile, compose
)

// action is one thing you can do to a container. Every action explains itself and
// shows the docker command behind it, so the UI doubles as a way to learn docker.
type action struct {
	key, title, about, command string
	run                        func(m *model, c Container) tea.Cmd
}

type model struct {
	w, h int

	engine   Engine
	starting bool
	loaded   bool
	cs       []Container
	stats    map[string]Stat
	statBusy bool
	cur      int
	offset   int

	logs    []string
	logsFor string
	events  []Event
	evCh    <-chan Event
	evStop  context.CancelFunc

	mode      mode
	acts      []action
	actCur    int
	tplCur    int
	input     textinput.Model
	confirm   string
	onConfirm tea.Cmd

	vp        viewport.Model
	viewTitle string

	flash    string
	flashBad bool
	compose  string
}

type (
	tickMsg time.Time
	psMsg   struct {
		cs     []Container
		engine Engine
		err    error
	}
	statsMsg map[string]Stat
	logsMsg  struct {
		name  string
		lines []string
	}
	eventMsg  Event
	evDoneMsg struct{}
	doneMsg   struct {
		text string
		err  error
	}
	engineMsg struct{ err error }
	viewMsg   struct {
		title, content string
		err            error
	}
)

func newModel() model {
	in := textinput.New()
	in.Prompt = "❯ "
	in.PromptStyle = sAccent
	in.CharLimit = 1000
	return model{stats: map[string]Stat{}, input: in, compose: composeFile()}
}

func (m model) Init() tea.Cmd { return tea.Batch(fetchPS, tick()) }

func tick() tea.Cmd { return tea.Tick(2*time.Second, func(t time.Time) tea.Msg { return tickMsg(t) }) }

func fetchPS() tea.Msg {
	e := engineInfo()
	if !e.Up {
		return psMsg{engine: e}
	}
	cs, err := listContainers()
	return psMsg{cs: cs, engine: e, err: err}
}

func fetchStatsCmd() tea.Msg { return statsMsg(fetchStats()) }

func fetchLogs(name string) tea.Cmd {
	return func() tea.Msg { return logsMsg{name: name, lines: tailLogs(name, 40)} }
}

func waitEvent(ch <-chan Event) tea.Cmd {
	return func() tea.Msg {
		e, ok := <-ch
		if !ok {
			return evDoneMsg{}
		}
		return eventMsg(e)
	}
}

// dockerDo runs a short docker command in the background and reports the result.
func dockerDo(text string, args ...string) tea.Cmd {
	return func() tea.Msg {
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
		defer cancel()
		_, err := docker(ctx, args...)
		return doneMsg{text: text, err: err}
	}
}

// interactive hands the terminal to docker (shell, follow logs, compose watch);
// ctrl+c stops docker and brings you back here.
func interactive(note string, args ...string) tea.Cmd {
	cmd := exec.Command("docker", args...)
	return tea.Sequence(
		tea.Printf("%s", sMuted.Render(note)),
		tea.ExecProcess(cmd, func(err error) tea.Msg {
			if err != nil && !strings.Contains(err.Error(), "signal: interrupt") && !strings.Contains(err.Error(), "exit status 130") {
				return doneMsg{err: err}
			}
			return doneMsg{}
		}),
	)
}

func (m *model) selected() (Container, bool) {
	if m.cur < 0 || m.cur >= len(m.cs) {
		return Container{}, false
	}
	return m.cs[m.cur], true
}

func (m *model) setFlash(text string, bad bool) { m.flash, m.flashBad = text, bad }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.w, m.h = msg.Width, msg.Height
		m.input.Width = max(20, m.w-12)
		_, bodyH, _, _ := m.layout()
		m.vp.Width, m.vp.Height = max(10, m.w-4), max(3, bodyH-2)
		return m, nil

	case viewMsg:
		if msg.err != nil {
			m.setFlash("✗ "+msg.err.Error(), true)
			return m, nil
		}
		_, bodyH, _, _ := m.layout()
		m.vp = viewport.New(max(10, m.w-4), max(3, bodyH-2))
		m.vp.SetContent(lipgloss.NewStyle().Width(m.vp.Width).Render(msg.content)) // длинные строки — переносом
		m.viewTitle, m.mode = msg.title, modeView
		return m, nil

	case tea.MouseMsg:
		return m.mouse(msg)

	case tickMsg:
		cmds := []tea.Cmd{fetchPS, tick()}
		if m.engine.Up && !m.statBusy {
			m.statBusy = true
			cmds = append(cmds, fetchStatsCmd)
		}
		if c, ok := m.selected(); ok {
			cmds = append(cmds, fetchLogs(c.Name))
		}
		return m, tea.Batch(cmds...)

	case psMsg:
		wasUp := m.engine.Up
		m.engine, m.loaded = msg.engine, true
		if msg.err == nil {
			prev, _ := m.selected()
			m.cs = msg.cs
			m.cur = indexOf(m.cs, prev.Name, m.cur)
		}
		var cmds []tea.Cmd
		if m.engine.Up && (!wasUp || m.evCh == nil) {
			ctx, cancel := context.WithCancel(context.Background())
			m.evStop, m.evCh = cancel, streamEvents(ctx)
			cmds = append(cmds, waitEvent(m.evCh))
		}
		if c, ok := m.selected(); ok && c.Name != m.logsFor {
			cmds = append(cmds, fetchLogs(c.Name))
		}
		return m, tea.Batch(cmds...)

	case statsMsg:
		m.statBusy = false
		if msg != nil {
			m.stats = msg
		}
		return m, nil

	case logsMsg:
		if c, ok := m.selected(); ok && c.Name == msg.name {
			m.logs, m.logsFor = msg.lines, msg.name
		}
		return m, nil

	case eventMsg:
		m.events = append(m.events, Event(msg))
		if len(m.events) > 50 {
			m.events = m.events[len(m.events)-50:]
		}
		return m, tea.Batch(waitEvent(m.evCh), fetchPS)

	case evDoneMsg:
		m.evCh = nil // restarted on the next poll while the engine is up
		return m, nil

	case doneMsg:
		if msg.err != nil {
			m.setFlash("✗ "+msg.err.Error(), true)
		} else if msg.text != "" {
			m.setFlash(msg.text, false)
		}
		return m, fetchPS

	case engineMsg:
		m.starting = false
		if msg.err != nil {
			m.setFlash("✗ "+msg.err.Error(), true)
		} else {
			m.setFlash("● движок запущен", false)
		}
		return m, fetchPS

	case tea.KeyMsg:
		return m.key(msg)
	}
	return m, nil
}

func indexOf(cs []Container, name string, fallback int) int {
	for i, c := range cs {
		if c.Name == name {
			return i
		}
	}
	return min(max(fallback, 0), max(len(cs)-1, 0))
}

func (m model) key(k tea.KeyMsg) (tea.Model, tea.Cmd) {
	if k.String() == "ctrl+c" {
		return m, tea.Quit
	}
	switch m.mode {
	case modeActions:
		return m.keyActions(k)
	case modeTemplates:
		return m.keyTemplates(k)
	case modeEdit:
		return m.keyEdit(k)
	case modeConfirm:
		switch k.String() {
		case "y", "Y", "enter":
			m.mode = modeList
			return m, m.onConfirm
		case "n", "N", "esc", "q":
			m.mode = modeList
		}
		return m, nil
	case modeHelp:
		m.mode = modeList
		return m, nil
	case modeView:
		switch k.String() {
		case "q", "esc", "left", "h":
			m.mode = modeList
			return m, nil
		case "g", "home":
			m.vp.GotoTop()
			return m, nil
		case "G", "end":
			m.vp.GotoBottom()
			return m, nil
		}
		var cmd tea.Cmd
		m.vp, cmd = m.vp.Update(k)
		return m, cmd
	}

	m.flash = ""
	c, ok := m.selected()
	needEngine := func(next tea.Cmd) tea.Cmd {
		if m.engine.Up {
			return next
		}
		return m.startEngine()
	}
	switch k.String() {
	case "q", "esc":
		return m, tea.Quit
	case "up", "k":
		if m.cur > 0 {
			m.cur--
		}
		return m, m.followLogs()
	case "down", "j":
		if m.cur < len(m.cs)-1 {
			m.cur++
		}
		return m, m.followLogs()
	case "g", "home":
		m.cur = 0
		return m, m.followLogs()
	case "G", "end":
		m.cur = max(len(m.cs)-1, 0)
		return m, m.followLogs()
	case "?":
		m.mode = modeHelp
	case "enter":
		if ok {
			m.acts, m.actCur, m.mode = containerActions(c), 0, modeActions
		} else if !m.engine.Up {
			return m, m.startEngine()
		}
	case "n":
		m.tplCur, m.mode = 0, modeTemplates
	case "l":
		if ok {
			return m, interactive("лог "+c.Name+" вживую · ctrl+c — назад", "logs", "-f", "--tail", "300", c.Name)
		}
	case "s":
		if ok && c.Running() {
			return m, shell(c.Name)
		}
	case "r":
		if ok {
			return m, needEngine(dockerDo("↻ перезапущен "+c.Name, "restart", c.Name))
		}
	case "x":
		if ok {
			if c.Running() {
				return m, dockerDo("■ остановлен "+c.Name, "stop", c.Name)
			}
			return m, needEngine(dockerDo("▶ запущен "+c.Name, "start", c.Name))
		}
	case "d":
		if ok {
			m.ask(fmt.Sprintf("Удалить %s? Тома останутся. [y/N]", c.Name), dockerDo("✗ удалён "+c.Name, "rm", "-f", c.Name))
		}
	case "i":
		if ok {
			return m, openInspect(c.Name)
		}
	case "f":
		if ok {
			return m, openDockerfile(c.Name, m.w)
		}
	case "c":
		if ok {
			return m, openCompose(c.Name, m.w)
		}
	case "t":
		if m.engine.Up {
			return m, interactive("CPU, память, сеть вживую · ctrl+c — назад", "stats")
		}
	case "w":
		return m, m.watch()
	case "u":
		if m.compose != "" {
			return m, needEngine(dockerDo("▶ проект поднят", "compose", "up", "-d"))
		}
	case "U":
		if m.compose != "" {
			m.ask("Остановить compose-проект в этой папке? [y/N]", dockerDo("■ проект остановлен", "compose", "down"))
		}
	case "e":
		if !m.engine.Up {
			return m, m.startEngine()
		}
	case "E":
		if m.engine.Up {
			ctxName := m.engine.Context
			m.ask("Выключить движок и вернуть память? [y/N]", func() tea.Msg {
				err := stopEngine(ctxName)
				return doneMsg{text: "○ движок выключен", err: err}
			})
		}
	}
	return m, nil
}

func (m *model) followLogs() tea.Cmd {
	if c, ok := m.selected(); ok {
		m.logs, m.logsFor = nil, ""
		return fetchLogs(c.Name)
	}
	return nil
}

func (m *model) ask(q string, then tea.Cmd) { m.confirm, m.onConfirm, m.mode = q, then, modeConfirm }

func (m *model) startEngine() tea.Cmd {
	if m.starting {
		return nil
	}
	m.starting = true
	m.setFlash("запускаю движок…", false)
	ctxName := m.engine.Context
	return func() tea.Msg { return engineMsg{err: startEngine(ctxName)} }
}

func shell(name string) tea.Cmd {
	return interactive("терминал в "+name+" · exit — назад",
		"exec", "-it", name, "sh", "-c", "command -v bash >/dev/null && exec bash || exec sh")
}

// watch: live rebuild via docker compose watch; adds develop.watch first if it's missing.
func (m *model) watch() tea.Cmd {
	if m.compose == "" {
		m.setFlash("в этой папке нет compose-файла — живая сборка работает в compose-проекте", true)
		return nil
	}
	data, err := os.ReadFile(m.compose)
	if err != nil {
		m.setFlash("✗ "+err.Error(), true)
		return nil
	}
	missing, err := missingWatch(data)
	if err != nil {
		m.setFlash("✗ "+err.Error(), true)
		return nil
	}
	run := interactive("слежу за кодом ("+m.compose+"): сохранил — пересборка и перезапуск · ctrl+c — назад", "compose", "watch")
	if len(missing) == 0 {
		return run
	}
	file := m.compose
	m.ask(fmt.Sprintf("Добавить блок develop.watch для %s в %s, чтобы контейнер пересобирался при сохранении кода? [y/N]",
		strings.Join(missing, ", "), file), tea.Sequence(func() tea.Msg {
		if err := addWatchToFile(file, missing); err != nil {
			return doneMsg{err: err}
		}
		return doneMsg{text: "✓ develop.watch добавлен в " + file}
	}, run))
	return nil
}

func containerActions(c Container) []action {
	acts := []action{
		{"l", "Логи", "Вывод контейнера вживую. ctrl+c — назад.", "docker logs -f --tail 300 " + c.Name,
			func(m *model, c Container) tea.Cmd {
				return interactive("лог "+c.Name+" вживую · ctrl+c — назад", "logs", "-f", "--tail", "300", c.Name)
			}},
	}
	if c.Running() {
		acts = append(acts,
			action{"s", "Терминал", "Зайти внутрь контейнера (bash, если есть). exit — назад.", "docker exec -it " + c.Name + " sh",
				func(m *model, c Container) tea.Cmd { return shell(c.Name) }},
			action{"r", "Перезапустить", "Остановить и запустить с теми же настройками. Пригодится после правки конфига.", "docker restart " + c.Name,
				func(m *model, c Container) tea.Cmd {
					return dockerDo("↻ перезапущен "+c.Name, "restart", c.Name)
				}},
			action{"x", "Остановить", "Контейнер остановится, файлы и тома останутся — запустишь снова когда угодно.", "docker stop " + c.Name,
				func(m *model, c Container) tea.Cmd {
					return dockerDo("■ остановлен "+c.Name, "stop", c.Name)
				}},
		)
	} else {
		acts = append(acts, action{"x", "Запустить", "Запустить остановленный контейнер с теми же настройками.", "docker start " + c.Name,
			func(m *model, c Container) tea.Cmd { return dockerDo("▶ запущен "+c.Name, "start", c.Name) }})
	}
	acts = append(acts,
		action{"i", "Внутренности", "Образ, состояние, команда запуска, порты, тома, сети и переменные окружения (пароли скрыты).", "docker inspect " + c.Name,
			func(m *model, c Container) tea.Cmd { return openInspect(c.Name) }},
		action{"f", "Dockerfile", "Как собран образ. Для контейнера из compose — его Dockerfile; для готового образа — слои, из которых он собран.", "cat Dockerfile · docker history " + c.Image,
			func(m *model, c Container) tea.Cmd { return openDockerfile(c.Name, m.w) }},
		action{"c", "Compose-файл", "Compose-файл проекта, из которого запущен контейнер.", "cat compose.yaml",
			func(m *model, c Container) tea.Cmd { return openCompose(c.Name, m.w) }},
		action{"d", "Удалить", "Удалить контейнер. Именованные тома (данные баз) останутся.", "docker rm -f " + c.Name,
			func(m *model, c Container) tea.Cmd {
				m.ask(fmt.Sprintf("Удалить %s? Тома останутся. [y/N]", c.Name), dockerDo("✗ удалён "+c.Name, "rm", "-f", c.Name))
				return nil
			}},
	)
	return acts
}

func (m model) keyActions(k tea.KeyMsg) (tea.Model, tea.Cmd) {
	c, ok := m.selected()
	switch k.String() {
	case "esc", "q", "left", "h":
		m.mode = modeList
	case "up", "k":
		m.actCur = max(m.actCur-1, 0)
	case "down", "j":
		m.actCur = min(m.actCur+1, len(m.acts)-1)
	case "enter", "right":
		if ok {
			m.mode = modeList
			return m, m.acts[m.actCur].run(&m, c)
		}
	default:
		for _, a := range m.acts {
			if k.String() == a.key && ok {
				m.mode = modeList
				return m, a.run(&m, c)
			}
		}
	}
	return m, nil
}

func (m model) keyTemplates(k tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch k.String() {
	case "esc", "q", "left", "h":
		m.mode = modeList
	case "up", "k":
		m.tplCur = max(m.tplCur-1, 0)
	case "down", "j":
		m.tplCur = min(m.tplCur+1, len(templates))
	case "enter", "right":
		if m.tplCur == len(templates) {
			m.input.SetValue("docker run -d --name app -p 8080:8080 образ:тег")
		} else {
			m.input.SetValue(templates[m.tplCur].Command())
		}
		m.input.CursorEnd()
		m.mode = modeEdit
		return m, m.input.Focus()
	}
	return m, nil
}

func (m model) keyEdit(k tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch k.String() {
	case "esc":
		m.input.Blur()
		m.mode = modeTemplates
		return m, nil
	case "enter":
		args, err := dockerArgs(m.input.Value())
		if err != nil {
			m.setFlash("✗ "+err.Error(), true)
			return m, nil
		}
		m.input.Blur()
		m.mode = modeList
		name := runName(args)
		run := dockerDo("▶ запущен "+name, args...)
		if m.engine.Up {
			return m, run
		}
		return m, tea.Sequence(m.startEngine(), run)
	}
	var cmd tea.Cmd
	m.input, cmd = m.input.Update(k)
	return m, cmd
}

func runName(args []string) string {
	for i, a := range args {
		if a == "--name" && i+1 < len(args) {
			return args[i+1]
		}
	}
	return "container"
}

// ---------- view ----------

func (m model) View() string {
	if m.w == 0 {
		return ""
	}
	header, bodyH, tableH, paneH := m.layout()
	footer := m.footer()
	var body string
	switch m.mode {
	case modeHelp:
		body = m.helpView(bodyH)
	case modeView:
		pct := fmt.Sprintf(" %3.0f%% ", m.vp.ScrollPercent()*100)
		body = boxed(" "+m.viewTitle+" · ↑↓ прокрутка · esc — назад ·"+pct, m.vp.View(), m.w, bodyH)
	default:
		var bottom string
		switch m.mode {
		case modeActions:
			bottom = m.actionsView(paneH)
		case modeTemplates:
			bottom = m.templatesView(paneH)
		case modeEdit:
			bottom = m.editView(paneH)
		case modeConfirm:
			bottom = m.confirmView(paneH)
		default:
			bottom = m.panesView(paneH)
		}
		body = lipgloss.JoinVertical(lipgloss.Left, m.tableView(tableH), "", bottom)
	}
	return lipgloss.JoinVertical(lipgloss.Left, header, lipgloss.NewStyle().Height(bodyH).MaxHeight(bodyH).Render(body), footer)
}

// layout: шапка и высоты частей экрана — общий расчёт для View и кликов мышью.
func (m model) layout() (header string, bodyH, tableH, paneH int) {
	var top []string
	if m.h >= 34 {
		top = append(top, "", banner(), "")
	} else {
		top = append(top, " "+title()+sMuted.Render("  контейнеры в терминале"))
	}
	top = append(top, " "+m.statusLine(), "")
	header = strings.Join(top, "\n")
	bodyH = m.h - lipgloss.Height(header) - lipgloss.Height(m.footer())
	// таблица — по числу контейнеров (но не больше 2/3 экрана), всё остальное — логу и событиям
	rows := len(m.cs) + 1
	if len(m.cs) == 0 {
		rows = 3
	}
	tableH = min(rows, bodyH*2/3)
	paneH = max(6, bodyH-tableH-1)
	return
}

func (m model) statusLine() string {
	name := engineName(m.engine.Context)
	switch {
	case !m.loaded:
		return sMuted.Render("подключаюсь…")
	case m.starting:
		return sGold.Render("◌ запускаю " + name + "…")
	case !m.engine.Up:
		return sGold.Render("○ движок выключен") + sMuted.Render(" · "+name+" · press ") + sKey.Render("e") +
			sMuted.Render(" — включить; любое действие включит его само")
	}
	run := 0
	for _, c := range m.cs {
		if c.Running() {
			run++
		}
	}
	s := sBlue.Render("● ") + sText.Render(name) + sMuted.Render(" · Docker "+m.engine.Version+" · ") +
		sAccent.Render(fmt.Sprint(run)) + sMuted.Render(fmt.Sprintf(" из %d работают", len(m.cs)))
	if m.compose != "" {
		wd, _ := os.Getwd()
		s += sMuted.Render(" · проект ") + sText.Render(lastPath(wd))
	}
	return s
}

func lastPath(p string) string {
	if i := strings.LastIndex(p, "/"); i >= 0 {
		return p[i+1:]
	}
	return p
}

const (
	wName  = 22
	wState = 24
	wCPU   = 7
	wMem   = 10
	wPorts = 22
)

func (m *model) tableView(h int) string {
	var lines []string
	head := fmt.Sprintf("   %-*s %-*s %*s %*s  %-*s %s", wName, "ИМЯ", wState, "СОСТОЯНИЕ", wCPU, "CPU", wMem, "ПАМЯТЬ", wPorts, "ПОРТЫ", "ПРОЕКТ")
	lines = append(lines, sMuted.Render(trunc(head, m.w)))
	rows := h - 1
	if len(m.cs) == 0 {
		msg := "контейнеров нет — n: запустить postgres, redis, nginx… по шаблону"
		if !m.engine.Up {
			msg = "движок выключен — контейнеры появятся, когда он заработает"
		}
		lines = append(lines, "", "   "+sMuted.Render(msg))
		return strings.Join(lines, "\n")
	}
	// keep the cursor in view
	if m.cur < m.offset {
		m.offset = m.cur
	}
	if m.cur >= m.offset+rows {
		m.offset = m.cur - rows + 1
	}
	for i := m.offset; i < len(m.cs) && i < m.offset+rows; i++ {
		c := m.cs[i]
		st := m.stats[c.Name]
		cpu, mem := st.CPU, st.Mem
		if !c.Running() {
			cpu, mem = "", ""
		}
		row := fmt.Sprintf("%-*s %-*s %*s %*s  %-*s %s",
			wName, trunc(c.Name, wName), wState, trunc(c.Status, wState), wCPU, cpu, wMem, mem, wPorts, trunc(c.Ports, wPorts), c.Project)
		row = trunc(row, m.w-4)
		if i == m.cur {
			line := sAccent.Render("▌") + dot(c) + " " + lipgloss.NewStyle().Foreground(cText).Background(cSelBg).Bold(true).Render(row)
			lines = append(lines, line)
		} else {
			style := sText
			if !c.Running() {
				style = sSubtle
			}
			lines = append(lines, " "+dot(c)+" "+style.Render(row))
		}
	}
	return strings.Join(lines, "\n")
}

func (m model) panesView(h int) string {
	inner := h - 2
	logW, evW := m.w, 0
	if m.w >= 100 {
		evW = max(36, m.w/3)
		logW = m.w - evW
	}
	name := m.logsFor
	if name == "" {
		name = "—"
	}
	var logLines []string
	for _, l := range lastN(m.logs, inner) {
		logLines = append(logLines, sSubtle.Render(trunc(l, logW-4)))
	}
	if len(logLines) == 0 {
		logLines = []string{sMuted.Render("пока пусто")}
	}
	logs := paneBox(" лог · "+name+" ", strings.Join(logLines, "\n"), logW, h)
	if evW == 0 {
		return logs
	}
	var evLines []string
	for _, e := range lastN(m.events, inner) {
		evLines = append(evLines, eventLine(e, evW-4))
	}
	if len(evLines) == 0 {
		evLines = []string{sMuted.Render("запуски, остановки, падения — здесь вживую")}
	}
	return lipgloss.JoinHorizontal(lipgloss.Top, logs, paneBox(" события ", strings.Join(evLines, "\n"), evW, h))
}

func eventLine(e Event, w int) string {
	var a string
	switch e.Action {
	case "start", "unpause", "healthy":
		a = sBlue.Render("▶ " + e.Action)
	case "die", "kill", "oom", "unhealthy":
		a = sRed.Render("✗ " + e.Action)
	case "create":
		a = sAccent.Render("+ " + e.Action)
	default:
		a = sMuted.Render("■ " + e.Action)
	}
	return trunc(sMuted.Render(e.Time.Format("15:04:05"))+" "+a+" "+sText.Render(e.Name), w)
}

func paneBox(label, content string, w, h int) string {
	box := sPane.Width(w - 2).Height(h - 2).MaxHeight(h).Render(content)
	// put the label into the top border
	lines := strings.Split(box, "\n")
	if len(lines) > 0 && w > len(label)+4 {
		lines[0] = sMuted.Render("╭─") + sSubtle.Render(label) + sMuted.Render(strings.Repeat("─", max(0, w-lipgloss.Width(label)-3))+"╮")
	}
	return strings.Join(lines, "\n")
}

func (m model) actionsView(h int) string {
	c, _ := m.selected()
	listW := 24
	var list []string
	for i, a := range m.acts {
		line := fmt.Sprintf("%s  %s", sKey.Render(a.key), a.title)
		if i == m.actCur {
			line = sAccent.Render("▌") + lipgloss.NewStyle().Background(cSelBg).Bold(true).Render(fmt.Sprintf("%s  %-*s", a.key, listW-6, a.title))
		} else {
			line = " " + line
		}
		list = append(list, line)
	}
	a := m.acts[m.actCur]
	about := lipgloss.NewStyle().Width(max(20, m.w-listW-10)).Render(
		sText.Render(a.about) + "\n\n" + sMuted.Render("команда: ") + sBlue.Render(a.command))
	content := lipgloss.JoinHorizontal(lipgloss.Top, lipgloss.NewStyle().Width(listW).Render(strings.Join(list, "\n")), about)
	return boxed(" "+c.Name+" · enter — выполнить · esc — назад ", content, m.w, h)
}

func (m model) templatesView(h int) string {
	listW := 22
	var list []string
	names := make([]string, 0, len(templates)+1)
	for _, t := range templates {
		names = append(names, t.Name)
	}
	names = append(names, "свой образ")
	for i, n := range names {
		if i == m.tplCur {
			list = append(list, sAccent.Render("▌")+lipgloss.NewStyle().Background(cSelBg).Bold(true).Render(fmt.Sprintf(" %-*s", listW-3, n)))
		} else {
			list = append(list, "  "+n)
		}
	}
	var about string
	if m.tplCur == len(templates) {
		about = sText.Render("Пустой docker run: впиши образ, порты и имя.") + "\n\n" +
			sMuted.Render("-d в фоне · --name имя · -p порт Mac:контейнер · -e переменная · -v том:/путь")
	} else {
		t := templates[m.tplCur]
		about = sText.Render(t.About) + "\n\n" + sMuted.Render("команда: ") + sBlue.Render(t.Command()) +
			"\n\n" + sMuted.Render("enter — посмотреть и поправить команду перед запуском")
	}
	about = lipgloss.NewStyle().Width(max(20, m.w-listW-10)).Render(about)
	content := lipgloss.JoinHorizontal(lipgloss.Top, lipgloss.NewStyle().Width(listW).Render(strings.Join(list, "\n")), about)
	return boxed(" новый контейнер · enter — выбрать · esc — назад ", content, m.w, h)
}

func (m model) editView(h int) string {
	content := sText.Render("Ровно эта команда и выполнится. Поправь что угодно.") + "\n\n" +
		m.input.View() + "\n\n" + sMuted.Render("enter — запустить · esc — к шаблонам")
	return boxed(" docker run ", content, m.w, h)
}

func (m model) confirmView(h int) string {
	return boxed(" подтверди ", sText.Render(m.confirm), m.w, h)
}

func boxed(label, content string, w, h int) string {
	box := sBox.Width(w - 2).Height(h - 2).MaxHeight(h).Render(content)
	lines := strings.Split(box, "\n")
	if len(lines) > 0 && w > lipgloss.Width(label)+4 {
		lines[0] = sAccent.Render("╭─") + sText.Render(label) + sAccent.Render(strings.Repeat("─", max(0, w-lipgloss.Width(label)-3))+"╮")
	}
	return strings.Join(lines, "\n")
}

var keyHelp = [][3]string{
	{"↑↓ j k", "выбрать", "контейнер; его лог — внизу"},
	{"enter", "действия", "всё, что можно сделать, с пояснением и командой docker"},
	{"l", "логи", "вживую (docker logs -f) · ctrl+c — назад"},
	{"s", "терминал", "внутри контейнера (docker exec -it … sh) · exit — назад"},
	{"r", "перезапуск", "docker restart"},
	{"x", "стоп / старт", "docker stop / docker start"},
	{"d", "удалить", "docker rm -f — именованные тома останутся"},
	{"i", "внутренности", "образ, порты, тома, сети, переменные (docker inspect)"},
	{"f", "Dockerfile", "как собран образ: Dockerfile из compose или слои образа"},
	{"c", "compose", "compose-файл проекта, из которого запущен контейнер"},
	{"мышь", "", "колесо — по списку, клик — выбрать контейнер"},
	{"n", "новый", "postgres, redis, nginx, mongo, mysql, rabbitmq или свой образ; команду можно поправить"},
	{"t", "мониторинг", "CPU, память и сеть всех контейнеров вживую (docker stats)"},
	{"w", "живая сборка", "сохранил код — образ пересобран, контейнер перезапущен (docker compose watch)"},
	{"u / U", "compose", "поднять / остановить проект в этой папке"},
	{"e / E", "движок", "включить / выключить (выключение возвращает память)"},
	{"q", "выход", ""},
}

func (m model) helpView(h int) string {
	var lines []string
	for _, k := range keyHelp {
		lines = append(lines, fmt.Sprintf("  %s %s %s", sKey.Render(fmt.Sprintf("%-8s", k[0])), sText.Render(fmt.Sprintf("%-14s", k[1])), sMuted.Render(k[2])))
	}
	lines = append(lines, "", sMuted.Render("  То же без интерфейса: orbstack help · любая клавиша — закрыть"))
	return boxed(" клавиши ", strings.Join(lines, "\n"), m.w, min(h, len(lines)+2))
}

func (m model) footer() string {
	if m.flash != "" {
		st := sBlue
		if m.flashBad {
			st = sRed
		}
		return " " + trunc(st.Render(m.flash), m.w-2)
	}
	keys := []string{"enter", "действия", "l", "логи", "s", "терминал", "r", "перезапуск", "x", "стоп/старт", "i", "внутри", "f", "Dockerfile", "n", "новый", "t", "мониторинг", "w", "живая сборка", "?", "все клавиши", "q", "выход"}
	var parts []string
	for i := 0; i < len(keys); i += 2 {
		parts = append(parts, sKey.Render(keys[i])+" "+sMuted.Render(keys[i+1]))
	}
	return " " + trunc(strings.Join(parts, sMuted.Render(" · ")), m.w-2)
}

func trunc(s string, w int) string {
	if w <= 0 {
		return ""
	}
	return lipgloss.NewStyle().MaxWidth(w).Render(s)
}

func lastN[T any](s []T, n int) []T {
	if n <= 0 {
		return nil
	}
	if len(s) > n {
		return s[len(s)-n:]
	}
	return s
}

// ---------- внутренности ----------

func openInspect(name string) tea.Cmd {
	return func() tea.Msg {
		d, err := inspect(name)
		if err != nil {
			return viewMsg{err: err}
		}
		return viewMsg{title: "внутренности · " + name, content: inspectSummary(d)}
	}
}

func openDockerfile(name string, w int) tea.Cmd {
	return func() tea.Msg {
		d, err := inspect(name)
		if err != nil {
			return viewMsg{err: err}
		}
		if path, err := dockerfileOf(d); err == nil {
			return viewMsg{title: "Dockerfile · " + shortPath(path), content: highlight(path, "dockerfile", w-6)}
		} else {
			// нет Dockerfile под рукой — показать, как образ был собран, по его слоям
			hist, herr := imageHistory(d.Config.Image)
			if herr != nil {
				return viewMsg{err: err}
			}
			note := sMuted.Render(err.Error()+"\nНиже — слои образа "+d.Config.Image+", сверху вниз: так он был собран.") + "\n\n"
			return viewMsg{title: "слои образа · " + d.Config.Image, content: note + hist}
		}
	}
}

func openCompose(name string, w int) tea.Cmd {
	return func() tea.Msg {
		d, err := inspect(name)
		if err != nil {
			return viewMsg{err: err}
		}
		path, err := composeFileOf(d)
		if err != nil {
			return viewMsg{err: err}
		}
		return viewMsg{title: "compose · " + shortPath(path), content: highlight(path, "yaml", w-6)}
	}
}

// ---------- мышь ----------

func (m model) mouse(msg tea.MouseMsg) (tea.Model, tea.Cmd) {
	if m.mode == modeView {
		var cmd tea.Cmd
		m.vp, cmd = m.vp.Update(msg)
		return m, cmd
	}
	if m.mode != modeList {
		return m, nil
	}
	switch {
	case msg.Button == tea.MouseButtonWheelUp && msg.Action == tea.MouseActionPress:
		if m.cur > 0 {
			m.cur--
			return m, m.followLogs()
		}
	case msg.Button == tea.MouseButtonWheelDown && msg.Action == tea.MouseActionPress:
		if m.cur < len(m.cs)-1 {
			m.cur++
			return m, m.followLogs()
		}
	case msg.Button == tea.MouseButtonLeft && msg.Action == tea.MouseActionPress:
		header, _, tableH, _ := m.layout()
		rows := tableH - 1
		offset := max(0, m.cur-rows+1)
		i := msg.Y - lipgloss.Height(header) - 1 + offset
		if msg.Y > lipgloss.Height(header) && i >= 0 && i < len(m.cs) && i < offset+rows {
			if i == m.cur { // второй клик по выбранному — действия
				m.acts, m.actCur, m.mode = containerActions(m.cs[i]), 0, modeActions
				return m, nil
			}
			m.cur = i
			return m, m.followLogs()
		}
	}
	return m, nil
}

// shortPath: /долгий/путь/shop/compose.yaml → shop/compose.yaml
func shortPath(p string) string {
	dir, file := filepath.Split(p)
	return filepath.Join(filepath.Base(dir), file)
}
