#!/usr/bin/env swift
// ============================================================
//   Стеклянные иконки папок — в стиле иконок Dock (icons.swift):
//   тёмное стекло в форме папки, внутри свечение акцентов темы, белый значок.
//   swift folder.swift apply            — поставить на все папки из списка
//   swift folder.swift preview <папка>  — PNG для просмотра
//   swift folder.swift reset            — вернуть стандартные
//   Цвета — hex Rosé Pine, themes/apply.sh перекрашивает их под текущую тему.
// ============================================================
import AppKit
import CoreText

func hex(_ v: Int) -> NSColor {
    NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255,
            blue: CGFloat(v & 0xff) / 255, alpha: 1)
}
let base = hex(0x191724), rose = hex(0xebbcba), foam = hex(0x9ccfd8), text = hex(0xe0def4)
let font = CTFontCreateWithName("JetBrainsMono Nerd Font" as CFString, 1000, nil)
let home = NSHomeDirectory()

// папка → значок внутри
let folders: [(String, String)] = [
    ("\(home)/dev", "\u{F0174}"),            // </>
    ("\(home)/Downloads", "\u{F01DA}"),      // загрузка
    ("\(home)/Documents", "\u{F0219}"),      // документ
    ("\(home)/Desktop", "\u{F0379}"),        // монитор
    ("\(home)/Pictures", "\u{F021F}"),       // картинка
    ("\(home)/Music", "\u{F075A}"),          // нота
    ("\(home)/dotfiles", "\u{F0493}"),       // шестерёнка
]

func glyphPath(_ g: String) -> CGPath? {
    var units = Array(g.utf16), glyphs = [CGGlyph](repeating: 0, count: units.count)
    guard CTFontGetGlyphsForCharacters(font, &units, &glyphs, units.count), glyphs[0] != 0 else { return nil }
    return CTFontCreatePathForGlyph(font, glyphs[0], nil)
}
// путь глифа, вписанный в прямоугольник
func fitted(_ p: CGPath, in r: CGRect) -> CGPath {
    let b = p.boundingBoxOfPath, k = min(r.width / b.width, r.height / b.height)
    var t = CGAffineTransform(translationX: r.midX, y: r.midY).scaledBy(x: k, y: k).translatedBy(x: -b.midX, y: -b.midY)
    return p.copy(using: &t)!
}

func render(_ emblem: String, index: Int) -> NSImage {
    let size: CGFloat = 1024
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus(); defer { img.unlockFocus() }
    let ctx = NSGraphicsContext.current!.cgContext
    let folder = fitted(glyphPath("\u{F024B}")!, in: CGRect(x: 70, y: 120, width: 884, height: 760))

    // тень и тёмное стекло
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 30, color: NSColor.black.withAlphaComponent(0.5).cgColor)
    ctx.addPath(folder); ctx.setFillColor(base.cgColor); ctx.fillPath()
    ctx.restoreGState()

    // свечение внутри: два акцента, угол свой у каждой папки
    ctx.saveGState(); ctx.addPath(folder); ctx.clip()
    let a = CGFloat(index) * 0.9 + 0.5
    for (c, ang, alpha) in [(rose, a, 0.75), (foam, a + .pi, 0.6)] as [(NSColor, CGFloat, CGFloat)] {
        let p = CGPoint(x: 512 + 300 * cos(ang), y: 500 + 260 * sin(ang))
        let g = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors:
            [c.withAlphaComponent(alpha).cgColor, c.withAlphaComponent(alpha * 0.3).cgColor, c.withAlphaComponent(0).cgColor] as CFArray,
            locations: [0, 0.45, 1])!
        ctx.drawRadialGradient(g, startCenter: p, startRadius: 0, endCenter: p, endRadius: 560, options: [])
    }
    // блик сверху
    let sheen = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors:
        [NSColor.white.withAlphaComponent(0.14).cgColor, NSColor.white.withAlphaComponent(0).cgColor] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sheen, start: CGPoint(x: 0, y: 880), end: CGPoint(x: 0, y: 560), options: [])
    ctx.restoreGState()

    // светлая кромка
    ctx.addPath(folder); ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.22).cgColor); ctx.setLineWidth(6); ctx.strokePath()

    // значок: белый с ореолом, по центру «тела» папки
    if let e = glyphPath(emblem) {
        let path = fitted(e, in: CGRect(x: 352, y: 300, width: 320, height: 300))
        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: 36, color: text.withAlphaComponent(0.5).cgColor)
        ctx.addPath(path); ctx.setFillColor(text.cgColor); ctx.fillPath()
        ctx.restoreGState()
    }
    return img
}

let args = CommandLine.arguments
let mode = args.count > 1 ? args[1] : "apply"
for (i, (path, emblem)) in folders.enumerated() where FileManager.default.fileExists(atPath: path) {
    let name = (path as NSString).lastPathComponent
    switch mode {
    case "preview":
        let rep = NSBitmapImageRep(data: render(emblem, index: i).tiffRepresentation!)!
        try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(args[2])/\(name).png"))
    case "reset":
        print(NSWorkspace.shared.setIcon(nil, forFile: path, options: []) ? "↺ \(name)" : "✗ \(name)")
    default:
        print(NSWorkspace.shared.setIcon(render(emblem, index: i), forFile: path, options: []) ? "✓ \(name)" : "✗ \(name)")
    }
}
