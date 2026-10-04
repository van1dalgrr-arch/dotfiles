#!/usr/bin/env swift
// ============================================================
//   Живые обои «Шёлк»: сотни тончайших нитей скручиваются в светящуюся ленту
//   на почти чёрном фоне. Свечение, пылинки, цвет ленты меняется за сутки.
//
//   swift wallpaper-silk.swift silk.heic   — динамические обои macOS
//   swift wallpaper-silk.swift preview/    — каждый кадр отдельным PNG
//   [ширина] [высота] — третьим/четвёртым аргументом (по умолчанию 2560×1664)
// ============================================================

import AppKit
import CoreImage

let args = CommandLine.arguments
let out = args.count > 1 ? args[1] : "silk.heic"
let W = args.count > 2 ? CGFloat(Double(args[2])!) : 2560
let H = args.count > 3 ? CGFloat(Double(args[3])!) : 1664
let S = W / 2560
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let gray = CGColorSpaceCreateDeviceGray()
let ci = CIContext(options: [.workingColorSpace: cs])

func color(_ h: Int) -> CIColor {
    CIColor(red: CGFloat((h >> 16) & 0xff) / 255, green: CGFloat((h >> 8) & 0xff) / 255, blue: CGFloat(h & 0xff) / 255)
}

let violet = 0xa855f7, blue = 0x3b82f6, sky = 0x0ea5e9, pink = 0xec4899, indigo = 0x6366f1, orange = 0xf97316

struct Look { var a, b: Int; var glow: CGFloat }   // цвет ленты слева → справа, сила свечения
let frames: [(hour: CGFloat, look: Look)] = [
    (0.0,  Look(a: indigo, b: blue,   glow: 0.75)),
    (5.0,  Look(a: violet, b: indigo, glow: 0.8)),
    (7.0,  Look(a: pink,   b: violet, glow: 0.9)),
    (10.0, Look(a: violet, b: sky,    glow: 0.95)),
    (13.0, Look(a: blue,   b: sky,    glow: 1.0)),
    (17.0, Look(a: violet, b: blue,   glow: 0.95)),
    (19.0, Look(a: orange, b: pink,   glow: 0.9)),
    (21.0, Look(a: pink,   b: violet, glow: 0.8)),
]
let lightIndex = 4, darkIndex = 0

// ─── форма ленты (одинакова во всех кадрах — меняется только цвет) ───

// центр ленты, её ширина и закрутка вдоль x
func center(_ u: CGFloat) -> CGFloat {
    H * 0.50 + 170 * S * sin(u * .pi * 1.6 + 0.5) + 70 * S * sin(u * .pi * 3.4 + 1.9) - 120 * S * (u - 0.5)
}
func width(_ u: CGFloat) -> CGFloat { (50 + 210 * pow(max(0, sin(u * .pi)), 1.4)) * S }   // max: за краем экрана sin < 0 → NaN
func twist(_ u: CGFloat) -> CGFloat { 2.4 * sin(u * .pi * 1.25 + 0.3) + u * 4.2 }

// интенсивность света: нити рисуются белым на чёрном (потом окрашиваются градиентом)
func strands(count: Int, alpha: CGFloat, lineWidth: CGFloat, spread: CGFloat, phase: CGFloat, yShift: CGFloat) -> CIImage {
    // 16 бит RGBA: серый 16-битный холст CoreImage читает неверно (нити пропадали)
    let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    ctx.setLineWidth(lineWidth); ctx.setLineCap(.round)
    for i in 0..<count {
        let t = CGFloat(i) / CGFloat(count - 1) * .pi
        let path = CGMutablePath()
        for k in 0...420 {
            let u = CGFloat(k) / 420 * 1.2 - 0.1                       // чуть за края экрана
            let y = center(u) + yShift + width(u) * spread * cos(twist(u) + t + phase)
            let p = CGPoint(x: u * W, y: y)
            k == 0 ? path.move(to: p) : path.addLine(to: p)
        }
        // нити по краю ленты ярче — так видно объём и изгиб
        let edge = 0.45 + 0.55 * pow(abs(cos(t)), 0.6)
        ctx.setStrokeColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: alpha * edge))
        ctx.addPath(path); ctx.strokePath()
    }
    return CIImage(cgImage: ctx.makeImage()!)
}

// пылинки вокруг ленты
func dust() -> CIImage {
    let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8, bytesPerRow: 0,
                        space: gray, bitmapInfo: CGImageAlphaInfo.none.rawValue)!
    ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    var seed: UInt64 = 0x51_1C
    func rnd() -> CGFloat { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return CGFloat(seed >> 33) / CGFloat(1 << 31) }
    for _ in 0..<520 {
        let u = rnd() * 1.1 - 0.05
        let gauss = (rnd() + rnd() + rnd() - 1.5) * 2                  // гуще у ленты
        let y = center(u) + gauss * width(max(0, min(1, u))) * 1.6
        let r = (0.5 + pow(rnd(), 4) * 2.2) * S
        ctx.setFillColor(CGColor(gray: 1, alpha: 0.15 + pow(rnd(), 2) * 0.6))
        ctx.fillEllipse(in: CGRect(x: u * W - r, y: y - r, width: r * 2, height: r * 2))
    }
    return CIImage(cgImage: ctx.makeImage()!)
}

// форма считается один раз
let extent = CGRect(x: 0, y: 0, width: W, height: H)
let main = strands(count: 220, alpha: 0.075, lineWidth: max(0.8, 1.1 * S), spread: 1.0, phase: 0, yShift: 0)
let echo = strands(count: 90, alpha: 0.035, lineWidth: max(0.8, 0.9 * S), spread: 1.6, phase: 1.3, yShift: -40 * S)
let specks = dust()
func blur(_ img: CIImage, _ r: CGFloat) -> CIImage {
    img.clampedToExtent().applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: r]).cropped(to: extent)
}
func add(_ a: CIImage, _ b: CIImage) -> CIImage { a.applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: b]) }
func scale(_ img: CIImage, _ k: CGFloat) -> CIImage {
    img.applyingFilter("CIColorMatrix", parameters: [
        "inputRVector": CIVector(x: k, y: 0, z: 0, w: 0), "inputGVector": CIVector(x: 0, y: k, z: 0, w: 0),
        "inputBVector": CIVector(x: 0, y: 0, z: k, w: 0), "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)])
}
let lines = add(main, echo)
let bloomNear = blur(lines, 10 * S), bloomFar = blur(lines, 60 * S)

func render(_ L: Look) -> CGImage {
    // градиент цвета вдоль ленты (по диагонали)
    let grad = CIFilter(name: "CILinearGradient", parameters: [
        "inputPoint0": CIVector(x: W * 0.1, y: H * 0.7), "inputPoint1": CIVector(x: W * 0.9, y: H * 0.3),
        "inputColor0": color(L.a), "inputColor1": color(L.b)])!.outputImage!.cropped(to: extent)

    // свет = нити + ближнее и дальнее свечение
    let light = add(add(lines, scale(bloomNear, 0.9 * L.glow)), scale(bloomFar, 1.6 * L.glow))
    let tinted = grad.applyingFilter("CIMultiplyCompositing", parameters: [kCIInputBackgroundImageKey: light])
    let whiteCore = scale(lines, 0.35)                                   // сердцевина нитей чуть белее
    let dustTinted = grad.applyingFilter("CIMultiplyCompositing", parameters: [kCIInputBackgroundImageKey: add(specks, scale(blur(specks, 3 * S), 1.5))])

    // фон: почти чёрный, к краям темнее
    let bg = CIFilter(name: "CIRadialGradient", parameters: [
        "inputCenter": CIVector(x: W * 0.5, y: H * 0.5), "inputRadius0": 0, "inputRadius1": hypot(W, H) * 0.6,
        "inputColor0": CIColor(red: 0.035, green: 0.035, blue: 0.045), "inputColor1": CIColor(red: 0.012, green: 0.012, blue: 0.016)])!
        .outputImage!.cropped(to: extent)

    let img = add(add(add(tinted, whiteCore), dustTinted), bg)
    return ci.createCGImage(img, from: extent, format: .RGBA8, colorSpace: cs)!
}

let images = frames.map { render($0.look) }

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
