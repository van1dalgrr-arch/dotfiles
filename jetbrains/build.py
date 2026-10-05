#!/usr/bin/env python3
# ============================================================
#   Dev Night / Dev Day для GoLand (и любой IDE JetBrains) — цветовые схемы редактора .icls,
#   собираются из Zed-темы (zed/dev-night-theme), чтобы цвета везде совпадали.
#     python3 jetbrains/build.py   →  jetbrains/Dev Night.icls, jetbrains/Dev Day.icls
#                                     + jetbrains/dist/dev-night-theme-<версия>.jar — плагин-тема
#                                       (интерфейс IDE + схема редактора) для Marketplace / Install from Disk
#   В .icls нет прозрачности: полупрозрачные цвета Zed смешиваются с фоном.
# ============================================================
import json, os, zipfile
from xml.sax.saxutils import quoteattr

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "zed", "dev-night-theme", "themes", "dev-night.json")

def blend(color, bg):
    """#rrggbb или #rrggbbaa → rrggbb (альфа смешивается с фоном)."""
    c = color.lstrip("#")
    if len(c) == 6:
        return c.lower()
    a = int(c[6:8], 16) / 255
    fg = [int(c[i:i + 2], 16) for i in (0, 2, 4)]
    b = [int(bg.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
    return "".join(f"{round(f * a + k * (1 - a)):02x}" for f, k in zip(fg, b))

def scheme(t):
    s, syn = t["style"], t["style"]["syntax"]
    bg = s["editor.background"]
    col = lambda k: blend(s[k], bg)
    sx = lambda k: syn[k]["color"]
    attrs = {}

    def attr(name, fg=None, back=None, font=0, effect=None, effect_type=None):
        v = {}
        if fg: v["FOREGROUND"] = blend(fg, bg)
        if back: v["BACKGROUND"] = blend(back, bg)
        if font: v["FONT_TYPE"] = str(font)          # 1 жирный, 2 курсив, 3 оба
        if effect: v["EFFECT_COLOR"] = blend(effect, bg)
        if effect_type is not None: v["EFFECT_TYPE"] = str(effect_type)  # 1 подчёркн., 2 волна, 3 зачёркн.
        attrs[name] = v

    italic = lambda k: 2 if syn[k].get("font_style") == "italic" else 0

    attr("TEXT", s["text"], bg)
    # общие для всех языков (Go наследует их)
    attr("DEFAULT_KEYWORD", sx("keyword"))
    attr("DEFAULT_STRING", sx("string"))
    attr("DEFAULT_VALID_STRING_ESCAPE", sx("string.escape"))
    attr("DEFAULT_INVALID_STRING_ESCAPE", s["error"], effect=s["error"], effect_type=2)
    attr("DEFAULT_NUMBER", sx("number"))
    attr("DEFAULT_CONSTANT", sx("constant"))
    attr("DEFAULT_PREDEFINED_SYMBOL", sx("constant.builtin"))
    for k in ("DEFAULT_LINE_COMMENT", "DEFAULT_BLOCK_COMMENT"):
        attr(k, sx("comment"), font=italic("comment"))
    attr("DEFAULT_DOC_COMMENT", sx("comment.doc"), font=italic("comment.doc"))
    attr("DEFAULT_DOC_COMMENT_TAG", sx("keyword"), font=2)
    attr("DEFAULT_FUNCTION_DECLARATION", sx("function"))
    attr("DEFAULT_FUNCTION_CALL", sx("function"))
    attr("DEFAULT_INSTANCE_METHOD", sx("function.method"))
    attr("DEFAULT_STATIC_METHOD", sx("function"))
    for k in ("DEFAULT_CLASS_NAME", "DEFAULT_CLASS_REFERENCE", "DEFAULT_INTERFACE_NAME"):
        attr(k, sx("type"))
    for k in ("DEFAULT_INSTANCE_FIELD", "DEFAULT_STATIC_FIELD", "DEFAULT_ATTRIBUTE"):
        attr(k, sx("property"))
    for k in ("DEFAULT_LOCAL_VARIABLE", "DEFAULT_GLOBAL_VARIABLE", "DEFAULT_IDENTIFIER", "DEFAULT_REASSIGNED_LOCAL_VARIABLE"):
        attr(k, sx("variable"))
    attr("DEFAULT_PARAMETER", sx("variable.parameter"))
    attr("DEFAULT_OPERATION_SIGN", sx("operator"))
    for k in ("DEFAULT_BRACES", "DEFAULT_BRACKETS", "DEFAULT_PARENTHS"):
        attr(k, sx("punctuation.bracket"))
    for k in ("DEFAULT_COMMA", "DEFAULT_DOT", "DEFAULT_SEMICOLON"):
        attr(k, sx("punctuation"))
    attr("DEFAULT_LABEL", sx("label"))
    attr("DEFAULT_METADATA", sx("attribute"))
    attr("DEFAULT_TAG", sx("tag"))
    attr("DEFAULT_ENTITY", sx("constant"))
    # Go в GoLand
    attr("GO_PACKAGE", sx("namespace"))
    attr("GO_BUILTIN_FUNCTION_CALL", sx("function.builtin"))
    attr("GO_BUILTIN_TYPE_REFERENCE", sx("type.builtin"))
    attr("GO_TYPE_REFERENCE", sx("type"))
    attr("GO_BUILTIN_CONSTANT", sx("constant.builtin"))
    attr("GO_METHOD_RECEIVER", sx("variable.parameter"))
    # Markdown
    attr("MARKDOWN_HEADER_LEVEL_1", sx("title"), font=1)
    attr("MARKDOWN_HEADER_LEVEL_2", sx("title"), font=1)
    attr("MARKDOWN_CODE_SPAN", sx("string"))
    attr("MARKDOWN_LINK_TEXT", s["link_text.hover"])
    # подсветка ошибок, поиска, ссылок
    attr("ERRORS_ATTRIBUTES", effect=s["error"], effect_type=2)
    attr("WARNING_ATTRIBUTES", back=s["warning.background"], effect=s["warning"], effect_type=2)
    attr("WRONG_REFERENCES_ATTRIBUTES", s["error"])
    attr("NOT_USED_ELEMENT_ATTRIBUTES", sx("comment"))
    attr("DEPRECATED_ATTRIBUTES", effect=sx("comment"), effect_type=3)
    attr("TODO_DEFAULT_ATTRIBUTES", s["warning"], font=3)
    attr("HYPERLINK_ATTRIBUTES", s["link_text.hover"], effect=s["link_text.hover"], effect_type=1)
    attr("SEARCH_RESULT_ATTRIBUTES", back=s["search.match_background"])
    attr("TEXT_SEARCH_RESULT_ATTRIBUTES", back=s["search.match_background"])
    attr("IDENTIFIER_UNDER_CARET_ATTRIBUTES", back=s["editor.document_highlight.read_background"])
    attr("WRITE_IDENTIFIER_UNDER_CARET_ATTRIBUTES", back=s["editor.document_highlight.write_background"])
    attr("MATCHED_BRACE_ATTRIBUTES", back=s["editor.document_highlight.bracket_background"], font=1)
    attr("INLAY_DEFAULT", s["hint"], s["hint.background"])
    # diff и git
    attr("DIFF_INSERTED", back=s["created.background"])
    attr("DIFF_MODIFIED", back=s["modified.background"])
    attr("DIFF_DELETED", back=s["deleted.background"])
    # консоль (Run, тесты) — ANSI как в терминале
    for name, key in (("BLACK", "black"), ("RED", "red"), ("GREEN", "green"), ("YELLOW", "yellow"),
                      ("BLUE", "blue"), ("MAGENTA", "magenta"), ("CYAN", "cyan"), ("GRAY", "white")):
        attr(f"CONSOLE_{name}_OUTPUT", s[f"terminal.ansi.{key}"])
    attr("CONSOLE_NORMAL_OUTPUT", s["text"])
    attr("CONSOLE_ERROR_OUTPUT", s["error"])
    attr("CONSOLE_SYSTEM_OUTPUT", s["text.muted"])

    colors = {
        "CARET_COLOR": s["players"][0]["cursor"],
        "CARET_ROW_COLOR": s["editor.active_line.background"],
        "SELECTION_BACKGROUND": s["players"][0]["selection"],
        "GUTTER_BACKGROUND": s["editor.gutter.background"],
        "LINE_NUMBERS_COLOR": s["editor.line_number"],
        "LINE_NUMBER_ON_CARET_ROW_COLOR": s["editor.active_line_number"],
        "INDENT_GUIDE": s["editor.indent_guide"],
        "SELECTED_INDENT_GUIDE": s["editor.indent_guide_active"],
        "WHITESPACES": s["editor.invisible"],
        "RIGHT_MARGIN_COLOR": s["editor.wrap_guide"],
        "TEARLINE_COLOR": s["border"],
        "METHOD_SEPARATORS_COLOR": s["border"],
        "CONSOLE_BACKGROUND_KEY": bg,
        "DOCUMENTATION_COLOR": s["elevated_surface.background"],
        "ADDED_LINES_COLOR": s["created"],
        "MODIFIED_LINES_COLOR": s["modified"],
        "DELETED_LINES_COLOR": s["deleted"],
        "VISUAL_INDENT_GUIDE": s["editor.indent_guide"],
    }

    dark = t["appearance"] == "dark"
    out = [f'<scheme name={quoteattr(t["name"])} version="142" parent_scheme="{"Darcula" if dark else "Default"}">',
           "  <metaInfo>",
           '    <property name="ide">GoLand</property>',
           f'    <property name="originalScheme">{t["name"]}</property>',
           "  </metaInfo>",
           "  <colors>"]
    out += [f'    <option name="{k}" value="{blend(v, bg)}" />' for k, v in colors.items()]
    out += ["  </colors>", "  <attributes>"]
    for name, v in attrs.items():
        out.append(f'    <option name="{name}">')
        out.append("      <value>")
        out += [f'        <option name="{k}" value="{x}" />' for k, x in v.items()]
        out.append("      </value>")
        out.append("    </option>")
    out += ["  </attributes>", "</scheme>", ""]
    return "\n".join(out)

VERSION = "1.0.0"
PLUGIN_ID = "io.github.van1dalgrr.devnight"

def ui(t):
    """Цвета интерфейса IDE (новый UI) из той же темы."""
    s = t["style"]; bg = s["background"]; c = lambda k: "#" + blend(s[k], bg)
    accent = "#" + blend(s["players"][0]["cursor"], bg)
    sel = "#" + blend(s["players"][0]["selection"], bg)
    return {
        "*": {
            "background": c("background"), "foreground": c("text"),
            "infoForeground": c("text.muted"), "disabledForeground": c("text.disabled"),
            "selectionBackground": sel, "selectionForeground": c("text"),
            "selectionInactiveBackground": c("element.selected"),
            "hoverBackground": c("element.hover"), "borderColor": c("border"),
            "separatorColor": c("border"), "focusColor": accent, "focusedBorderColor": accent,
            "acceleratorForeground": c("text.muted"), "lineSeparatorColor": c("border.variant"),
        },
        "Component": {"focusColor": accent, "borderColor": c("border")},
        "MainToolbar": {"background": c("title_bar.background")},
        "MainWindow.Tab": {"selectedBackground": c("tab.active_background")},
        "ToolWindow": {"background": c("panel.background"), "Header.background": c("panel.background"),
                       "Header.inactiveBackground": c("panel.background")},
        "EditorTabs": {"background": c("tab_bar.background"), "underlinedTabBackground": c("tab.active_background"),
                       "underlineColor": accent, "inactiveUnderlineColor": c("text.muted")},
        "StatusBar": {"background": c("status_bar.background"), "borderColor": c("border")},
        "Popup": {"background": c("elevated_surface.background"), "borderColor": c("border")},
        "Tree": {"selectionBackground": sel, "selectionInactiveBackground": c("element.selected")},
        "List": {"selectionBackground": sel, "selectionInactiveBackground": c("element.selected")},
        "Button": {"default.startBackground": accent, "default.endBackground": accent,
                   "default.foreground": "#ffffff"},
        "Link": {"activeForeground": c("link_text.hover")},
        "ProgressBar": {"progressColor": accent},
        "Notification": {"background": c("elevated_surface.background")},
    }

PLUGIN_XML = f"""<idea-plugin>
  <id>{PLUGIN_ID}</id>
  <name>Dev Night Theme</name>
  <version>{VERSION}</version>
  <vendor email="van1dalgrr@gmail.com" url="https://github.com/van1dalgrr-arch/dotfiles">van1dalgrr-arch</vendor>
  <description><![CDATA[
    <p><b>Dev Night</b> (dark) and <b>Dev Day</b> (light): saturated violet and blue accents on a near-black
    or near-white background. Made for Go, readable for everything else.</p>
    <ul>
      <li>UI theme and editor color scheme in one plugin</li>
      <li>Go-aware highlighting: packages, builtins, method receivers, types</li>
      <li>Matching themes for Zed and the terminal in the same repository</li>
    </ul>
    <p>Pair Dev Night and Dev Day with <i>Settings → Appearance → Sync with OS</i>.</p>
  ]]></description>
  <change-notes><![CDATA[<p>First release: Dev Night and Dev Day.</p>]]></change-notes>
  <idea-version since-build="233"/>
  <depends>com.intellij.modules.platform</depends>
  <extensions defaultExtensionNs="com.intellij">
    <themeProvider id="dev-night" path="/themes/dev_night.theme.json"/>
    <themeProvider id="dev-day" path="/themes/dev_day.theme.json"/>
  </extensions>
</idea-plugin>
"""

# значок плагина: полумесяц в цветах темы
ICON = """<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#a855f7"/><stop offset="1" stop-color="#3b82f6"/></linearGradient></defs>
  <rect width="40" height="40" rx="9" fill="#101010"/>
  <path d="M25.5 9.5a11 11 0 1 0 5 16.6A9 9 0 0 1 25.5 9.5z" fill="url(#g)"/>
</svg>
"""

root = os.path.join(HERE, "..")
os.makedirs(os.path.join(HERE, "dist"), exist_ok=True)
jar = os.path.join(HERE, "dist", f"dev-night-theme-{VERSION}.jar")
with zipfile.ZipFile(jar, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("META-INF/plugin.xml", PLUGIN_XML)
    z.writestr("META-INF/pluginIcon.svg", ICON)
    for theme in json.load(open(SRC))["themes"]:
        icls = scheme(theme)
        path = os.path.join(HERE, f'{theme["name"]}.icls')
        open(path, "w").write(icls)
        print("→", os.path.relpath(path, root))
        slug = theme["name"].lower().replace(" ", "_")
        z.writestr(f"themes/{slug}.xml", icls)
        z.writestr(f"themes/{slug}.theme.json", json.dumps({
            "name": theme["name"], "dark": theme["appearance"] == "dark", "author": "van1dalgrr-arch",
            "editorScheme": f"/themes/{slug}.xml", "ui": ui(theme)}, indent=2))
print("→", os.path.relpath(jar, root))
