#!/usr/bin/env swift
// ============================================================
//   Живые обои Rosé Pine: горы и сосны, которые живут по часам —
//   ночь с луной → рассвет → день → закат → снова ночь.
//
//   swift wallpaper.swift rose-pine.heic   — динамические обои macOS
//   swift wallpaper.swift preview/         — каждый кадр отдельным PNG
//   [ширина] [высота] — третьим/четвёртым аргументом (по умолчанию 2560×1664)
//
//   Кадры меняет сама macOS по метаданным HEIC — ничего не запущено в фоне.
// ============================================================

import AppKit
import CoreImage

let args = CommandLine.arguments
let out = args.count > 1 ? args[1] : "rose-pine.heic"
let W = args.count > 2 ? CGFloat(Double(args[2])!) : 2560
let H = args.count > 3 ? CGFloat(Double(args[3])!) : 1664
let S = W / 2560                                   // масштаб под любое разрешение
let cs = CGColorSpace(name: CGColorSpace.sRGB)!

// ─── цвет ───

func rgb(_ h: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((h >> 16) & 0xff) / 255, green: CGFloat((h >> 8) & 0xff) / 255,
            blue: CGFloat(h & 0xff) / 255, alpha: a)
}

func mix(_ a: Int, _ b: Int, _ t: CGFloat) -> Int {
    [16, 8, 0].reduce(0) { acc, s in
        let x = CGFloat((a >> s) & 0xff), y = CGFloat((b >> s) & 0xff)
        return acc | (Int((x + (y - x) * t).rounded()) << s)
    }
}

func mix(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }

// ─── освещение сцены ───

struct Look {
    var skyTop, skyMid, skyLow: Int      // небо сверху → к горизонту
    var far, mid, near: Int              // три слоя гор (ближний — с соснами)
    var mist: Int, mistA: CGFloat        // дымка между слоями
    var night: CGFloat                   // 0…1: звёзды, луна, ночные пятна света
    var sun: Int, sunGlow: CGFloat
    var vignette: CGFloat

    func blend(_ o: Look, _ t: CGFloat) -> Look {
        Look(skyTop: mix(skyTop, o.skyTop, t), skyMid: mix(skyMid, o.skyMid, t), skyLow: mix(skyLow, o.skyLow, t),
             far: mix(far, o.far, t), mid: mix(mid, o.mid, t), near: mix(near, o.near, t),
             mist: mix(mist, o.mist, t), mistA: mix(mistA, o.mistA, t), night: mix(night, o.night, t),
             sun: mix(sun, o.sun, t), sunGlow: mix(sunGlow, o.sunGlow, t), vignette: mix(vignette, o.vignette, t))
    }
}

// Ночь — Rosé Pine, день — Rosé Pine Dawn, рассвет и закат — между ними
let night = Look(skyTop: 0x1f1d2e, skyMid: 0x1a1828, skyLow: 0x141220,
                 far: 0x2a2740, mid: 0x211f33, near: 0x17151f, mist: 0x31748f, mistA: 0.10,
                 night: 1, sun: 0xf6c177, sunGlow: 0, vignette: 0.35)
let dawn = Look(skyTop: 0x2a273f, skyMid: 0x907aa9, skyLow: 0xebbcba,
                far: 0x817c9c, mid: 0x56526e, near: 0x232136, mist: 0xebbcba, mistA: 0.18,
                night: 0.15, sun: 0xf6c177, sunGlow: 0.45, vignette: 0.25)
let day = Look(skyTop: 0x56949f, skyMid: 0x9ccfd8, skyLow: 0xf2e9e1,
               far: 0xa8a2c4, mid: 0x797593, near: 0x3a3654, mist: 0xfffaf3, mistA: 0.22,
               night: 0, sun: 0xfffaf3, sunGlow: 0.5, vignette: 0.15)
let dusk = Look(skyTop: 0x191724, skyMid: 0x403d52, skyLow: 0xb4637a,
                far: 0x44415a, mid: 0x2a273f, near: 0x17151f, mist: 0xc4a7e7, mistA: 0.12,
                night: 0.7, sun: 0xeb6f92, sunGlow: 0.15, vignette: 0.32)
let sunset = Look(skyTop: 0x26233a, skyMid: 0xb4637a, skyLow: 0xf6c177,
                  far: 0x6e6a86, mid: 0x44415a, near: 0x191724, mist: 0xeb6f92, mistA: 0.15,
                  night: 0.1, sun: 0xf6c177, sunGlow: 0.6, vignette: 0.30)

// Кадры: час суток → освещение. 21:30 снова показывает кадр ночи (индекс 0).
let frames: [(hour: CGFloat, look: Look)] = [
    (0.0,  night),
    (4.5,  night.blend(dawn, 0.4)),     // предрассветное
    (6.0,  dawn),
    (8.0,  dawn.blend(day, 0.55)),      // утро
    (11.5, day),
    (15.5, day.blend(sunset, 0.35)),    // после полудня
    (18.0, sunset),
    (19.5, dusk),                       // сумерки
]
let nightAgain: CGFloat = 21.5
let lightIndex = 4, darkIndex = 0       // для «светлого/тёмного» оформления macOS

// ─── рисование одного кадра ───

func render(hour: CGFloat, look L: Look) -> CGImage {
    let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

    // детерминированный «рандом» — во всех кадрах те же звёзды, горы и сосны
    var seed: UInt64 = 0x5EED_2026
    func rnd() -> CGFloat {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat(seed >> 33) / CGFloat(1 << 31)
    }

    // небо
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(L.skyTop), rgb(L.skyMid), rgb(L.skyLow)] as CFArray,
                         locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: W * 0.3, y: H), end: CGPoint(x: W * 0.5, y: H * 0.2),
                           options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

    // мягкие пятна света (x, y — доли экрана; r — доля ширины)
    func glow(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ color: Int, _ a: CGFloat) {
        guard a > 0.001 else { return }
        let g = CGGradient(colorsSpace: cs, colors: [rgb(color, a), rgb(color, a * 0.35), rgb(color, 0)] as CFArray,
                           locations: [0, 0.45, 1])!
        let c = CGPoint(x: W * x, y: H * y)
        ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: W * r, options: [])
    }
    glow(0.78, 0.80, 0.55, 0xc4a7e7, 0.38 * L.night)   // iris — справа сверху
    glow(0.18, 0.22, 0.50, 0x31748f, 0.32 * L.night)   // pine — слева снизу
    glow(0.60, 0.30, 0.38, 0xebbcba, 0.20 * L.night)   // rose — центр-низ
    glow(0.30, 0.85, 0.30, 0xeb6f92, 0.08 * L.night)   // love — едва заметно

    // звёзды — гуще наверху, гаснут к утру (rnd() зовём всегда, чтобы кадры совпадали)
    for _ in 0..<170 {
        let x = rnd() * W
        let y = H * (0.40 + 0.60 * sqrt(rnd()))
        let r = (0.6 + rnd() * 1.4) * S
        let colors = [0xe0def4, 0xe0def4, 0xc4a7e7, 0xebbcba, 0x9ccfd8]
        let c = colors[Int(rnd() * 5) % 5], a = (0.15 + rnd() * 0.45) * L.night
        if a > 0.01 {
            ctx.setFillColor(rgb(c, a))
            ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
    }

    // солнце идёт по дуге 6:00 → 19:00 и садится за горы
    let p = (hour - 6) / 13
    if p >= 0 && p <= 1 && L.sunGlow > 0.01 {
        // на краях дуги солнце ниже хребтов — встаёт и садится из-за гор
        let sun = CGPoint(x: W * (0.10 + 0.80 * p), y: H * (0.18 + 0.67 * sin(.pi * p)))
        let sr = 40 * S
        let halo = CGGradient(colorsSpace: cs, colors: [rgb(L.sun, L.sunGlow), rgb(L.sun, L.sunGlow * 0.3), rgb(L.sun, 0)] as CFArray,
                              locations: [0, 0.3, 1])!
        ctx.drawRadialGradient(halo, startCenter: sun, startRadius: sr, endCenter: sun, endRadius: W * 0.32, options: [])
        ctx.setFillColor(rgb(L.sun, 0.95))
        ctx.fillEllipse(in: CGRect(x: sun.x - sr, y: sun.y - sr, width: sr * 2, height: sr * 2))
    }

    // полумесяц в сиянии — проявляется с темнотой
    if L.night > 0.05 {
        let moon = CGPoint(x: W * 0.78, y: H * 0.80), mr = 46 * S
        let halo = CGGradient(colorsSpace: cs, colors: [rgb(0xebbcba, 0.22 * L.night), rgb(0xebbcba, 0)] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(halo, startCenter: moon, startRadius: mr, endCenter: moon, endRadius: mr * 5, options: [])
        ctx.saveGState()
        ctx.addEllipse(in: CGRect(x: moon.x - mr, y: moon.y - mr, width: mr * 2, height: mr * 2))
        ctx.clip()
        ctx.addRect(CGRect(x: 0, y: 0, width: W, height: H))
        ctx.addEllipse(in: CGRect(x: moon.x - mr + mr * 0.55, y: moon.y - mr + mr * 0.30, width: mr * 2, height: mr * 2))
        ctx.setFillColor(rgb(0xebbcba, 0.92 * L.night))
        ctx.fillPath(using: .evenOdd)
        ctx.restoreGState()
    }

    // хребет: сумма синусоид со случайными фазами
    func ridge(_ baseY: CGFloat, _ amp: CGFloat) -> [CGPoint] {
        let waves = (0..<4).map { i in (f: CGFloat(i + 1) * (1.3 + rnd()), p: rnd() * 6.28, a: amp / CGFloat(i + 1)) }
        return stride(from: CGFloat(0), through: W, by: 6 * S).map { x in
            let u = x / W * 6.28
            return CGPoint(x: x, y: baseY + waves.reduce(0) { $0 + $1.a * sin(u * $1.f + $1.p) })
        }
    }

    func fillRidge(_ pts: [CGPoint], _ color: CGColor) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        pts.forEach { path.addLine(to: $0) }
        path.addLine(to: CGPoint(x: W, y: 0)); path.closeSubpath()
        ctx.addPath(path); ctx.setFillColor(color); ctx.fillPath()
    }

    // дымка над слоем
    func mist(_ y: CGFloat) {
        let g = CGGradient(colorsSpace: cs, colors: [rgb(L.mist, 0), rgb(L.mist, L.mistA), rgb(L.mist, 0)] as CFArray,
                           locations: [0, 0.5, 1])!
        ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: y - 60 * S), end: CGPoint(x: 0, y: y + 90 * S), options: [])
    }

    // сосна: три яруса треугольников
    func pine(_ x: CGFloat, _ y: CGFloat, _ h: CGFloat, _ color: CGColor) {
        ctx.setFillColor(color)
        for i in 0..<3 {
            let tierBottom = y + h * CGFloat(i) * 0.24
            let w = h * (0.42 - CGFloat(i) * 0.09)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x - w / 2, y: tierBottom))
            path.addLine(to: CGPoint(x: x + w / 2, y: tierBottom))
            path.addLine(to: CGPoint(x: x, y: tierBottom + h * 0.48))
            path.closeSubpath()
            ctx.addPath(path); ctx.fillPath()
        }
        ctx.fill(CGRect(x: x - h * 0.025, y: y - h * 0.08, width: h * 0.05, height: h * 0.1))
    }

    let far = ridge(H * 0.36, 70 * S);  mist(H * 0.30); fillRidge(far, rgb(L.far, 0.85))
    let mid = ridge(H * 0.25, 55 * S);  mist(H * 0.20); fillRidge(mid, rgb(L.mid, 0.95))
    let near = ridge(H * 0.14, 38 * S)
    fillRidge(near, rgb(L.near))

    // сосны на ближнем хребте, гуще по краям — центр остаётся свободным
    var x: CGFloat = 0
    while x < W {
        let edge = abs(x / W - 0.5) * 2               // 0 в центре, 1 по краям
        if rnd() < 0.25 + 0.65 * edge {
            let i = min(Int(x / (6 * S)), near.count - 1)
            let h = (60 + rnd() * 110) * S * (0.6 + 0.6 * edge)
            pine(x, near[i].y - 6 * S, h, rgb(L.near))
        }
        x += (14 + rnd() * 26) * S
    }

    // виньетка по краям
    let vig = CGGradient(colorsSpace: cs, colors: [rgb(0x000000, 0), rgb(0x000000, L.vignette)] as CFArray, locations: [0.55, 1])!
    ctx.drawRadialGradient(vig, startCenter: CGPoint(x: W / 2, y: H / 2), startRadius: 0,
                           endCenter: CGPoint(x: W / 2, y: H / 2), endRadius: hypot(W, H) / 2, options: [])

    return ctx.makeImage()!
}

// HEIC хранит 8 бит на канал — лёгкий шум убирает «ступеньки» на градиентах неба
let ci = CIContext(options: [.workingColorSpace: cs])
func dithered(_ img: CGImage) -> CGImage {
    let base = CIImage(cgImage: img)
    let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!
        .applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0.012, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: 0.012, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: 0.012, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBiasVector": CIVector(x: -0.006, y: -0.006, z: -0.006, w: 1),
        ])
        .cropped(to: base.extent)
    let sum = noise.applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: base])
    return ci.createCGImage(sum, from: base.extent, format: .RGBA8, colorSpace: cs)!
}

let images = frames.map { render(hour: $0.hour, look: $0.look) }

// ─── превью: каждый кадр в PNG ───
if out.hasSuffix("/") {
    try! FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)
    for (i, f) in frames.enumerated() {
        let mins = Int(f.hour * 60)
        let url = URL(fileURLWithPath: String(format: "%@%d-%02d.%02d.png", out, i, mins / 60, mins % 60))
        let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, images[i], nil)
        CGImageDestinationFinalize(dest)
    }
    print("превью: \(out) (\(frames.count) кадров)")
    exit(0)
}

// ─── динамический HEIC: кадры + расписание в метаданных apple_desktop:h24 ───
var schedule: [[String: Any]] = frames.enumerated().map { ["i": $0.offset, "t": Double($0.element.hour / 24)] }
schedule.append(["i": 0, "t": Double(nightAgain / 24)])
let plist: [String: Any] = ["ap": ["l": lightIndex, "d": darkIndex], "ti": schedule]
let h24 = try! PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0).base64EncodedString()

let ns = "http://ns.apple.com/namespace/1.0/" as CFString
let meta = CGImageMetadataCreateMutable()
CGImageMetadataRegisterNamespaceForPrefix(meta, ns, "apple_desktop" as CFString, nil)
let tag = CGImageMetadataTagCreate(ns, "apple_desktop" as CFString, "h24" as CFString, .string, h24 as CFString)!
CGImageMetadataSetTagWithPath(meta, nil, "apple_desktop:h24" as CFString, tag)

let url = URL(fileURLWithPath: out)
let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.heic" as CFString, images.count, nil)!
let opts = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
for (i, img) in images.enumerated() {
    if i == 0 { CGImageDestinationAddImageAndMetadata(dest, dithered(img), meta, opts) }
    else { CGImageDestinationAddImage(dest, dithered(img), opts) }
}
guard CGImageDestinationFinalize(dest) else { print("не удалось записать \(out)"); exit(1) }
print("обои: \(out) — \(images.count) кадров, меняются по времени суток")
