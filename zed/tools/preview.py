#!/usr/bin/env python3
# ============================================================
#   Превью тем Dev Night / Dev Day без запуска Zed: окно «как в Zed» (дерево файлов с
#   иконками, вкладки, Go-код, статус-бар), цвета — прямо из themes/dev-night.json.
#     python3 zed/tools/preview.py            → docs/zed-themes.png (обе темы рядом)
#   Рисует встроенный в macOS WebKit (icons/html2png.swift), окон не открывает.
# ============================================================
import json, os, re, subprocess, tempfile, html

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
OUT = os.path.join(ROOT, "docs", "zed-themes.png")
RENDER = os.path.join(ROOT, "icons", "html2png.swift")

CODE = '''package main

import (
\t"log"
\t"net/http"

\t"github.com/gin-gonic/gin"
)

// Server отдаёт API логов.
type Server struct {
\tdb   *Store
\tport int
}

func (s *Server) Health(c *gin.Context) {
\tc.JSON(http.StatusOK, gin.H{"status": "ok", "uptime": 42})
}

func main() {
\ts := &Server{port: 8080}
\tr := gin.Default()
\tr.GET("/health", s.Health)
\tif err := r.Run(":8080"); err != nil {
\t\tlog.Fatal(err)
\t}
}'''

KEYWORDS = r"package|import|type|struct|func|return|if|else|for|range|var|const|go|defer|nil|true|false"
TOKEN = re.compile(
    r"(?P<comment>//[^\n]*)|(?P<string>\"(?:\\.|[^\"\\])*\")|(?P<number>\b\d+\b)"
    rf"|(?P<keyword>\b(?:{KEYWORDS})\b)|(?P<builtin>\b(?:int|string|error|bool)\b)"
    r"|(?P<type>\b[A-Z]\w*(?=\s*(?:struct|\{|\)|$)))|(?P<func>\b\w+(?=\())"
    r"|(?P<field>(?<=\.)\w+)|(?P<op>:=|!=|==|&|\*)|(?P<punct>[{}()\[\],.:;])|(?P<ident>\w+)|(?P<ws>\s+)|(?P<other>.)",
)
SCOPE = {"comment": "comment", "string": "string", "number": "number", "keyword": "keyword",
         "builtin": "type.builtin", "type": "type", "func": "function", "field": "property",
         "op": "operator", "punct": "punctuation", "ident": "variable"}

def highlight(theme):
    syn = theme["style"]["syntax"]
    def color(scope):
        return (syn.get(scope) or {}).get("color") or theme["style"]["editor.foreground"]
    lines = []
    for line in CODE.split("\n"):
        out = []
        for m in TOKEN.finditer(line.replace("\t", "    ")):
            kind, text = m.lastgroup, html.escape(m.group())
            if kind in ("ws", "other"):
                out.append(text)
                continue
            st = syn.get(SCOPE[kind]) or {}
            italic = "font-style:italic;" if st.get("font_style") == "italic" else ""
            out.append(f'<span style="color:{color(SCOPE[kind])};{italic}">{text}</span>')
        lines.append("".join(out) or "&nbsp;")
    return lines

def icon(name):
    return f'<img src="file://{HERE}/../dev-night-icons/icons/{name}.svg">'

def window(theme):
    s = theme["style"]
    g = lambda k: s.get(k) or s["background"]
    lines = highlight(theme)
    active = 16  # строка с курсором
    code = "".join(
        f'<div class="ln" style="background:{g("editor.active_line.background") if i == active else "transparent"}">'
        f'<span class="num" style="color:{g("editor.active_line_number") if i == active else g("editor.line_number")}">{i}</span>'
        f'<span>{l}{"<i class=cur style=background:" + s["players"][0]["cursor"] + "></i>" if i == active else ""}</span></div>'
        for i, l in enumerate(lines, 1))
    tree = [("folder-open", "logsence", 0, False), ("folder", "cmd", 1, False), ("folder", "internal", 1, False),
            ("folder", "migrations", 1, False), ("docker", "Dockerfile", 1, False), ("compose", "docker-compose.yml", 1, False),
            ("env", ".env.example", 1, False), ("gomod", "go.mod", 1, False), ("go", "main.go", 1, True),
            ("make", "Makefile", 1, False), ("markdown", "README.md", 1, False)]
    rows = "".join(
        f'<div class="row" style="padding-left:{10 + d * 14}px;{"background:" + g("element.selected") + ";color:" + s["text"] if sel else ""}">'
        f'{icon(ic)}<span>{n}</span></div>' for ic, n, d, sel in tree)
    return f'''
<div class="win" style="background:{g('background')};color:{s['text']};border-color:{g('border')}">
  <div class="title" style="background:{g('title_bar.background')};border-color:{g('border')};color:{g('text.muted')}">
    <span class="dots"><b></b><b></b><b></b></span><span>logsence</span><span style="color:{s['text.accent']}">main</span>
    <span class="badge" style="color:{s['text.accent']}">{theme['name']}</span></div>
  <div class="body">
    <div class="tree" style="background:{g('panel.background')};border-color:{g('border')};color:{g('text.muted')}">{rows}</div>
    <div class="main">
      <div class="tabs" style="background:{g('tab_bar.background')};border-color:{g('border')}">
        <div class="tab" style="background:{g('tab.active_background')};color:{s['text']};border-color:{g('border')}">{icon('go')}main.go</div>
        <div class="tab" style="color:{g('text.muted')};border-color:{g('border')}">{icon('compose')}docker-compose.yml</div>
        <div class="tab" style="color:{g('text.muted')};border-color:{g('border')}">{icon('gomod')}go.mod</div></div>
      <div class="code" style="background:{g('editor.background')}">{code}</div>
    </div></div>
  <div class="status" style="background:{g('status_bar.background')};border-color:{g('border')};color:{g('text.muted')}">
    <span style="color:{s['text.accent']}">● gopls</span><span>Go</span><span>17:5</span>
    <span style="color:{s.get('success', s['text.accent'])}">✓ 0 проблем</span></div>
</div>'''

family = json.load(open(os.path.join(HERE, "..", "dev-night-theme", "themes", "dev-night.json")))
page = f'''<!doctype html><meta charset="utf-8"><style>
body{{margin:0;padding:28px;background:#6b6b78;display:flex;gap:28px;font:13px/1 -apple-system,sans-serif}}
.win{{width:820px;border:1px solid;border-radius:12px;overflow:hidden;box-shadow:0 20px 50px #0006}}
.title{{height:34px;display:flex;align-items:center;gap:14px;padding:0 14px;border-bottom:1px solid}}
.dots b{{display:inline-block;width:12px;height:12px;border-radius:50%;margin-right:7px;background:#ff5f57}}
.dots b:nth-child(2){{background:#febc2e}}.dots b:nth-child(3){{background:#28c840}}
.badge{{margin-left:auto;font-weight:600}}
.body{{display:flex;height:560px}}
.tree{{width:210px;border-right:1px solid;padding-top:8px}}
.row{{display:flex;align-items:center;gap:7px;height:26px}} .row img,.tab img{{width:15px;height:15px}}
.main{{flex:1;display:flex;flex-direction:column;min-width:0}}
.tabs{{display:flex;height:34px;border-bottom:1px solid}}
.tab{{display:flex;align-items:center;gap:7px;padding:0 14px;border-right:1px solid}}
.code{{flex:1;padding-top:8px;font:13px/20px "JetBrainsMono Nerd Font","JetBrains Mono",monospace;white-space:pre}}
.ln{{display:flex}} .num{{width:44px;text-align:right;padding-right:16px;flex:none}}
.cur{{display:inline-block;width:2px;height:16px;vertical-align:-3px}}
.status{{height:26px;display:flex;gap:18px;align-items:center;padding:0 14px;border-top:1px solid;font-size:12px}}
</style>{"".join(window(t) for t in family["themes"])}'''

with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
    f.write(page)
subprocess.run(["swift", RENDER, f.name, OUT, "1760", "700"], check=True, capture_output=True)
os.unlink(f.name)
print("→", OUT)
