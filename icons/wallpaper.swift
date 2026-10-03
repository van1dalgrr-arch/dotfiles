#!/usr/bin/env swift
// ============================================================
//   Обои Rosé Pine: тёмная база + мягкое сияние iris / rose / pine
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
