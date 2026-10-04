// ============================================================
//   Общий набор для живых обоев (не запускается сам по себе).
//   Файл обоев задаёт render(hour:) и в конце вызывает runWallpaper();
//   `wall` склеивает этот набор с файлом обоев и собирает динамический HEIC.
//
//   12 кадров — каждые 2 часа; параметры обоев считаются от часа непрерывно,
//   поэтому соседние кадры похожи и macOS плавно перетекает между ними.
// ============================================================

import AppKit
import CoreImage
import CoreText

let kitArgs = CommandLine.arguments
let W: CGFloat = kitArgs.count > 2 ? CGFloat(Double(kitArgs[2])!) : 2560
let H: CGFloat = kitArgs.count > 3 ? CGFloat(Double(kitArgs[3])!) : 1664
let S = W / 2560
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ci = CIContext(options: [.workingColorSpace: cs])
let extent = CGRect(x: 0, y: 0, width: W, height: H)

// палитра (насыщенная, как в теме)
let violet = 0xa855f7, blue = 0x3b82f6, sky = 0x0ea5e9, pink = 0xec4899, indigo = 0x6366f1, orange = 0xf97316

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
func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }

// «день» 0…1: 0 ночью, 1 в 13:00, плавно (косинус)
func daylight(_ hour: CGFloat) -> CGFloat { (1 - cos((hour - 1) / 24 * 2 * .pi)) / 2 }

// цвет суток: ночь индиго → рассвет розовый → день синий → закат фиолетовый
func tint(_ hour: CGFloat) -> (a: Int, b: Int) {
    let light = 0x60a5fa   // чистый светло-синий: sky (#0ea5e9) на тёмном уходит в бирюзу
    let keys: [(CGFloat, Int, Int)] = [(0, indigo, blue), (5, violet, indigo), (7, pink, violet), (10, violet, light),
                                       (13, blue, light), (17, violet, blue), (19, pink, violet), (21, violet, indigo), (24, indigo, blue)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t))
    }
    return (indigo, blue)
}

// детерминированный «рандом» — во всех кадрах одинаковые звёзды/детали
struct Rng {
    var seed: UInt64
    mutating func next() -> CGFloat {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat(seed >> 33) / CGFloat(1 << 31)
    }
}

func canvas() -> CGContext {
    let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setFillColor(rgb(0x050507)); ctx.fill(extent)
    return ctx
}

func radialGlow(_ ctx: CGContext, _ p: CGPoint, _ r: CGFloat, _ c: Int, _ a: CGFloat) {
    let g = CGGradient(colorsSpace: cs, colors: [rgb(c, a), rgb(c, a * 0.35), rgb(c, 0)] as CFArray, locations: [0, 0.4, 1])!
    ctx.drawRadialGradient(g, startCenter: p, startRadius: 0, endCenter: p, endRadius: r, options: [])
}

func stars(_ ctx: CGContext, count: Int, alpha: CGFloat, seed: UInt64 = 0x57A2) {
    var r = Rng(seed: seed)
    for _ in 0..<count {
        let x = r.next() * W, y = r.next() * H
        let rad = (0.5 + pow(r.next(), 3) * 1.5) * S, a = (0.15 + pow(r.next(), 2) * 0.6) * alpha
        ctx.setFillColor(rgb(0xffffff, a))
        ctx.fillEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
    }
}

func blurred(_ img: CGImage, _ radius: CGFloat) -> CIImage {
    CIImage(cgImage: img).clampedToExtent().applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: radius]).cropped(to: extent)
}
// свечение: картинка + её размытые копии поверх (screen)
func bloom(_ img: CGImage, near: CGFloat = 8, far: CGFloat = 40, strength: CGFloat = 1) -> CGImage {
    let base = CIImage(cgImage: img)
    func k(_ i: CIImage, _ v: CGFloat) -> CIImage {
        i.applyingFilter("CIColorMatrix", parameters: ["inputRVector": CIVector(x: v, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: v, z: 0, w: 0), "inputBVector": CIVector(x: 0, y: 0, z: v, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)])
    }
    let glow = k(blurred(img, near * S), 0.7 * strength)
        .applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: k(blurred(img, far * S), 0.6 * strength)])
    let out = glow.applyingFilter("CIScreenBlendMode", parameters: [kCIInputBackgroundImageKey: base])
    return ci.createCGImage(out, from: extent, format: .RGBA16, colorSpace: cs)!
}

// ─── сборка: 12 кадров, расписание apple_desktop:h24 ───
func runWallpaper(_ render: (CGFloat) -> CGImage) {
    let out = kitArgs.count > 1 ? kitArgs[1] : "wallpaper.heic"
    let hours: [CGFloat] = stride(from: 0, to: 24, by: 2).map { CGFloat($0) }
    let images = hours.map { h -> CGImage in
        ci.createCGImage(CIImage(cgImage: render(h)), from: extent, format: .RGBA8, colorSpace: cs)!
    }
    if out.hasSuffix(".png") {   // превью — кадр на 13:00
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, images[6], nil); CGImageDestinationFinalize(dest)
        return
    }
    let schedule: [[String: Any]] = hours.enumerated().map { ["i": $0.offset, "t": Double($0.element / 24)] }
    let plist: [String: Any] = ["ap": ["l": 6, "d": 0], "ti": schedule]
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
}
