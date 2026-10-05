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
let gold = hex("f6c177"), love = hex("eb6f92"), text = hex("e0def4")

let apps: [App] = [
    App(path: "/Applications/Visual Studio Code.app", glyph: "\u{F0A1E}", color: foam),
    App(path: "/Applications/Telegram.app",           glyph: "\u{F2C6}",  color: iris),
    App(path: "/Applications/Discord.app",            glyph: "\u{F066F}", color: rose),
    App(path: "/Applications/Spotify.app",            glyph: "\u{F1BC}",  color: love),
    App(path: "/Applications/OrbStack.app",           glyph: "\u{F0868}", color: iris),
    App(path: "/Applications/Zed.app",                glyph: "Z",          color: text),
    App(path: "/Applications/ChatGPT.app",            glyph: "\u{F06A9}", color: foam),
    App(path: "/Applications/Claude.app",             glyph: "\u{F06C4}", color: rose),
    App(path: "/Applications/Яндекс Музыка.app",      glyph: "\u{F075A}", color: gold),
    App(path: "/Applications/Yaak.app",               glyph: "\u{F048A}", color: foam),   // API-клиент
    App(path: "/Applications/TablePlus.app",          glyph: "\u{F01BC}", color: iris),   // базы данных
    App(path: "/Applications/Happ.app",               glyph: "\u{F132}",  color: love),
]

let fontName = "JetBrainsMono Nerd Font"

// Стиль «стекло»: тёмная матовая основа, внутри мягкое свечение двух акцентов темы
// (rose и foam — в Vesper это фиолетовый и синий), у каждого приложения свой угол,
// сверху блик и светлая кромка, логотип белый с ореолом.
func render(_ app: App, index: Int) -> NSImage {
    let size: CGFloat = 1024
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    defer { img.unlockFocus() }
    let ctx = NSGraphicsContext.current!.cgContext

    // Сетка иконок macOS: тело 824×824 по центру, скругление ~185
    let body = NSRect(x: 100, y: 100, width: 824, height: 824)
    let shape = NSBezierPath(roundedRect: body, xRadius: 185, yRadius: 185)

    // тень под плиткой
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.45)
    shadow.shadowBlurRadius = 28
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.set()
    base.setFill(); shape.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    shape.addClip()
    NSGradient(starting: base.blended(withFraction: 0.08, of: .white)!, ending: base)!.draw(in: body, angle: -90)

    // свечение: два пятна по разные стороны, угол зависит от приложения
    let a = CGFloat(index) * 0.9 + 0.6
    let r: CGFloat = 330
    func glow(_ c: NSColor, _ ang: CGFloat, _ alpha: CGFloat, _ radius: CGFloat) {
        let p = NSPoint(x: 512 + r * cos(ang), y: 512 + r * sin(ang))
        NSGradient(colors: [c.withAlphaComponent(alpha), c.withAlphaComponent(alpha * 0.35), c.withAlphaComponent(0)],
                   atLocations: [0, 0.45, 1], colorSpace: .sRGB)!
            .draw(fromCenter: p, radius: 0, toCenter: p, radius: radius, options: [])
    }
    glow(rose, a, 0.72, 560)
    glow(foam, a + .pi * 0.95, 0.62, 520)

    // стеклянный блик сверху
    NSGradient(colors: [NSColor.white.withAlphaComponent(0.13), NSColor.white.withAlphaComponent(0)],
               atLocations: [0, 1], colorSpace: .sRGB)!
        .draw(in: NSRect(x: 100, y: 560, width: 824, height: 364), angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // светлая кромка стекла: ярче сверху, гаснет к низу
    NSGraphicsContext.saveGraphicsState()
    let ring = NSBezierPath(roundedRect: body.insetBy(dx: 3, dy: 3), xRadius: 182, yRadius: 182)
    let stroked = ring.cgPath.copy(strokingWithWidth: 5, lineCap: .round, lineJoin: .round, miterLimit: 10)
    ctx.addPath(stroked); ctx.clip()
    NSGradient(colors: [NSColor.white.withAlphaComponent(0.30), NSColor.white.withAlphaComponent(0.06)],
               atLocations: [0, 1], colorSpace: .sRGB)!.draw(in: body, angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // логотип: белый, с мягким ореолом, точно по центру по реальным границам глифа
    guard let font = NSFont(name: fontName, size: 420) else { fatalError("нет шрифта \(fontName)") }
    let str = NSAttributedString(string: app.glyph, attributes: [.font: font, .foregroundColor: text])
    let line = CTLineCreateWithAttributedString(str)
    let b = CTLineGetImageBounds(line, ctx)
    guard b.width > 1 else { fatalError("в шрифте нет глифа для \(app.path)") }
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 40, color: text.withAlphaComponent(0.45).cgColor)
    ctx.textPosition = CGPoint(x: size / 2 - b.midX, y: size / 2 - b.midY)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
    return img
}

let args = CommandLine.arguments
let mode = args.count > 1 ? args[1] : "preview"

for (index, app) in apps.enumerated() {
    let name = (app.path as NSString).lastPathComponent
    guard FileManager.default.fileExists(atPath: app.path) else { print("нет: \(name)"); continue }
    switch mode {
    case "preview":
        let dir = args.count > 2 ? args[2] : "."
        let rep = NSBitmapImageRep(data: render(app, index: index).tiffRepresentation!)!
        let out = "\(dir)/\(name).png"
        try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
        print("png: \(out)")
    case "apply":
        let ok = NSWorkspace.shared.setIcon(render(app, index: index), forFile: app.path, options: [])
        print(ok ? "✓ \(name)" : "✗ \(name) — не вышло: дай терминалу «Управление приложениями», для root-приложений ещё sudo")
    case "reset":
        let ok = NSWorkspace.shared.setIcon(nil, forFile: app.path, options: [])
        print(ok ? "↺ \(name)" : "✗ \(name) — не вышло: дай терминалу «Управление приложениями», для root-приложений ещё sudo")
    default:
        print("usage: icons.swift preview <dir> | apply | reset")
    }
}
