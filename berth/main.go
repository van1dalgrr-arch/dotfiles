// berth — контейнеры в терминале: живая панель с логами, событиями и нагрузкой,
// шаблоны для частых сервисов и живая сборка compose-проектов.
// В dotfiles вызывается как orbstack (alias в zsh/.zshrc); собирает install.sh.
package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"text/tabwriter"

	tea "github.com/charmbracelet/bubbletea"
)

var version = "dev"

const usage = `orbstack — контейнеры в терминале

  orbstack                  живая панель (внутри ? — все клавиши)
  orbstack ps               все контейнеры
  orbstack run [шаблон]     postgres redis nginx mongo mysql rabbitmq; без имени — список
  orbstack logs [имя]       лог вживую
  orbstack sh [имя]         терминал внутри контейнера
  orbstack restart|stop|start|rm [имя]
  orbstack top              CPU, память, сеть вживую
  orbstack events           что запускается и падает
  orbstack up|down          compose-проект в текущей папке
  orbstack watch            живая сборка: сохранил код — контейнер пересобрался сам
  orbstack images|clean     образы, уборка
  orbstack on|off           движок: включить / выключить и вернуть память
  orbstack guide            шпаргалка: как запускать контейнеры из терминала

Без имени контейнера — выбор из списка. Работает с любым docker context: OrbStack, Colima, Docker Desktop.
`

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		p := tea.NewProgram(newModel(), tea.WithAltScreen())
		if _, err := p.Run(); err != nil {
			fail(err)
		}
		return
	}
	if err := runCLI(args); err != nil {
		fail(err)
	}
}

func fail(err error) {
	fmt.Fprintln(os.Stderr, "orbstack:", err)
	os.Exit(1)
}

func runCLI(args []string) error {
	arg := func(i int) string {
		if i < len(args) {
			return args[i]
		}
		return ""
	}
	// движок нужен только этим командам; остальные (help, guide, run без шаблона…) работают и без него
	needsEngine := map[string]bool{"ps": true, "logs": true, "sh": true, "exec": true, "shell": true, "restart": true,
		"stop": true, "start": true, "rm": true, "top": true, "stats": true, "events": true, "up": true, "down": true,
		"images": true, "clean": true, "run": arg(1) != ""}
	if needsEngine[args[0]] {
		if err := ensureEngine(); err != nil {
			return err
		}
	}
	switch args[0] {
	case "help", "-h", "--help":
		fmt.Print(usage)
	case "version", "--version":
		fmt.Println("berth", version)
	case "ps":
		return printPS()
	case "run":
		return cliRun(arg(1))
	case "logs":
		return withName(arg(1), func(n string) error { return passthrough("logs", "-f", "--tail", "300", n) })
	case "sh", "exec", "shell":
		return withName(arg(1), func(n string) error {
			return passthrough("exec", "-it", n, "sh", "-c", "command -v bash >/dev/null && exec bash || exec sh")
		})
	case "restart", "stop", "start":
		return withName(arg(1), func(n string) error { return passthrough(args[0], n) })
	case "rm":
		return withName(arg(1), func(n string) error { return passthrough("rm", "-f", n) })
	case "top", "stats":
		return passthrough("stats")
	case "events":
		return cliEvents()
	case "up":
		return passthrough("compose", "up", "-d")
	case "down":
		return passthrough("compose", "down")
	case "watch":
		return cliWatch()
	case "images":
		return passthrough("images")
	case "clean":
		return cliClean()
	case "on":
		e := engineInfo()
		if e.Up {
			fmt.Println("● движок уже работает")
			return nil
		}
		fmt.Println("запускаю", engineName(e.Context)+"…")
		if err := startEngine(e.Context); err != nil {
			return err
		}
		fmt.Println("● движок запущен")
	case "off":
		if err := stopEngine(engineInfo().Context); err != nil {
			return err
		}
		fmt.Println("○ движок выключен, память свободна")
	case "guide":
		return guide()
	default:
		return fmt.Errorf("не знаю «%s» — orbstack help", args[0])
	}
	return nil
}

// ensureEngine: движок выключен — запустить и дождаться, а не падать с «failed to connect».
func ensureEngine() error {
	e := engineInfo()
	if e.Up {
		return nil
	}
	fmt.Fprintln(os.Stderr, "запускаю "+engineName(e.Context)+"…")
	return startEngine(e.Context)
}

// withName: имя не указано — выбор из списка контейнеров (fzf, если есть).
func withName(name string, f func(string) error) error {
	if name != "" {
		return f(name)
	}
	cs, err := listContainers()
	if err != nil {
		return err
	}
	if len(cs) == 0 {
		return fmt.Errorf("контейнеров нет — orbstack run")
	}
	var lines []string
	for _, c := range cs {
		lines = append(lines, fmt.Sprintf("%s\t%s\t%s", c.Name, c.Status, c.Image))
	}
	if _, err := exec.LookPath("fzf"); err != nil {
		return fmt.Errorf("укажи имя: %s", strings.Join(names(cs), ", "))
	}
	cmd := exec.Command("fzf", "--height=40%", "--prompt=контейнер ❯ ", "--delimiter=\t",
		"--preview", "docker logs --tail 40 {1} 2>&1", "--preview-window=down,45%,wrap")
	cmd.Stdin, cmd.Stderr = strings.NewReader(strings.Join(lines, "\n")), os.Stderr
	out, err := cmd.Output()
	if err != nil {
		return nil // esc
	}
	picked, _, _ := strings.Cut(strings.TrimSpace(string(out)), "\t")
	return f(picked)
}

func names(cs []Container) []string {
	out := make([]string, len(cs))
	for i, c := range cs {
		out[i] = c.Name
	}
	return out
}

// passthrough запускает docker прямо в этом терминале.
func passthrough(args ...string) error {
	cmd := exec.Command("docker", args...)
	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
	return cmd.Run()
}

func printPS() error {
	cs, err := listContainers()
	if err != nil {
		return err
	}
	tw := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintln(tw, "ИМЯ\tСОСТОЯНИЕ\tПОРТЫ\tПРОЕКТ")
	for _, c := range cs {
		fmt.Fprintf(tw, "%s\t%s\t%s\t%s\n", c.Name, c.Status, c.Ports, c.Project)
	}
	return tw.Flush()
}

func cliRun(name string) error {
	if name == "" {
		tw := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
		for _, t := range templates {
			fmt.Fprintf(tw, "%s\t%s\n", t.Name, t.About)
		}
		tw.Flush()
		fmt.Println("\norbstack run <шаблон> покажет команду docker run и спросит перед запуском.")
		return nil
	}
	t, ok := findTemplate(name)
	if !ok {
		return fmt.Errorf("нет шаблона «%s» — orbstack run покажет список", name)
	}
	fmt.Println(t.Command())
	if !askYes("запустить?") {
		return nil
	}
	args, _ := dockerArgs(t.Command())
	return passthrough(args...)
}

func cliEvents() error {
	fmt.Println("события контейнеров вживую · ctrl+c — выход")
	for e := range streamEvents(context.Background()) {
		fmt.Printf("%s  %-10s %s\n", e.Time.Format("15:04:05"), e.Action, e.Name)
	}
	return nil
}

func cliWatch() error {
	file := composeFile()
	if file == "" {
		return fmt.Errorf("в этой папке нет compose-файла — живая сборка работает в compose-проекте")
	}
	data, err := os.ReadFile(file)
	if err != nil {
		return err
	}
	missing, err := missingWatch(data)
	if err != nil {
		return err
	}
	if len(missing) > 0 {
		fmt.Printf("Чтобы %s пересобирался при изменении кода, в %s нужен блок:\n\n%s\n\n", strings.Join(missing, ", "), file, watchSnippet)
		if !askYes("добавить?") {
			return nil
		}
		if err := addWatchToFile(file, missing); err != nil {
			return err
		}
		fmt.Println("✓ добавлено в", file)
	}
	if err := ensureEngine(); err != nil {
		return err
	}
	fmt.Println("слежу за кодом: сохранил — пересборка и перезапуск · ctrl+c — перестать")
	return passthrough("compose", "watch")
}

func cliClean() error {
	_ = passthrough("system", "df")
	fmt.Println("\nубрать висячие образы и кэш сборки старше недели (контейнеры и тома не трогаются)")
	if !askYes("убрать?") {
		return nil
	}
	if err := passthrough("image", "prune", "-f"); err != nil {
		return err
	}
	return passthrough("builder", "prune", "-f", "--filter", "until=168h")
}

// guide показывает docs/docker.ru.md из dotfiles.
func guide() error {
	dir := os.Getenv("DOTFILES")
	if dir == "" {
		home, _ := os.UserHomeDir()
		dir = filepath.Join(home, "dotfiles")
	}
	file := filepath.Join(dir, "docs", "docker.ru.md")
	viewer, args := "less", []string{"-R", file}
	if _, err := exec.LookPath("bat"); err == nil {
		viewer, args = "bat", []string{"-l", "md", "--style=plain", "--paging=always", file}
	}
	cmd := exec.Command(viewer, args...)
	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
	return cmd.Run()
}

func askYes(q string) bool {
	fmt.Print(q + " [y/N] ")
	line, _ := bufio.NewReader(os.Stdin).ReadString('\n')
	return strings.EqualFold(strings.TrimSpace(line), "y")
}
