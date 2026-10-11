package main

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// Palette: near-black base, violet → blue accent, saturated status colors.
var (
	cAccent = lipgloss.Color("#a855f7")
	cBlue   = lipgloss.Color("#3b82f6")
	cText   = lipgloss.Color("#f0f0f0")
	cSubtle = lipgloss.Color("#a0a0a0")
	cMuted  = lipgloss.Color("#666666")
	cRed    = lipgloss.Color("#ef4444")
	cGold   = lipgloss.Color("#eab308")
	cSelBg  = lipgloss.Color("#1c1c1c")
	cBorder = lipgloss.Color("#3a3a3a")

	sText   = lipgloss.NewStyle().Foreground(cText)
	sSubtle = lipgloss.NewStyle().Foreground(cSubtle)
	sMuted  = lipgloss.NewStyle().Foreground(cMuted)
	sAccent = lipgloss.NewStyle().Foreground(cAccent)
	sBlue   = lipgloss.NewStyle().Foreground(cBlue)
	sRed    = lipgloss.NewStyle().Foreground(cRed)
	sGold   = lipgloss.NewStyle().Foreground(cGold)
	sKey    = lipgloss.NewStyle().Foreground(cAccent).Bold(true)

	sPane = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).BorderForeground(cBorder).Padding(0, 1)
	sBox  = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).BorderForeground(cAccent).Padding(0, 1)
)

// logo is built from 5×5 glyphs; every pixel is drawn two cells wide so it looks square
var glyphs = map[rune][5]string{
	'b': {"#### ", "#   #", "#### ", "#   #", "#### "},
	'e': {"#####", "#    ", "#### ", "#    ", "#####"},
	'r': {"#### ", "#   #", "#### ", "#  # ", "#   #"},
	't': {"#####", "  #  ", "  #  ", "  #  ", "  #  "},
	'h': {"#   #", "#   #", "#####", "#   #", "#   #"},
}

var logo = func() []string {
	rows := make([]string, 5)
	for i, ch := range "berth" {
		for r := range rows {
			if i > 0 {
				rows[r] += " "
			}
			rows[r] += glyphs[ch][r]
		}
	}
	return rows
}()

// banner draws the logo with a horizontal violet → blue gradient and paint drips below.
func banner() string {
	w := len(logo[0])
	cols := gradient("#a855f7", "#3b82f6", w)
	var b strings.Builder
	for _, row := range logo {
		b.WriteString("  ")
		for i, ch := range row {
			if ch == '#' {
				b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color(cols[i])).Render("██"))
			} else {
				b.WriteString("  ")
			}
		}
		b.WriteByte('\n')
	}
	shades := []string{"▓▓", "▒▒", "░░"}
	bottom := logo[len(logo)-1]
	for k := 1; k <= 3; k++ {
		b.WriteString("  ")
		for i, ch := range bottom {
			drip := (i*7 + i/3*5) % 4 // drip length from the column, not random: stable between frames
			if ch == '#' && k <= drip {
				b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color(dim(cols[i], 4-k, 4))).Render(shades[k-1]))
			} else {
				b.WriteString("  ")
			}
		}
		if k < 3 {
			b.WriteByte('\n')
		}
	}
	return b.String()
}

// title is the one-line header for short terminals.
func title() string {
	cols := gradient("#a855f7", "#3b82f6", 5)
	var b strings.Builder
	for i, ch := range "berth" {
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color(cols[i])).Bold(true).Render(string(ch)))
	}
	return b.String()
}

func gradient(from, to string, n int) []string {
	r1, g1, b1 := hexRGB(from)
	r2, g2, b2 := hexRGB(to)
	out := make([]string, n)
	for i := range out {
		t := 0.0
		if n > 1 {
			t = float64(i) / float64(n-1)
		}
		out[i] = fmt.Sprintf("#%02x%02x%02x", lerp(r1, r2, t), lerp(g1, g2, t), lerp(b1, b2, t))
	}
	return out
}

func dim(hex string, num, den int) string {
	r, g, b := hexRGB(hex)
	return fmt.Sprintf("#%02x%02x%02x", r*num/den, g*num/den, b*num/den)
}

func hexRGB(h string) (int, int, int) {
	var r, g, b int
	fmt.Sscanf(strings.TrimPrefix(h, "#"), "%02x%02x%02x", &r, &g, &b)
	return r, g, b
}

func lerp(a, b int, t float64) int { return a + int(float64(b-a)*t+0.5) }

// dot is the state marker in the table.
func dot(c Container) string {
	switch {
	case strings.Contains(c.Status, "unhealthy"):
		return sRed.Render("●")
	case c.State == "running":
		return sBlue.Render("●")
	case c.State == "restarting" || c.State == "dead":
		return sRed.Render("●")
	case c.State == "created" || c.State == "paused":
		return sGold.Render("●")
	}
	return sMuted.Render("○")
}
