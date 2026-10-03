#!/usr/bin/env swift
// ============================================================
//   Обои Rosé Pine: ночь, луна, горы и сосны
//   swift wallpaper.swift <out.png> [ширина] [высота]
// ============================================================

import AppKit
import CoreImage

let args = CommandLine.arguments
let out = args.count > 1 ? args[1] : "rose-pine.png"
let W = args.count > 2 ? CGFloat(Double(args[2])!) : 2560
let H = args.count > 3 ? CGFloat(Double(args[3])!) : 1664

func rgb(_ h: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((h >> 16) & 0xff) / 255, green: CGFloat((h >> 8) & 0xff) / 255,
            blue: CGFloat(h & 0xff) / 255, alpha: a)
}

let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                    space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

// база: base сверху → чуть темнее снизу
let bg = CGGradient(colorsSpace: cs, colors: [rgb(0x1f1d2e), rgb(0x141220)] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: H), end: CGPoint(x: W * 0.3, y: 0),
                       options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

// мягкие пятна света (x, y — доли экрана; r — доля ширины)
func glow(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ color: Int, _ a: CGFloat) {
    let g = CGGradient(colorsSpace: cs, colors: [rgb(color, a), rgb(color, a * 0.35), rgb(color, 0)] as CFArray,
                       locations: [0, 0.45, 1])!
    let c = CGPoint(x: W * x, y: H * y)
    ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: W * r, options: [])
}
glow(0.78, 0.80, 0.55, 0xc4a7e7, 0.38)   // iris — справа сверху
glow(0.18, 0.22, 0.50, 0x31748f, 0.32)   // pine — слева снизу
glow(0.60, 0.30, 0.38, 0xebbcba, 0.20)   // rose — центр-низ
glow(0.30, 0.85, 0.30, 0xeb6f92, 0.08)   // love — едва заметно

// ─── детали: звёзды, луна, горы, сосны ───
let S = W / 2560                                   // масштаб под любое разрешение

// детерминированный «рандом», чтобы картинка всегда была одинаковой
var seed: UInt64 = 0x5EED_2026
func rnd() -> CGFloat {
    seed = seed &* 6364136223846793005 &+ 1442695040888963407
    return CGFloat(seed >> 33) / CGFloat(1 << 31)
}

// звёзды — редкие, гуще наверху
for _ in 0..<170 {
    let x = rnd() * W
    let t = rnd()
    let y = H * (0.40 + 0.60 * sqrt(t))
    let r = (0.6 + rnd() * 1.4) * S
    let colors = [0xe0def4, 0xe0def4, 0xc4a7e7, 0xebbcba, 0x9ccfd8]
    ctx.setFillColor(rgb(colors[Int(rnd() * 5) % 5], 0.15 + rnd() * 0.45))
    ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
}

// полумесяц в сиреневом сиянии
let moon = CGPoint(x: W * 0.78, y: H * 0.80), mr = 46 * S
let halo = CGGradient(colorsSpace: cs, colors: [rgb(0xebbcba, 0.22), rgb(0xebbcba, 0)] as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(halo, startCenter: moon, startRadius: mr, endCenter: moon, endRadius: mr * 5, options: [])
ctx.saveGState()
ctx.addEllipse(in: CGRect(x: moon.x - mr, y: moon.y - mr, width: mr * 2, height: mr * 2))
ctx.clip()
ctx.addRect(CGRect(x: 0, y: 0, width: W, height: H))
ctx.addEllipse(in: CGRect(x: moon.x - mr + mr * 0.55, y: moon.y - mr + mr * 0.30, width: mr * 2, height: mr * 2))
ctx.setFillColor(rgb(0xebbcba, 0.92))
ctx.fillPath(using: .evenOdd)
ctx.restoreGState()

// хребет: сумма синусоид со случайными фазами
func ridge(_ baseY: CGFloat, _ amp: CGFloat) -> [CGPoint] {
    let waves = (0..<4).map { i in (f: CGFloat(i + 1) * (1.3 + rnd()), p: rnd() * 6.28, a: amp / CGFloat(i + 1)) }
    return stride(from: CGFloat(0), through: W, by: 6 * S).map { x in
        let u = x / W * 6.28
        return CGPoint(x: x, y: baseY + waves.reduce(0) { $0 + $1.a * sin(u * $1.f + $1.p) })
    }
}

func fillRidge(_ pts: [CGPoint], _ color: CGColor) {
    let p = CGMutablePath()
    p.move(to: CGPoint(x: 0, y: 0))
    pts.forEach { p.addLine(to: $0) }
    p.addLine(to: CGPoint(x: W, y: 0)); p.closeSubpath()
    ctx.addPath(p); ctx.setFillColor(color); ctx.fillPath()
}

// дымка над слоем — чуть светлее pine
func mist(_ y: CGFloat) {
    let g = CGGradient(colorsSpace: cs, colors: [rgb(0x31748f, 0), rgb(0x31748f, 0.10), rgb(0x31748f, 0)] as CFArray,
                       locations: [0, 0.5, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: y - 60 * S), end: CGPoint(x: 0, y: y + 90 * S), options: [])
}

// сосна: три яруса треугольников
func pine(_ x: CGFloat, _ y: CGFloat, _ h: CGFloat, _ color: CGColor) {
    ctx.setFillColor(color)
    for i in 0..<3 {
        let tierBottom = y + h * CGFloat(i) * 0.24
        let w = h * (0.42 - CGFloat(i) * 0.09)
        let p = CGMutablePath()
        p.move(to: CGPoint(x: x - w / 2, y: tierBottom))
        p.addLine(to: CGPoint(x: x + w / 2, y: tierBottom))
        p.addLine(to: CGPoint(x: x, y: tierBottom + h * 0.48))
        p.closeSubpath()
        ctx.addPath(p); ctx.fillPath()
    }
    ctx.fill(CGRect(x: x - h * 0.025, y: y - h * 0.08, width: h * 0.05, height: h * 0.1))
}

let far = ridge(H * 0.36, 70 * S);  mist(H * 0.30); fillRidge(far, rgb(0x2a2740, 0.85))
let mid = ridge(H * 0.25, 55 * S);  mist(H * 0.20); fillRidge(mid, rgb(0x211f33, 0.95))
let near = ridge(H * 0.14, 38 * S)
fillRidge(near, rgb(0x17151f))

// сосны на ближнем хребте, гуще по краям — центр остаётся свободным
var x: CGFloat = 0
while x < W {
    let edge = abs(x / W - 0.5) * 2               // 0 в центре, 1 по краям
    if rnd() < 0.25 + 0.65 * edge {
        let i = min(Int(x / (6 * S)), near.count - 1)
        let h = (60 + rnd() * 110) * S * (0.6 + 0.6 * edge)
        pine(x, near[i].y - 6 * S, h, rgb(0x17151f))
    }
    x += (14 + rnd() * 26) * S
}

// виньетка по краям
let vig = CGGradient(colorsSpace: cs, colors: [rgb(0x000000, 0), rgb(0x000000, 0.35)] as CFArray, locations: [0.55, 1])!
ctx.drawRadialGradient(vig, startCenter: CGPoint(x: W / 2, y: H / 2), startRadius: 0,
                       endCenter: CGPoint(x: W / 2, y: H / 2), endRadius: hypot(W, H) / 2, options: [])

// 16 бит на канал — градиенты без «ступенек», шум не нужен
let result = CIImage(cgImage: ctx.makeImage()!)

let ci = CIContext(options: [.workingColorSpace: cs])
let png = ci.pngRepresentation(of: result, format: .RGBA16, colorSpace: cs)!
try! png.write(to: URL(fileURLWithPath: out))
print("обои: \(out)")
