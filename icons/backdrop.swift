// Фон терминала из обоев: swift backdrop.swift <обои> <glow|aurora|haze|glass> <выход.png>
// Из обоев — только цвета и свет (тёмное прозрачно); форма glow и aurora своя. У HEIC — кадр текущего часа.
import AppKit
import CoreImage

let args = CommandLine.arguments
guard args.count == 4 else { print("swift backdrop.swift <обои> <haze|glow|aurora|glass> <выход.png>"); exit(2) }
let (srcPath, style, outPath) = (args[1], args[2], args[3])

// кадр обоев: у динамического HEIC — по текущему часу
guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: srcPath) as CFURL, nil) else { print("нет файла: \(srcPath)"); exit(1) }
let frames = CGImageSourceGetCount(src)
let hour = Calendar.current.component(.hour, from: Date())
let index = frames > 1 ? min(frames - 1, hour * frames / 24) : 0
guard let frame = CGImageSourceCreateImageAtIndex(src, index, nil) else { exit(1) }

func smooth(_ a: Double, _ b: Double, _ x: Double) -> Double { let t = max(0, min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t) }
let styleNames = ["haze", "glow", "aurora", "glass"]
guard styleNames.contains(style) else { print("стили: \(styleNames.joined(separator: " "))"); exit(2) }

// холст под окно терминала 16:10; кадр обоев — «cover»
let W = 1600, H = 1000
let ctx = CIContext()
let scale = max(Double(W) / Double(frame.width), Double(H) / Double(frame.height))
let base = CIImage(cgImage: frame)
    .transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    .transformed(by: CGAffineTransform(translationX: -(Double(frame.width) * scale - Double(W)) / 2,
                                       y: -(Double(frame.height) * scale - Double(H)) / 2))
func pixels(_ im: CIImage, blur: Double) -> [UInt8] {
    var img = im
    if blur > 0 { img = img.clampedToExtent().applyingGaussianBlur(sigma: blur) }
    var px = [UInt8](repeating: 0, count: W * H * 4)
    ctx.render(img.cropped(to: CGRect(x: 0, y: 0, width: W, height: H)), toBitmap: &px, rowBytes: W * 4,
               bounds: CGRect(x: 0, y: 0, width: W, height: H), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
    return px
}

// главные цвета обоев: яркие насыщенные пиксели по 12 секторам оттенка, два самых весомых
typealias RGB = (Double, Double, Double)
func palette(_ px: [UInt8]) -> [RGB] {
    var sum = [RGB](repeating: (0, 0, 0), count: 12), weight = [Double](repeating: 0, count: 12)
    for i in stride(from: 0, to: px.count, by: 4 * 7) {
        let r = Double(px[i]) / 255, g = Double(px[i + 1]) / 255, b = Double(px[i + 2]) / 255
        let mx = max(r, g, b), mn = min(r, g, b), sat = mx > 0 ? (mx - mn) / mx : 0
        guard mx > 0.2, sat > 0.25 else { continue }
        var h: Double = mx == r ? (g - b) / (mx - mn) : mx == g ? 2 + (b - r) / (mx - mn) : 4 + (r - g) / (mx - mn)
        h = (h < 0 ? h + 6 : h) / 6
        let bin = min(11, Int(h * 12)), w = mx * sat
        sum[bin] = (sum[bin].0 + r * w, sum[bin].1 + g * w, sum[bin].2 + b * w); weight[bin] += w
    }
    let top = (0..<12).sorted { weight[$0] > weight[$1] }.filter { weight[$0] > 0 }
    var out = top.prefix(2).map { i -> RGB in
        let c = (sum[i].0 / weight[i], sum[i].1 / weight[i], sum[i].2 / weight[i]); let m = max(c.0, c.1, c.2)
        return (c.0 / m, c.1 / m, c.2 / m)                       // на полную яркость
    }
    if out.isEmpty { out = [(0.66, 0.33, 0.97)] }                 // монохромные обои — фиолетовый акцент
    if out.count == 1 { out.append((out[0].2, out[0].0, out[0].1)) }
    return out
}

var px = pixels(base, blur: style == "glass" ? 5 : 70)
let pal = palette(pixels(base, blur: 12))
let (c1, c2) = (pal[0], pal[1])

// свет пикселя (x, y ∈ 0…1, y = 0 внизу) → цвет и альфа
func light(_ x: Double, _ y: Double, _ i: Int) -> (RGB, Double) {
    switch style {
    case "glow":     // два цветных пятна света: большое из правого нижнего угла, малое — слева сверху
        let a1 = exp(-pow(hypot((1 - x) * 1.1, y * 1.6) / 0.55, 2)) * 0.75
        let a2 = exp(-pow(hypot(x * 1.4, (1 - y) * 1.9) / 0.38, 2)) * 0.45
        let a = 1 - (1 - a1) * (1 - a2), k = a1 / max(a1 + a2, 1e-6)
        return ((c1.0 * k + c2.0 * (1 - k), c1.1 * k + c2.1 * (1 - k), c1.2 * k + c2.2 * (1 - k)), a)
    case "aurora":   // волнистые ленты сияния у нижнего края, цвет перетекает слева направо
        var a = 0.0
        for (amp, freq, phase, thick, base0) in [(0.05, 7.0, 0.3, 0.07, 0.2), (0.04, 11.0, 1.7, 0.05, 0.12), (0.06, 5.0, 2.9, 0.09, 0.28)] {
            let center = base0 + amp * sin(x * freq + phase)
            a = max(a, exp(-pow((y - center) / thick, 2)) * (0.35 + 0.65 * smooth(0.0, 0.25, 1 - abs(x - 0.5) * 1.6)))
        }
        a *= 0.5 * (1 - smooth(0.08, 0.42, y))
        let k = x
        return ((c1.0 * (1 - k) + c2.0 * k, c1.1 * (1 - k) + c2.1 * k, c1.2 * (1 - k) + c2.2 * k), a)
    default:         // haze / glass — свет самих обоев: тёмное прозрачно
        let r = Double(px[i]) / 255, g = Double(px[i + 1]) / 255, b = Double(px[i + 2]) / 255
        let lum = max(r, g, b)
        var a = smooth(0.04, 0.6, lum)
        if style == "haze" { a = min(1, a * 1.4) * 0.45 }
        else { a *= 0.3 * (1 - smooth(0.35, 1.0, hypot(x - 0.5, y - 0.5) * 1.35)) }   // glass: виньетка
        return (lum > 0.001 ? (r / lum, g / lum, b / lum) : (0, 0, 0), a)
    }
}

for row in 0..<H {
    let y = Double(H - 1 - row) / Double(H - 1)
    for col in 0..<W {
        let i = (row * W + col) * 4
        let (c, a) = light(Double(col) / Double(W - 1), y, i)
        px[i] = UInt8(min(255, c.0 * a * 255)); px[i + 1] = UInt8(min(255, c.1 * a * 255))
        px[i + 2] = UInt8(min(255, c.2 * a * 255)); px[i + 3] = UInt8(min(255, a * 255))
    }
}

let out = CGContext(data: &px, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4,
                    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
let rep = NSBitmapImageRep(cgImage: out.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: outPath))
print("\(style) ← \(URL(fileURLWithPath: srcPath).lastPathComponent) (кадр \(index + 1)/\(frames)) → \(outPath)")
