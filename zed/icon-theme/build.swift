#!/usr/bin/env swift
// ============================================================
//   Тема иконок Zed «Dev Night Icons» — те же значки Nerd Font, что в терминале
//   (eza / ls), в цветах темы Dev Night. docker-compose / compose — красные.
//
//   swift build.swift   — пересобрать icons/*.svg и icon_themes/dev-night-icons.json
//   Значки берутся из шрифта JetBrainsMono Nerd Font и сохраняются векторными SVG.
// ============================================================

import AppKit
import CoreText

let dir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().path
let font = CTFontCreateWithName("JetBrainsMono Nerd Font" as CFString, 1000, nil)

// палитра Dev Night (zed/themes/dev-night.json)
let violet = "#a855f7", blue = "#3b82f6", sky = "#0ea5e9", pink = "#ec4899", gold = "#eab308"
let orange = "#f97316", peri = "#818cf8", lilac = "#c084fc", muted = "#858aa3", red = "#ef4444"

// имя иконки → (кандидаты-глифы по порядку, цвет). Берётся первый, который есть в шрифте
let icons: [(String, [UInt32], String)] = [
    ("folder",        [0xF024B],          violet),
    ("folder-open",   [0xF0770],          violet),
    ("chevron-right", [0xF0142],          muted),
    ("chevron-down",  [0xF0140],          muted),
    ("default",       [0xF0214],          muted),
    ("go",            [0xF07D3, 0xE627],  sky),
    ("gomod",         [0xF03D7],          lilac),
    ("markdown",      [0xF0354],          blue),
    ("json",          [0xF0626],          gold),
    ("yaml",          [0xF022E, 0xF0219], pink),
    ("toml",          [0xE615],           orange),
    ("docker",        [0xF0868],          blue),
    ("compose",       [0xF0868],          red),
    ("env",           [0xF0306],          gold),
    ("sql",           [0xF01BC],          lilac),
    ("shell",         [0xF018D],          peri),
    ("make",          [0xE673, 0xF1322],  orange),
    ("git",           [0xF02A2],          orange),
    ("python",        [0xF0320],          gold),
    ("javascript",    [0xF031E],          gold),
    ("typescript",    [0xF06E6],          blue),
    ("html",          [0xF031D],          orange),
    ("css",           [0xF031C],          blue),
    ("image",         [0xF021F],          pink),
    ("lock",          [0xF033E],          muted),
    ("text",          [0xF0219],          muted),
    ("license",       [0xF0FC3, 0xF0219], gold),
    ("swift",         [0xF06E5],          orange),
    ("proto",         [0xF0169, 0xF0219], peri),
    ("csv",           [0xF021B, 0xF0219], gold),
]

// глиф → SVG-путь, вписанный в 16×16 с полями
func svgPath(_ cp: UInt32) -> String? {
    var units = Array(String(UnicodeScalar(cp)!).utf16)
    var glyphs = [CGGlyph](repeating: 0, count: units.count)
    guard CTFontGetGlyphsForCharacters(font, &units, &glyphs, units.count), glyphs[0] != 0,
          let path = CTFontCreatePathForGlyph(font, glyphs[0], nil) else { return nil }
    let b = path.boundingBoxOfPath
    guard b.width > 0, b.height > 0 else { return nil }
    let box: CGFloat = 13, scale = box / max(b.width, b.height)
    let ox = (16 - b.width * scale) / 2, oy = (16 - b.height * scale) / 2
    func pt(_ p: CGPoint) -> String {   // y во шрифте вверх, в SVG вниз
        String(format: "%.2f %.2f", (p.x - b.minX) * scale + ox, 16 - ((p.y - b.minY) * scale + oy))
    }
    var d = ""
    path.applyWithBlock { e in
        let p = e.pointee.points
        switch e.pointee.type {
        case .moveToPoint:         d += "M\(pt(p[0]))"
        case .addLineToPoint:      d += "L\(pt(p[0]))"
        case .addQuadCurveToPoint: d += "Q\(pt(p[0])) \(pt(p[1]))"
        case .addCurveToPoint:     d += "C\(pt(p[0])) \(pt(p[1])) \(pt(p[2]))"
        case .closeSubpath:        d += "Z"
        @unknown default: break
        }
    }
    return d
}

let fm = FileManager.default
try? fm.createDirectory(atPath: "\(dir)/icons", withIntermediateDirectories: true)
try? fm.createDirectory(atPath: "\(dir)/icon_themes", withIntermediateDirectories: true)

for (name, candidates, color) in icons {
    guard let d = candidates.lazy.compactMap(svgPath).first else { fatalError("нет глифа для \(name)") }
    let svg = """
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16"><path fill="\(color)" d="\(d)"/></svg>

    """
    try! svg.write(toFile: "\(dir)/icons/\(name).svg", atomically: true, encoding: .utf8)
}

// ─── какие файлы какой иконкой ───
var suffixes: [String: String] = [:]
for (icon, exts) in [
    ("go", ["go"]), ("gomod", ["sum"]), ("markdown", ["md", "markdown", "mdx"]),
    ("json", ["json", "jsonc", "json5"]), ("yaml", ["yml", "yaml"]), ("toml", ["toml"]),
    ("env", ["env"]), ("sql", ["sql", "psql"]), ("shell", ["sh", "zsh", "bash", "fish"]),
    ("python", ["py", "pyi"]), ("javascript", ["js", "mjs", "cjs", "jsx"]), ("typescript", ["ts", "tsx", "mts"]),
    ("html", ["html", "htm", "tmpl", "gohtml"]), ("css", ["css", "scss", "sass"]),
    ("image", ["png", "jpg", "jpeg", "gif", "svg", "webp", "ico", "heic"]), ("lock", ["lock"]),
    ("text", ["txt", "log"]), ("swift", ["swift"]), ("proto", ["proto"]), ("csv", ["csv", "tsv"]),
    ("docker", ["dockerfile"]), ("make", ["mk"]),
] { for e in exts { suffixes[e] = icon } }

var stems: [String: String] = [:]
for n in ["Dockerfile", "Containerfile", ".dockerignore"] { stems[n] = "docker" }
for base in ["docker-compose", "compose"] {
    for variant in ["", ".override", ".dev", ".development", ".prod", ".production", ".local", ".test", ".ci", ".staging"] {
        for ext in ["yml", "yaml"] { stems["\(base)\(variant).\(ext)"] = "compose" }
    }
}
for n in ["go.mod", "go.sum", "go.work", "go.work.sum"] { stems[n] = "gomod" }
for n in ["Makefile", "makefile", "GNUmakefile", "Justfile", "justfile"] { stems[n] = "make" }
for n in [".gitignore", ".gitattributes", ".gitmodules", ".gitkeep"] { stems[n] = "git" }
for n in [".env", ".env.local", ".env.example", ".env.sample", ".env.dev", ".env.prod", ".envrc"] { stems[n] = "env" }
for n in ["LICENSE", "LICENSE.md", "LICENSE.txt"] { stems[n] = "license" }
for n in [".air.toml", ".golangci.yml", ".golangci.yaml"] { stems[n] = "toml" }
for n in ["package-lock.json", "uv.lock", "Cargo.lock", "yarn.lock"] { stems[n] = "lock" }

var fileIcons: [String: [String: String]] = [:]
for (name, _, _) in icons where !["folder", "folder-open", "chevron-right", "chevron-down"].contains(name) {
    fileIcons[name] = ["path": "./icons/\(name).svg"]
}

let theme: [String: Any] = [
    "$schema": "https://zed.dev/schema/icon_themes/v0.2.0.json",
    "name": "Dev Night Icons",
    "author": "dotfiles",
    "themes": [[
        "name": "Dev Night Icons",
        "appearance": "dark",
        "directory_icons": ["collapsed": "./icons/folder.svg", "expanded": "./icons/folder-open.svg"],
        "chevron_icons": ["collapsed": "./icons/chevron-right.svg", "expanded": "./icons/chevron-down.svg"],
        "file_stems": stems,
        "file_suffixes": suffixes,
        "file_icons": fileIcons,
    ]],
]
let json = try! JSONSerialization.data(withJSONObject: theme, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
try! json.write(to: URL(fileURLWithPath: "\(dir)/icon_themes/dev-night-icons.json"))
print("иконок: \(icons.count), расширений: \(suffixes.count), имён файлов: \(stems.count)")
