#!/usr/bin/env swift
// Иконка папки с проектами: папка iris + «</>» внутри
// swift folder.swift <папка> [preview.png]
import AppKit
import CoreText

func hex(_ v: Int) -> NSColor {
    NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255,
            blue: CGFloat(v & 0xff) / 255, alpha: 1)
}

let size: CGFloat = 1024
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

func glyph(_ g: String, _ pt: CGFloat, _ color: NSColor, dy: CGFloat = 0) {
    let font = NSFont(name: "JetBrainsMono Nerd Font", size: pt)!
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: g, attributes: [.font: font, .foregroundColor: color]))
    ctx.textPosition = .zero
    let b = CTLineGetImageBounds(line, ctx)
    precondition(b.width > 1, "нет глифа")
    ctx.textPosition = CGPoint(x: size / 2 - b.midX, y: size / 2 - b.midY + dy)
    CTLineDraw(line, ctx)
}

let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
shadow.shadowBlurRadius = 20
shadow.shadowOffset = NSSize(width: 0, height: -8)
NSGraphicsContext.saveGraphicsState(); shadow.set()
glyph("\u{F024B}", 1000, hex(0xc4a7e7))          // папка — iris
NSGraphicsContext.restoreGraphicsState()
glyph("\u{F0174}", 330, hex(0x191724), dy: -40)   // </> — base
img.unlockFocus()

let args = CommandLine.arguments
if args.count > 2 {
    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
    print("png:", args[2])
} else {
    print(NSWorkspace.shared.setIcon(img, forFile: args[1], options: []) ? "✓ \(args[1])" : "✗ \(args[1])")
}
