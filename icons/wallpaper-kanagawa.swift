#!/usr/bin/env swift
// ============================================================
//   Живые обои Kanagawa: Фудзи, море узором сэйгайха, полосы тумана касуми,
//   солнце встаёт и садится в море, на закате Фудзи краснеет (как у Хокусая).
//   День — Kanagawa Lotus (бумага), ночь — Kanagawa Wave (индиго).
//
//   swift wallpaper-kanagawa.swift kanagawa.heic   — динамические обои macOS
//   swift wallpaper-kanagawa.swift preview/        — каждый кадр отдельным PNG
//   [ширина] [высота] — третьим/четвёртым аргументом (по умолчанию 2560×1664)
// ============================================================

import AppKit
import CoreImage
import CoreText

let args = CommandLine.arguments
let out = args.count > 1 ? args[1] : "kanagawa.heic"
let W = args.count > 2 ? CGFloat(Double(args[2])!) : 2560
let H = args.count > 3 ? CGFloat(Double(args[3])!) : 1664
let S = W / 2560
let cs = CGColorSpace(name: CGColorSpace.sRGB)!

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

// ─── освещение ───

struct Look {
    var skyTop, skyMid, skyLow: Int
    var sun: Int, sunGlow: CGFloat
    var cloud: Int, cloudA: CGFloat          // полосы касуми
    var fuji, fujiShade, snow: Int
    var sea: [Int], seaLine: Int             // кольца сэйгайха и линии между ними
    var mist: Int
    var stamp: Int
    var night: CGFloat                        // звёзды и луна
    var grain: CGFloat                        // фактура бумаги
    var vignette: CGFloat

    func blend(_ o: Look, _ t: CGFloat) -> Look {
        Look(skyTop: mix(skyTop, o.skyTop, t), skyMid: mix(skyMid, o.skyMid, t), skyLow: mix(skyLow, o.skyLow, t),
             sun: mix(sun, o.sun, t), sunGlow: mix(sunGlow, o.sunGlow, t),
             cloud: mix(cloud, o.cloud, t), cloudA: mix(cloudA, o.cloudA, t),
             fuji: mix(fuji, o.fuji, t), fujiShade: mix(fujiShade, o.fujiShade, t), snow: mix(snow, o.snow, t),
             sea: zip(sea, o.sea).map { mix($0, $1, t) }, seaLine: mix(seaLine, o.seaLine, t),
             mist: mix(mist, o.mist, t), stamp: mix(stamp, o.stamp, t),
             night: mix(night, o.night, t), grain: mix(grain, o.grain, t), vignette: mix(vignette, o.vignette, t))
    }
}

let night = Look(skyTop: 0x16161d, skyMid: 0x1f1f28, skyLow: 0x223249, sun: 0xffa066, sunGlow: 0,
                 cloud: 0x2a2a37, cloudA: 0.85, fuji: 0x363646, fujiShade: 0x2a2a37, snow: 0x9e9a86,
                 sea: [0x1a1a22, 0x223249, 0x2d4f67, 0x223249], seaLine: 0x54546d, mist: 0x223249,
                 stamp: 0x9c3438, night: 1, grain: 0.010, vignette: 0.38)
let dawn = Look(skyTop: 0x4a4a64, skyMid: 0x938aa9, skyLow: 0xe6b8a2, sun: 0xffa066, sunGlow: 0.45,
                cloud: 0xf2ecbc, cloudA: 0.45, fuji: 0x4a4a64, fujiShade: 0x3a3a52, snow: 0xe8e2c8,
                sea: [0x2d3d5c, 0x3a4e73, 0x4d699b, 0x3a4e73], seaLine: 0xd9b8a8, mist: 0xe6b8a2,
                stamp: 0xc34043, night: 0.2, grain: 0.014, vignette: 0.22)
let day = Look(skyTop: 0x9fb5c9, skyMid: 0xe5ddb0, skyLow: 0xf2ecbc, sun: 0xc84053, sunGlow: 0.0,
               cloud: 0xe7dba0, cloudA: 0.95, fuji: 0x4d699b, fujiShade: 0x3e5683, snow: 0xf2ecbc,
               sea: [0x3e5683, 0x4d699b, 0x6693bf, 0x4d699b], seaLine: 0xf2ecbc, mist: 0xf2ecbc,
               stamp: 0xc84053, night: 0, grain: 0.020, vignette: 0.12)
let sunset = Look(skyTop: 0x2a2a37, skyMid: 0xc34043, skyLow: 0xffa066, sun: 0xe6c384, sunGlow: 0.55,
                  cloud: 0x43242b, cloudA: 0.75, fuji: 0x9e3b36, fujiShade: 0x7a2e2e, snow: 0xffd8b0,
                  sea: [0x1f2a40, 0x223249, 0x2d4f67, 0x223249], seaLine: 0xffa066, mist: 0xe46876,
                  stamp: 0xc34043, night: 0.1, grain: 0.014, vignette: 0.3)
let dusk = Look(skyTop: 0x16161d, skyMid: 0x54546d, skyLow: 0xd27e99, sun: 0xd27e99, sunGlow: 0.15,
                cloud: 0x363646, cloudA: 0.8, fuji: 0x363646, fujiShade: 0x2a2a37, snow: 0xb8a8a8,
                sea: [0x1a1a22, 0x223249, 0x2d4f67, 0x223249], seaLine: 0x957fb8, mist: 0x938aa9,
                stamp: 0xa33539, night: 0.7, grain: 0.012, vignette: 0.34)

let frames: [(hour: CGFloat, look: Look)] = [
    (0.0,  night),
    (4.5,  night.blend(dawn, 0.45)),
    (6.0,  dawn),
    (8.0,  dawn.blend(day, 0.6)),
    (11.5, day),
    (15.5, day.blend(sunset, 0.3)),
    (18.0, sunset),
    (19.5, dusk),
]
let nightAgain: CGFloat = 21.5
let lightIndex = 4, darkIndex = 0

let horizon = H * 0.30

// ─── кадр ───

func render(hour: CGFloat, look L: Look) -> CGImage {
    let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    var seed: UInt64 = 0x4B41_4E41   // «KANA» — одинаковые звёзды и облака во всех кадрах
    func rnd() -> CGFloat {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat(seed >> 33) / CGFloat(1 << 31)
    }

    // небо
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(L.skyTop), rgb(L.skyMid), rgb(L.skyLow)] as CFArray,
                         locations: [0, 0.6, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: horizon), options: [.drawsAfterEndLocation])

    // звёзды
    for _ in 0..<110 {
        let x = rnd() * W, y = horizon + (H - horizon) * (0.25 + 0.75 * sqrt(rnd()))
        let r = (0.6 + rnd() * 1.3) * S, a = (0.2 + rnd() * 0.5) * L.night
        if a > 0.01 {
            ctx.setFillColor(rgb(0xdcd7ba, a))
            ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
    }

    // луна — полная, в мягком ореоле
    if L.night > 0.05 {
        let m = CGPoint(x: W * 0.80, y: H * 0.80), mr = 58 * S
        let halo = CGGradient(colorsSpace: cs, colors: [rgb(0xdcd7ba, 0.18 * L.night), rgb(0xdcd7ba, 0)] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(halo, startCenter: m, startRadius: mr, endCenter: m, endRadius: mr * 5, options: [])
        ctx.setFillColor(rgb(0xdcd7ba, 0.9 * L.night))
        ctx.fillEllipse(in: CGRect(x: m.x - mr, y: m.y - mr, width: mr * 2, height: mr * 2))
    }

    // солнце: дуга 6:00 → 19:00, встаёт и садится в море. Днём — плоский красный диск, как на гравюре
    let p = (hour - 6) / 13
    if p >= 0 && p <= 1 {
        let sun = CGPoint(x: W * (0.12 + 0.76 * p), y: horizon - 40 * S + H * 0.62 * sin(.pi * p))
        let sr = 105 * S
        if L.sunGlow > 0.01 {
            let g = CGGradient(colorsSpace: cs, colors: [rgb(L.sun, L.sunGlow), rgb(L.sun, L.sunGlow * 0.25), rgb(L.sun, 0)] as CFArray,
                               locations: [0, 0.35, 1])!
            ctx.drawRadialGradient(g, startCenter: sun, startRadius: sr, endCenter: sun, endRadius: W * 0.3, options: [])
        }
        ctx.setFillColor(rgb(L.sun, 0.95))
        ctx.fillEllipse(in: CGRect(x: sun.x - sr, y: sun.y - sr, width: sr * 2, height: sr * 2))
    }

    // полосы тумана касуми: длинные скруглённые ленты, часть — поверх солнца
    func kasumi(_ y: CGFloat, _ x0: CGFloat, _ x1: CGFloat, _ h: CGFloat) {
        let r = CGRect(x: W * x0, y: H * y, width: W * (x1 - x0), height: h * S)
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: h * S / 2, cornerHeight: h * S / 2, transform: nil))
        ctx.setFillColor(rgb(L.cloud, L.cloudA)); ctx.fillPath()
    }
    kasumi(0.72, -0.05, 0.38, 64)
    kasumi(0.675, 0.20, 0.52, 40)
    kasumi(0.575, 0.56, 1.05, 56)
    kasumi(0.535, 0.72, 0.96, 34)

    // Фудзи: вогнутые склоны, плоская вершина, правый склон в тени
    let cx = W * 0.60, peak = H * 0.63, base = horizon - 10 * S, half = W * 0.40, top = W * 0.038
    func slope(_ side: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx, y: base))
        path.addLine(to: CGPoint(x: cx + side * half, y: base))
        path.addQuadCurve(to: CGPoint(x: cx + side * top, y: peak),
                          control: CGPoint(x: cx + side * half * 0.28, y: base + (peak - base) * 0.18))
        path.addLine(to: CGPoint(x: cx, y: peak + 4 * S))
        path.closeSubpath()
        return path
    }
    ctx.addPath(slope(-1)); ctx.setFillColor(rgb(L.fuji)); ctx.fillPath()
    ctx.addPath(slope(1)); ctx.setFillColor(rgb(L.fujiShade)); ctx.fillPath()

    // снег: та же гора, обрезанная «пальцами» вниз по склонам
    ctx.saveGState()
    let both = CGMutablePath(); both.addPath(slope(-1)); both.addPath(slope(1))
    ctx.addPath(both); ctx.clip()
    let snowLine = CGMutablePath()
    let sl = peak - (peak - base) * 0.30
    snowLine.move(to: CGPoint(x: cx - half, y: H))
    var x = cx - half * 0.45
    snowLine.addLine(to: CGPoint(x: x, y: sl + 40 * S))
    while x < cx + half * 0.45 {
        let w = (26 + rnd() * 30) * S, depth = (30 + rnd() * 90) * S
        snowLine.addLine(to: CGPoint(x: x + w * 0.5, y: sl - depth))
        snowLine.addLine(to: CGPoint(x: x + w, y: sl + (10 + rnd() * 30) * S))
        x += w
    }
    snowLine.addLine(to: CGPoint(x: cx + half, y: H)); snowLine.closeSubpath()
    ctx.addPath(snowLine); ctx.setFillColor(rgb(L.snow)); ctx.fillPath()
    ctx.restoreGState()

    // дымка у подножия
    let mist = CGGradient(colorsSpace: cs, colors: [rgb(L.mist, 0), rgb(L.mist, 0.55), rgb(L.mist, 0)] as CFArray, locations: [0, 0.6, 1])!
    ctx.drawLinearGradient(mist, start: CGPoint(x: 0, y: horizon + 160 * S), end: CGPoint(x: 0, y: horizon - 20 * S), options: [])

    // море — сэйгайха: ряды чешуек из концентрических колец, у горизонта мельче
    var y = horizon, row = 0
    while y > -80 * S {
        let t = (horizon - y) / horizon                     // 0 у горизонта → 1 внизу
        let R = (16 + 58 * t * t) * S
        let off = row % 2 == 0 ? 0 : R
        var sx = -R + off
        while sx < W + R {
            for k in 0..<4 {
                let rr = R * (1 - CGFloat(k) * 0.24)
                let rect = CGRect(x: sx - rr, y: y - rr, width: rr * 2, height: rr * 2)
                ctx.setFillColor(rgb(L.sea[k])); ctx.fillEllipse(in: rect)
                if k == 0 {   // тонкая линия только по краю чешуйки — без ряби из обводок
                    ctx.setStrokeColor(rgb(L.seaLine, 0.45))
                    ctx.setLineWidth(max(1, 1.8 * S * (0.5 + t)))
                    ctx.strokeEllipse(in: rect.insetBy(dx: 0.5, dy: 0.5))
                }
            }
            sx += R * 2
        }
        y -= R * 0.5; row += 1
    }
    // у горизонта узор растворяется в дымке
    let fade = CGGradient(colorsSpace: cs, colors: [rgb(L.mist, 0.75), rgb(L.mist, 0)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(fade, start: CGPoint(x: 0, y: horizon + 6 * S), end: CGPoint(x: 0, y: horizon - 110 * S), options: [])

    // печать-ханко с иероглифом 波 («волна»)
    let st = CGRect(x: W - 150 * S, y: H * 0.30 + 90 * S, width: 78 * S, height: 78 * S)
    ctx.addPath(CGPath(roundedRect: st, cornerWidth: 10 * S, cornerHeight: 10 * S, transform: nil))
    ctx.setFillColor(rgb(L.stamp, 0.92)); ctx.fillPath()
    if let font = NSFont(name: "HiraMinProN-W6", size: 58 * S) {
        let str = NSAttributedString(string: "波", attributes: [.font: font, .foregroundColor: NSColor(cgColor: rgb(0xf2ecbc, 0.95))!])
        let line = CTLineCreateWithAttributedString(str)
        let b = CTLineGetImageBounds(line, ctx)
        ctx.textPosition = CGPoint(x: st.midX - b.midX, y: st.midY - b.midY)
        CTLineDraw(line, ctx)
    }

    // виньетка
    let vig = CGGradient(colorsSpace: cs, colors: [rgb(0, 0), rgb(0, L.vignette)] as CFArray, locations: [0.55, 1])!
    ctx.drawRadialGradient(vig, startCenter: CGPoint(x: W / 2, y: H / 2), startRadius: 0,
                           endCenter: CGPoint(x: W / 2, y: H / 2), endRadius: hypot(W, H) / 2, options: [])
    return ctx.makeImage()!
}

// фактура бумаги васи + дизеринг для 8-битного HEIC
let ci = CIContext(options: [.workingColorSpace: cs])
func papered(_ img: CGImage, _ amount: CGFloat) -> CGImage {
    let base = CIImage(cgImage: img)
    let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!
        .applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: amount, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: amount, y: 0, z: 0, w: 0),   // один канал на все — серое зерно
            "inputBVector": CIVector(x: amount, y: 0, z: 0, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBiasVector": CIVector(x: -amount / 2, y: -amount / 2, z: -amount / 2, w: 1),
        ])
        .cropped(to: base.extent)
    let sum = noise.applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: base])
    return ci.createCGImage(sum, from: base.extent, format: .RGBA8, colorSpace: cs)!
}

let images = frames.map { papered(render(hour: $0.hour, look: $0.look), $0.look.grain) }

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

// динамический HEIC: расписание в метаданных apple_desktop:h24 (как в wallpaper.swift)
var schedule: [[String: Any]] = frames.enumerated().map { ["i": $0.offset, "t": Double($0.element.hour / 24)] }
schedule.append(["i": 0, "t": Double(nightAgain / 24)])
let plist: [String: Any] = ["ap": ["l": lightIndex, "d": darkIndex], "ti": schedule]
let h24 = try! PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0).base64EncodedString()
let ns = "http://ns.apple.com/namespace/1.0/" as CFString
let meta = CGImageMetadataCreateMutable()
CGImageMetadataRegisterNamespaceForPrefix(meta, ns, "apple_desktop" as CFString, nil)
CGImageMetadataSetTagWithPath(meta, nil, "apple_desktop:h24" as CFString,
                              CGImageMetadataTagCreate(ns, "apple_desktop" as CFString, "h24" as CFString, .string, h24 as CFString)!)
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, "public.heic" as CFString, images.count, nil)!
let opts = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
for (i, img) in images.enumerated() {
    if i == 0 { CGImageDestinationAddImageAndMetadata(dest, img, meta, opts) } else { CGImageDestinationAddImage(dest, img, opts) }
}
guard CGImageDestinationFinalize(dest) else { print("не удалось записать \(out)"); exit(1) }
print("обои: \(out) — \(images.count) кадров, меняются по времени суток")
