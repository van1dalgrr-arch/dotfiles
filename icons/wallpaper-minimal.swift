#!/usr/bin/env swift
// ============================================================
//   Минималистичные живые обои: почти чёрный фон, точечная сетка,
//   тонкие контурные линии (как на топокарте) и одно мягкое пятно света,
//   которое за сутки меняет цвет и место: синий ночью → белый свет днём → розовый закат.
//
//   swift wallpaper-minimal.swift vesper.heic   — динамические обои macOS
//   swift wallpaper-minimal.swift preview/      — каждый кадр отдельным PNG
//   [ширина] [высота] — третьим/четвёртым аргументом (по умолчанию 2560×1664)
// ============================================================

import AppKit
import CoreImage

let args = CommandLine.arguments
let out = args.count > 1 ? args[1] : "minimal.heic"
let W = args.count > 2 ? CGFloat(Double(args[2])!) : 2560
let H = args.count > 3 ? CGFloat(Double(args[3])!) : 1664
let S = W / 2560
let cs = CGColorSpace(name: CGColorSpace.sRGB)!

func rgb(_ h: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((h >> 16) & 0xff) / 255, green: CGFloat((h >> 8) & 0xff) / 255,
            blue: CGFloat(h & 0xff) / 255, alpha: a)
}

// ─── освещение: только пятно света, всё остальное неизменно ───

struct Look {
    var glow: Int, glowA: CGFloat     // цвет и сила пятна
    var gx, gy: CGFloat               // где оно (доли экрана)
    var glow2: Int, glow2A: CGFloat   // второе, совсем слабое — для глубины
    var lines: CGFloat                // яркость сетки и контуров
}

// Кадры: час → свет. Пятно медленно обходит экран, как солнце, но остаётся почти невидимым
let frames: [(hour: CGFloat, look: Look)] = [
    (0.0,  Look(glow: 0x3b82f6, glowA: 0.065, gx: 0.80, gy: 0.22, glow2: 0x1e3a8a, glow2A: 0.060, lines: 0.60)),  // ночь — синий
    (5.0,  Look(glow: 0xa855f7, glowA: 0.075, gx: 0.18, gy: 0.18, glow2: 0x1e3a8a, glow2A: 0.050, lines: 0.64)), // предрассвет — фиолет
    (7.0,  Look(glow: 0xf97316, glowA: 0.055, gx: 0.20, gy: 0.28, glow2: 0xa855f7, glow2A: 0.060, lines: 0.68)),  // рассвет — розоватый
    (10.0, Look(glow: 0xf0ece4, glowA: 0.050, gx: 0.40, gy: 0.70, glow2: 0x3b82f6, glow2A: 0.030, lines: 0.75)),  // утро — белый свет
    (13.0, Look(glow: 0xf0ece4, glowA: 0.060, gx: 0.55, gy: 0.82, glow2: 0xa855f7, glow2A: 0.030, lines: 0.75)),  // день
    (17.0, Look(glow: 0xf0ece4, glowA: 0.050, gx: 0.74, gy: 0.55, glow2: 0xa855f7, glow2A: 0.050, lines: 0.71)), // вечер
    (19.0, Look(glow: 0xec4899, glowA: 0.055, gx: 0.82, gy: 0.30, glow2: 0xa855f7, glow2A: 0.060, lines: 0.68)),  // закат — розовый
    (21.0, Look(glow: 0xa855f7, glowA: 0.070, gx: 0.80, gy: 0.24, glow2: 0x3b82f6, glow2A: 0.035, lines: 0.64)), // сумерки
]
let lightIndex = 4, darkIndex = 0

// центр «рельефа» — контуры расходятся отсюда
let focus = CGPoint(x: W * 0.70, y: H * 0.38)

func render(_ L: Look) -> CGImage {
    let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    var seed: UInt64 = 0x0D07_6121
    func rnd() -> CGFloat {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat(seed >> 33) / CGFloat(1 << 31)
    }

    // фон: почти чёрный, чуть светлее к центру
    ctx.setFillColor(rgb(0x08080a)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let lift = CGGradient(colorsSpace: cs, colors: [rgb(0x101012), rgb(0x08080a)] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(lift, startCenter: CGPoint(x: W * 0.5, y: H * 0.55), startRadius: 0,
                           endCenter: CGPoint(x: W * 0.5, y: H * 0.55), endRadius: hypot(W, H) * 0.6, options: [])

    // пятна света
    func glow(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ c: Int, _ a: CGFloat) {
        let g = CGGradient(colorsSpace: cs, colors: [rgb(c, a), rgb(c, a * 0.4), rgb(c, 0)] as CFArray, locations: [0, 0.4, 1])!
        let p = CGPoint(x: W * x, y: H * y)
        ctx.drawRadialGradient(g, startCenter: p, startRadius: 0, endCenter: p, endRadius: W * r, options: [])
    }
    glow(L.gx, L.gy, 0.55, L.glow, L.glowA)
    glow(1 - L.gx * 0.8, 1 - L.gy * 0.7, 0.45, L.glow2, L.glow2A)

    // точечная сетка — ярче у центра рельефа, к краям гаснет
    let step = 34 * S
    var gy = step / 2
    while gy < H {
        var gx = step / 2
        while gx < W {
            let d = hypot(gx - focus.x, gy - focus.y) / hypot(W, H)
            let a = max(0, 0.22 - d * 0.30) * L.lines
            if a > 0.004 {
                ctx.setFillColor(rgb(0xffffff, a))
                let r = max(0.8, 1.3 * S)
                ctx.fillEllipse(in: CGRect(x: gx - r, y: gy - r, width: r * 2, height: r * 2))
            }
            gx += step
        }
        gy += step
    }

    // контурные линии: концентрические «изолинии» с мягкими искажениями
    let waves = (0..<5).map { i in (k: CGFloat(i + 2), p: rnd() * 6.28, a: (0.10 + rnd() * 0.08) / CGFloat(i + 1)) }
    for ring in 1...26 {
        let r0 = CGFloat(ring) * 38 * S
        let path = CGMutablePath()
        for i in 0...360 {
            let th = CGFloat(i) / 360 * 2 * .pi
            let wob = waves.reduce(0) { $0 + $1.a * sin($1.k * th + $1.p + CGFloat(ring) * 0.13) }
            let r = r0 * (1 + wob)
            let pt = CGPoint(x: focus.x + r * cos(th), y: focus.y + r * sin(th) * 0.82)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        // каждая пятая линия чуть ярче — как на топокарте
        let a = (ring % 5 == 0 ? 0.16 : 0.075) * L.lines * max(0.25, 1 - CGFloat(ring) / 30)
        ctx.addPath(path)
        ctx.setStrokeColor(rgb(0xffffff, a)); ctx.setLineWidth(max(1, ring % 5 == 0 ? 1.6 * S : 1.1 * S))
        ctx.strokePath()
    }

    // пара технических меток «+» на узлах сетки
    for (fx, fy) in [(0.18, 0.78), (0.86, 0.84), (0.30, 0.22), (0.62, 0.62)] as [(CGFloat, CGFloat)] {
        let x = (W * fx / step).rounded() * step + step / 2, y = (H * fy / step).rounded() * step + step / 2
        let l = 7 * S
        ctx.setStrokeColor(rgb(0xffffff, 0.30 * L.lines)); ctx.setLineWidth(max(1, 1.4 * S))
        ctx.move(to: CGPoint(x: x - l, y: y)); ctx.addLine(to: CGPoint(x: x + l, y: y))
        ctx.move(to: CGPoint(x: x, y: y - l)); ctx.addLine(to: CGPoint(x: x, y: y + l))
        ctx.strokePath()
    }
    return ctx.makeImage()!
}

// 8-битный HEIC: тонкий шум против «ступенек» на градиентах
let ci = CIContext(options: [.workingColorSpace: cs])
func dithered(_ img: CGImage) -> CGImage {
    let base = CIImage(cgImage: img)
    let a: CGFloat = 0.004   // серый (один канал на все) — без цветных точек
    let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!
        .applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: a, y: 0, z: 0, w: 0), "inputGVector": CIVector(x: a, y: 0, z: 0, w: 0),
            "inputBVector": CIVector(x: a, y: 0, z: 0, w: 0), "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBiasVector": CIVector(x: -a / 2, y: -a / 2, z: -a / 2, w: 1),
        ]).cropped(to: base.extent)
    let sum = noise.applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: base])
    return ci.createCGImage(sum, from: base.extent, format: .RGBA8, colorSpace: cs)!
}

let images = frames.map { dithered(render($0.look)) }

if out.hasSuffix("/") {
    try! FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)
    for (i, f) in frames.enumerated() {
        let mins = Int(f.hour * 60)
        let url = URL(fileURLWithPath: String(format: "%@%d-%02d.%02d.png", out, i, mins / 60, mins % 60))
        let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, images[i], nil); CGImageDestinationFinalize(dest)
    }
    print("превью: \(out) (\(frames.count) кадров)")
    exit(0)
}

// динамический HEIC: расписание в метаданных apple_desktop:h24 (как в wallpaper.swift)
let schedule: [[String: Any]] = frames.enumerated().map { ["i": $0.offset, "t": Double($0.element.hour / 24)] }
let plist: [String: Any] = ["ap": ["l": lightIndex, "d": darkIndex], "ti": schedule]
let h24 = try! PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0).base64EncodedString()
let ns = "http://ns.apple.com/namespace/1.0/" as CFString
let meta = CGImageMetadataCreateMutable()
CGImageMetadataRegisterNamespaceForPrefix(meta, ns, "apple_desktop" as CFString, nil)
CGImageMetadataSetTagWithPath(meta, nil, "apple_desktop:h24" as CFString,
                              CGImageMetadataTagCreate(ns, "apple_desktop" as CFString, "h24" as CFString, .string, h24 as CFString)!)
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, "public.heic" as CFString, images.count, nil)!
let opts = [kCGImageDestinationLossyCompressionQuality: 0.92] as CFDictionary
for (i, img) in images.enumerated() {
    if i == 0 { CGImageDestinationAddImageAndMetadata(dest, img, meta, opts) } else { CGImageDestinationAddImage(dest, img, opts) }
}
guard CGImageDestinationFinalize(dest) else { print("не удалось записать \(out)"); exit(1) }
print("обои: \(out) — \(images.count) кадров, меняются по времени суток")
