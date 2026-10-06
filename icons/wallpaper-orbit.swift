#!/usr/bin/env swift
// ============================================================
//   Живые обои «Орбита»: вид из кабины корабля. Снизу край тёмной планеты
//   со светящейся атмосферой (фиолетовый → синий), чёрный космос со звёздами,
//   еле заметный HUD кабины. За сутки — орбитальный рассвет и закат над краем планеты.
//
//   swift wallpaper-orbit.swift orbit.heic   — динамические обои macOS
//   swift wallpaper-orbit.swift preview/     — каждый кадр отдельным PNG
//   [ширина] [высота] — третьим/четвёртым аргументом (по умолчанию 2560×1664)
// ============================================================

import AppKit
import CoreImage
import CoreText

let args = CommandLine.arguments
let out = args.count > 1 ? args[1] : "orbit.heic"
let W = args.count > 2 ? CGFloat(Double(args[2])!) : 2560
let H = args.count > 3 ? CGFloat(Double(args[3])!) : 1664
let S = W / 2560
let cs = CGColorSpace(name: CGColorSpace.sRGB)!

func rgb(_ h: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((h >> 16) & 0xff) / 255, green: CGFloat((h >> 8) & 0xff) / 255,
            blue: CGFloat(h & 0xff) / 255, alpha: a)
}

let violet = 0xa855f7, blue = 0x3b82f6, sky = 0x0ea5e9, pink = 0xec4899, orange = 0xf97316

// ─── свет кадра ───
struct Look {
    var rimLeft, rimRight: Int     // цвет атмосферы по краю планеты слева / справа
    var rim: CGFloat               // яркость атмосферы
    var sunX: CGFloat?             // где над краем стоит солнце (доля ширины), nil — нет
    var sunColor: Int
    var nebula: CGFloat            // слабая туманность наверху
}

let frames: [(hour: CGFloat, look: Look)] = [
    (0.0,  Look(rimLeft: violet, rimRight: blue,  rim: 0.55, sunX: nil,  sunColor: orange, nebula: 0.05)),  // ночная сторона
    (5.0,  Look(rimLeft: violet, rimRight: violet, rim: 0.70, sunX: nil, sunColor: orange, nebula: 0.05)),
    (6.5,  Look(rimLeft: orange, rimRight: violet, rim: 0.95, sunX: 0.16, sunColor: orange, nebula: 0.04)), // орбитальный рассвет
    (9.0,  Look(rimLeft: violet, rimRight: sky,   rim: 0.85, sunX: nil,  sunColor: orange, nebula: 0.03)),
    (13.0, Look(rimLeft: blue,   rimRight: sky,   rim: 1.00, sunX: nil,  sunColor: orange, nebula: 0.03)),  // дневная сторона
    (17.0, Look(rimLeft: blue,   rimRight: violet, rim: 0.90, sunX: nil, sunColor: pink,   nebula: 0.04)),
    (19.0, Look(rimLeft: violet, rimRight: pink,  rim: 0.95, sunX: 0.84, sunColor: pink,   nebula: 0.05)),  // закат
    (21.0, Look(rimLeft: violet, rimRight: blue,  rim: 0.65, sunX: nil,  sunColor: pink,   nebula: 0.05)),
]
let lightIndex = 4, darkIndex = 0

// планета: огромный круг, наружу торчит только верхний край
let R = W * 1.6
let planet = CGPoint(x: W * 0.5, y: H * 0.27 - R)
func limbY(_ x: CGFloat) -> CGFloat { planet.y + sqrt(R * R - (x - planet.x) * (x - planet.x)) }

// маска для перехода цвета атмосферы слева направо
let rightMask: CGImage = {
    let g = CGColorSpaceCreateDeviceGray()
    let m = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8, bytesPerRow: 0, space: g,
                      bitmapInfo: CGImageAlphaInfo.none.rawValue)!
    let grad = CGGradient(colorsSpace: g, colors: [CGColor(gray: 0, alpha: 1), CGColor(gray: 1, alpha: 1)] as CFArray, locations: [0.15, 0.85])!
    m.drawLinearGradient(grad, start: .zero, end: CGPoint(x: W, y: 0), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    return m.makeImage()!
}()

func render(_ L: Look) -> CGImage {
    let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    var seed: UInt64 = 0x0B17_A1
    func rnd() -> CGFloat {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat(seed >> 33) / CGFloat(1 << 31)
    }

    // космос
    ctx.setFillColor(rgb(0x050507)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    func glow(_ p: CGPoint, _ r: CGFloat, _ c: Int, _ a: CGFloat) {
        let g = CGGradient(colorsSpace: cs, colors: [rgb(c, a), rgb(c, a * 0.35), rgb(c, 0)] as CFArray, locations: [0, 0.4, 1])!
        ctx.drawRadialGradient(g, startCenter: p, startRadius: 0, endCenter: p, endRadius: r, options: [])
    }
    glow(CGPoint(x: W * 0.22, y: H * 0.86), W * 0.45, violet, L.nebula)
    glow(CGPoint(x: W * 0.85, y: H * 0.75), W * 0.35, blue, L.nebula * 0.8)

    // звёзды — только над планетой; несколько ярких с крестиком
    for i in 0..<320 {
        let x = rnd() * W, y = rnd() * H
        let r = (0.5 + pow(rnd(), 3) * 1.6) * S
        let a = 0.15 + pow(rnd(), 2) * 0.6
        let tint = [0xffffff, 0xffffff, 0xdbeafe, 0xede9fe][Int(rnd() * 4) % 4]
        guard y > limbY(x) + 30 * S else { continue }
        ctx.setFillColor(rgb(tint, a))
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        if i % 41 == 0 {   // блик-крестик
            ctx.setStrokeColor(rgb(tint, a * 0.5)); ctx.setLineWidth(max(0.7, 0.8 * S))
            let l = 7 * S
            ctx.move(to: CGPoint(x: x - l, y: y)); ctx.addLine(to: CGPoint(x: x + l, y: y))
            ctx.move(to: CGPoint(x: x, y: y - l)); ctx.addLine(to: CGPoint(x: x, y: y + l))
            ctx.strokePath()
        }
    }

    // атмосфера: круговое свечение над краем (ровная дуга), цвет слева → справа через маску
    func ring(_ c: Int, _ a: CGFloat, _ width: CGFloat) {
        let g = CGGradient(colorsSpace: cs, colors: [rgb(c, a), rgb(c, a * 0.25), rgb(c, 0)] as CFArray, locations: [0, 0.35, 1])!
        ctx.drawRadialGradient(g, startCenter: planet, startRadius: R - 4 * S, endCenter: planet, endRadius: R + width, options: [])
    }
    func atmosphere(_ a: CGFloat, _ width: CGFloat) {
        ring(L.rimLeft, a, width)
        ctx.saveGState()
        ctx.clip(to: CGRect(x: 0, y: 0, width: W, height: H), mask: rightMask)   // справа — второй цвет
        ring(L.rimRight, a, width)
        ctx.restoreGState()
    }
    atmosphere(0.22 * L.rim, 160 * S)   // широкое сияние
    atmosphere(0.75 * L.rim, 14 * S)    // тонкая яркая кромка

    // планета: почти чёрная, с едва заметной подсветкой изнутри по краю
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: planet.x - R, y: planet.y - R, width: R * 2, height: R * 2)); ctx.clip()
    ctx.setFillColor(rgb(0x030305)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let inner = CGGradient(colorsSpace: cs, colors: [rgb(mixColor(L.rimLeft, L.rimRight, 0.5), 0), rgb(mixColor(L.rimLeft, L.rimRight, 0.5), 0.10 * L.rim)] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(inner, startCenter: planet, startRadius: R - 120 * S, endCenter: planet, endRadius: R, options: [])
    ctx.restoreGState()

    // солнце над краем: точка, ореол и горизонтальный блик
    if let sx = L.sunX {
        let p = CGPoint(x: W * sx, y: limbY(W * sx) + 6 * S)
        glow(p, 260 * S, L.sunColor, 0.35)
        glow(p, 60 * S, 0xffffff, 0.8)
        let streak = CGGradient(colorsSpace: cs, colors: [rgb(0xffffff, 0), rgb(0xffffff, 0.5), rgb(0xffffff, 0)] as CFArray, locations: [0, 0.5, 1])!
        ctx.saveGState(); ctx.clip(to: CGRect(x: 0, y: p.y - 1.2 * S, width: W, height: 2.4 * S))
        ctx.drawLinearGradient(streak, start: CGPoint(x: p.x - 700 * S, y: 0), end: CGPoint(x: p.x + 700 * S, y: 0), options: [])
        ctx.restoreGState()
    }

    // ─── HUD кабины: еле заметные уголки, прицел, телеметрия ───
    let hud = rgb(0xffffff, 0.16)
    ctx.setStrokeColor(hud); ctx.setLineWidth(max(1, 1.4 * S))
    let m = 70 * S, l = 46 * S
    for (cx, cy, dx, dy) in [(m, H - m, 1.0, -1.0), (W - m, H - m, -1.0, -1.0), (m, m, 1.0, 1.0), (W - m, m, -1.0, 1.0)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        ctx.move(to: CGPoint(x: cx, y: cy + dy * l)); ctx.addLine(to: CGPoint(x: cx, y: cy)); ctx.addLine(to: CGPoint(x: cx + dx * l, y: cy))
    }
    ctx.strokePath()

    // прицел по центру
    let c = CGPoint(x: W / 2, y: H * 0.58), rr = 16 * S
    ctx.setStrokeColor(rgb(0xffffff, 0.11))
    ctx.strokeEllipse(in: CGRect(x: c.x - rr, y: c.y - rr, width: rr * 2, height: rr * 2))
    for (dx, dy) in [(1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)] as [(CGFloat, CGFloat)] {
        ctx.move(to: CGPoint(x: c.x + dx * rr * 1.6, y: c.y + dy * rr * 1.6))
        ctx.addLine(to: CGPoint(x: c.x + dx * rr * 2.6, y: c.y + dy * rr * 2.6))
    }
    ctx.strokePath()

    // шкала высоты справа
    ctx.setStrokeColor(rgb(0xffffff, 0.10))
    for i in 0..<21 {
        let y = H * 0.40 + CGFloat(i) * 16 * S, len = (i % 5 == 0 ? 18 : 9) * S
        ctx.move(to: CGPoint(x: W - m - len, y: y)); ctx.addLine(to: CGPoint(x: W - m, y: y))
    }
    ctx.strokePath()

    // подписи
    func label(_ s: String, _ x: CGFloat, _ y: CGFloat, _ a: CGFloat, right: Bool = false) {
        guard let f = NSFont(name: "JetBrainsMono Nerd Font", size: 15 * S) else { return }
        let str = NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: NSColor(cgColor: rgb(0xffffff, a))!, .kern: 2.5 * S])
        let line = CTLineCreateWithAttributedString(str)
        let w = CTLineGetTypographicBounds(line, nil, nil, nil)
        ctx.textPosition = CGPoint(x: right ? x - CGFloat(w) : x, y: y)
        CTLineDraw(line, ctx)
    }
    label("VESPER-1  ·  ORBIT", m + 4 * S, H - m - l - 34 * S, 0.22)
    label("ALT 408 KM   VEL 7.66 KM/S   INC 51.6°", m + 4 * S, m + l + 20 * S, 0.18)
    label("SYS NOMINAL  ●", W - m - 4 * S, m + l + 20 * S, 0.18, right: true)
    return ctx.makeImage()!
}

func mixColor(_ a: Int, _ b: Int, _ t: CGFloat) -> Int {
    [16, 8, 0].reduce(0) { acc, s in
        let x = CGFloat((a >> s) & 0xff), y = CGFloat((b >> s) & 0xff)
        return acc | (Int((x + (y - x) * t).rounded()) << s)
    }
}

// 8-битный HEIC: тонкий серый шум против «ступенек» на градиентах
let ci = CIContext(options: [.workingColorSpace: cs])
func dithered(_ img: CGImage) -> CGImage {
    let base = CIImage(cgImage: img), a: CGFloat = 0.004
    let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!
        .applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: a, y: 0, z: 0, w: 0), "inputGVector": CIVector(x: a, y: 0, z: 0, w: 0),
            "inputBVector": CIVector(x: a, y: 0, z: 0, w: 0), "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBiasVector": CIVector(x: -a / 2, y: -a / 2, z: -a / 2, w: 1),
        ]).cropped(to: base.extent)
    let sum = noise.applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: base])
    return ci.createCGImage(sum, from: base.extent, format: .RGBA8, colorSpace: cs)!
}

// 8 бит без шума: фильтр CIRandomGenerator давал тысячи белых точек-«звёзд» на чёрном
let images = frames.map { img -> CGImage in
    let r = render(img.look)
    return ci.createCGImage(CIImage(cgImage: r), from: CGRect(x: 0, y: 0, width: W, height: H), format: .RGBA8, colorSpace: cs)!
}

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
