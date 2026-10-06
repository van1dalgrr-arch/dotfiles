// Общий набор для живых обоев (сам не запускается): wall склеивает его с файлом обоев.
// 12 кадров через 2 часа, параметры считаются от часа непрерывно — macOS плавно перетекает между кадрами.

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
    if out.hasSuffix(".png") {
        // превью — кадр на 13:00; WALL_HOUR — другой час (backdrop берёт кадр текущего часа)
        let hour = ProcessInfo.processInfo.environment["WALL_HOUR"].flatMap { Double($0) }.map { CGFloat($0) } ?? 13
        let img = render(hour)
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, ci.createCGImage(CIImage(cgImage: img), from: extent, format: .RGBA8, colorSpace: cs)!, nil)
        CGImageDestinationFinalize(dest)
        return
    }
    let hours: [CGFloat] = stride(from: 0, to: 24, by: 2).map { CGFloat($0) }
    let images = hours.map { h -> CGImage in
        ci.createCGImage(CIImage(cgImage: render(h)), from: extent, format: .RGBA8, colorSpace: cs)!
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

// ─── для атмосферных сцен (туман, снег, сумерки) ───
// размыть уже нарисованное: дальние планы рисуются первыми и уходят в расфокус, ближние — резкие поверх
func soften(_ ctx: CGContext, _ radius: CGFloat) {
    guard radius > 0, let img = ctx.makeImage(),
          let out = ci.createCGImage(blurred(img, radius * S), from: extent, format: .RGBA16, colorSpace: cs) else { return }
    ctx.clear(extent); ctx.draw(out, in: extent)
}
// слой тумана: снизу плотнее (bottom), сверху реже (top) — между планами, как воздушная перспектива
func haze(_ ctx: CGContext, _ c: Int, bottom: CGFloat, top: CGFloat, from y0: CGFloat = 0, to y1: CGFloat = H) {
    let g = CGGradient(colorsSpace: cs, colors: [rgb(c, bottom), rgb(c, top)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: y0), end: CGPoint(x: 0, y: y1), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}
// плёночное зерно и виньетка: без них процедурная картинка выглядит «пластиковой»
func filmic(_ img: CGImage, grain: CGFloat = 0.035, vignette: CGFloat = 0.55) -> CGImage {
    let base = CIImage(cgImage: img)
    let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!.cropped(to: extent)
        .applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0, y: 1, z: 0, w: 0), "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 1, z: 0, w: 0), "inputAVector": CIVector(x: 0, y: 0, z: 0, w: grain),
            "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)])
    let grained = noise.applyingFilter("CISoftLightBlendMode", parameters: [kCIInputBackgroundImageKey: base])
    let out = grained.applyingFilter("CIVignetteEffect", parameters: [
        kCIInputCenterKey: CIVector(x: W / 2, y: H / 2), kCIInputRadiusKey: max(W, H) * 0.62, kCIInputIntensityKey: vignette])
    return ci.createCGImage(out.cropped(to: extent), from: extent, format: .RGBA16, colorSpace: cs)!
}
// тёплый огонёк (окно, фонарь) с ореолом в тумане
func lamp(_ ctx: CGContext, _ p: CGPoint, _ r: CGFloat, _ c: Int, _ a: CGFloat) {
    radialGlow(ctx, p, r * 9, c, a * 0.25)
    ctx.setFillColor(rgb(mix(c, 0xffffff, 0.5), a)); ctx.fillEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
}

// ─── город: панельные высотки и провода (туманный город, снегопад) ───
let warm = 0xffc27a

// панельная высотка: фасад, окна сеткой, светлые полосы лоджий. fogMix — насколько она утонула в тумане
func tower(_ ctx: CGContext, _ x: CGFloat, _ w: CGFloat, _ h: CGFloat, base y0: CGFloat, k: CGFloat,
           facade: Int, fog: Int, fogMix: CGFloat, lit: CGFloat, rng: inout Rng) {
    let body = mix(facade, fog, fogMix)
    ctx.setFillColor(rgb(body)); ctx.fill(CGRect(x: x, y: y0, width: w, height: h))
    // технический этаж и надстройка на крыше
    ctx.setFillColor(rgb(mix(body, fog, 0.15))); ctx.fill(CGRect(x: x + w * 0.3, y: y0 + h, width: w * 0.25, height: 14 * k * S))
    let floorH = 21 * k * S, winW = 9 * k * S, winH = 11 * k * S, step = 17 * k * S
    let cols = Int((w - 10 * k * S) / step), rows = Int((h - 20 * k * S) / floorH)
    let left = x + (w - CGFloat(cols) * step) / 2 + (step - winW) / 2
    // лоджии — вертикальные светлые полосы через каждые 3 окна
    ctx.setFillColor(rgb(mix(body, 0xffffff, 0.05)))
    var c = 1
    while c < cols { ctx.fill(CGRect(x: left + CGFloat(c) * step - 3 * k * S, y: y0, width: winW + 6 * k * S, height: h - 12 * k * S)); c += 3 }
    ctx.setFillColor(rgb(mix(body, 0x000000, 0.12), 0.5))
    for r in 0..<rows { ctx.fill(CGRect(x: x, y: y0 + 6 * k * S + CGFloat(r) * floorH, width: w, height: 1.2 * k * S)) }
    for r in 0..<rows {
        let floorMood = rng.next() < 0.25 ? 2.2 : 0.7          // на некоторых этажах окна горят чаще
        for c in 0..<cols {
            let wx = left + CGFloat(c) * step, wy = y0 + 10 * k * S + CGFloat(r) * floorH
            let on = rng.next() < lit * floorMood, v = rng.next()
            if on {
                let col = mix(mix(warm, 0xffe2b0, v), fog, fogMix * 0.75)
                ctx.setFillColor(rgb(col, 0.9)); ctx.fill(CGRect(x: wx, y: wy, width: winW, height: winH))
            } else {
                ctx.setFillColor(rgb(mix(mix(body, 0x000000, 0.25), fog, fogMix * 0.3), 0.55 + v * 0.3))
                ctx.fill(CGRect(x: wx, y: wy, width: winW, height: winH))
            }
        }
    }
}

// провод — провисающая цепная линия
func wire(_ ctx: CGContext, _ a: CGPoint, _ b: CGPoint, sag: CGFloat, _ c: Int, _ alpha: CGFloat, _ width: CGFloat) {
    let p = CGMutablePath(); p.move(to: a)
    for i in 1...60 {
        let t = CGFloat(i) / 60
        p.addLine(to: CGPoint(x: lerp(a.x, b.x, t), y: lerp(a.y, b.y, t) - sag * 4 * t * (1 - t)))
    }
    ctx.addPath(p); ctx.setStrokeColor(rgb(c, alpha)); ctx.setLineWidth(width * S); ctx.strokePath()
}
// отдельный прозрачный слой с размытием — кусты, сугробы, дальние кроны
func blurLayer(_ blur: CGFloat, _ draw: (CGContext) -> Void) -> CGImage {
    let layer = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                          space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    draw(layer)
    let img = layer.makeImage()!
    guard blur > 0 else { return img }
    return ci.createCGImage(CIImage(cgImage: img).applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: blur * S]).cropped(to: extent),
                            from: extent, format: .RGBA16, colorSpace: cs)!
}

