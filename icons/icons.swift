#!/usr/bin/env swift
// ============================================================
//   Иконки приложений в стиле Rosé Pine
//   swift icons.swift preview <папка>  — только PNG для просмотра
//   swift icons.swift apply            — поставить иконки (root-приложения: через sudo)
//   swift icons.swift reset            — вернуть родные иконки
//   После обновления приложения иконка сбрасывается — просто запусти apply снова.
// ============================================================

import AppKit
import CoreText

struct App { let path: String; let glyph: String; let color: NSColor }

func hex(_ s: String) -> NSColor {
    let v = Int(s, radix: 16)!
    return NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255,
                   green: CGFloat((v >> 8) & 0xff) / 255,
                   blue: CGFloat(v & 0xff) / 255, alpha: 1)
}

let base = hex("191724"), surface = hex("26233a")
let iris = hex("c4a7e7"), rose = hex("ebbcba"), foam = hex("9ccfd8")
let gold = hex("f6c177"), love = hex("eb6f92")

let apps: [App] = [
    App(path: "/Applications/Visual Studio Code.app", glyph: "\u{F0A1E}", color: foam),
    App(path: "/Applications/Google Chrome.app",      glyph: "\u{F268}",  color: gold),
    App(path: "/Applications/Telegram.app",           glyph: "\u{F2C6}",  color: iris),
    App(path: "/Applications/Discord.app",            glyph: "\u{F066F}", color: rose),
    App(path: "/Applications/Spotify.app",            glyph: "\u{F1BC}",  color: love),
    App(path: "/Applications/Docker.app",             glyph: "\u{F0868}", color: foam),
]

let fontName = "JetBrainsMono Nerd Font"

func render(_ app: App) -> NSImage {
    let size: CGFloat = 1024
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    defer { img.unlockFocus() }

    // Сетка иконок macOS: тело 824×824 по центру, скругление ~185
    let body = NSRect(x: 100, y: 100, width: 824, height: 824)
    let shape = NSBezierPath(roundedRect: body, xRadius: 185, yRadius: 185)

    // тень, как у системных иконок
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.shadowBlurRadius = 24
    shadow.shadowOffset = NSSize(width: 0, height: -10)
    shadow.set()
    base.setFill(); shape.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGradient(starting: surface, ending: base)!.draw(in: shape, angle: -90)

    // обводка iris → rose
    NSGraphicsContext.saveGraphicsState()
    let ring = NSBezierPath(roundedRect: body.insetBy(dx: 5, dy: 5), xRadius: 180, yRadius: 180)
    ring.lineWidth = 10
    let stroked = ring.cgPath.copy(strokingWithWidth: 10, lineCap: .round, lineJoin: .round, miterLimit: 10)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.addPath(stroked); ctx.clip()
    NSGradient(starting: iris, ending: rose)!.draw(in: body, angle: -45)
    NSGraphicsContext.restoreGraphicsState()

    // логотип, точно по центру по реальным границам глифа
    guard let font = NSFont(name: fontName, size: 440) else { fatalError("нет шрифта \(fontName)") }
    let str = NSAttributedString(string: app.glyph, attributes: [.font: font, .foregroundColor: app.color])
    let line = CTLineCreateWithAttributedString(str)
    let b = CTLineGetImageBounds(line, ctx)
    guard b.width > 1 else { fatalError("в шрифте нет глифа для \(app.path)") }
    ctx.textPosition = CGPoint(x: size / 2 - b.midX, y: size / 2 - b.midY)
    CTLineDraw(line, ctx)
    return img
}

let args = CommandLine.arguments
let mode = args.count > 1 ? args[1] : "preview"

for app in apps {
    let name = (app.path as NSString).lastPathComponent
    guard FileManager.default.fileExists(atPath: app.path) else { print("нет: \(name)"); continue }
    switch mode {
    case "preview":
        let dir = args.count > 2 ? args[2] : "."
        let rep = NSBitmapImageRep(data: render(app).tiffRepresentation!)!
        let out = "\(dir)/\(name).png"
        try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
        print("png: \(out)")
    case "apply":
        let ok = NSWorkspace.shared.setIcon(render(app), forFile: app.path, options: [])
        print(ok ? "✓ \(name)" : "✗ \(name) — не вышло: дай терминалу «Управление приложениями», для root-приложений ещё sudo")
    case "reset":
        let ok = NSWorkspace.shared.setIcon(nil, forFile: app.path, options: [])
        print(ok ? "↺ \(name)" : "✗ \(name) — не вышло: дай терминалу «Управление приложениями», для root-приложений ещё sudo")
    default:
        print("usage: icons.swift preview <dir> | apply | reset")
    }
}
