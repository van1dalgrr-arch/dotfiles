// Любые обои → фон для терминала: swift terminal-grade.swift <картинка> <выход.png> [ширина высота]
// Картинка кадрируется «cover» под окно, затем тонируется: яркость выравнивается к одному уровню,
// блики прижаты, слева (где текст) и сверху темнее, мелочь чуть размыта — текст читается где угодно.
// У HEIC берётся кадр текущего часа. Вызывает backdrop (zsh/theme.zsh).
import AppKit
import CoreImage

let args = CommandLine.arguments
guard args.count >= 3 else { print("swift terminal-grade.swift <картинка> <выход.png> [w h]"); exit(2) }
let W: CGFloat = args.count > 3 ? CGFloat(Double(args[3])!) : 1600
let H: CGFloat = args.count > 4 ? CGFloat(Double(args[4])!) : 1000
let S = W / 1600
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ci = CIContext(options: [.workingColorSpace: cs])
let extent = CGRect(x: 0, y: 0, width: W, height: H)

guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: args[1]) as CFURL, nil) else { print("нет файла: \(args[1])"); exit(1) }
let frames = CGImageSourceGetCount(src)
let index = frames > 1 ? min(frames - 1, Calendar.current.component(.hour, from: Date()) * frames / 24) : 0
guard let frame = CGImageSourceCreateImageAtIndex(src, index, nil) else { exit(1) }
let scale = max(W / CGFloat(frame.width), H / CGFloat(frame.height))
let cover = CIImage(cgImage: frame)
    .transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    .transformed(by: CGAffineTransform(translationX: -(CGFloat(frame.width) * scale - W) / 2, y: -(CGFloat(frame.height) * scale - H) / 2))
    .cropped(to: extent)
let img = ci.createCGImage(cover, from: extent, format: .RGBA16, colorSpace: cs)!

func terminalGrade(_ img: CGImage) -> CGImage {
    let soft = CIImage(cgImage: img).clampedToExtent().applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 2.5 * S]).cropped(to: extent)
    // средняя яркость кадра → общий уровень ~0.27: и дневной, и ночной кадр одинаково спокойные
    var avg = [UInt8](repeating: 0, count: 4)
    ci.render(soft.applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: CIVector(cgRect: extent)]), toBitmap: &avg, rowBytes: 4,
              bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: cs)
    let luma = (0.2126 * CGFloat(avg[0]) + 0.7152 * CGFloat(avg[1]) + 0.0722 * CGFloat(avg[2])) / 255
    let gain = min(1.8, max(0.3, 0.27 / max(luma, 0.01)))
    let graded = soft
        .applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 1.4, kCIInputContrastKey: 0.95])
        .applyingFilter("CIColorMatrix", parameters: ["inputRVector": CIVector(x: gain, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: gain, z: 0, w: 0), "inputBVector": CIVector(x: 0, y: 0, z: gain, w: 0)])
        .applyingFilter("CIToneCurve", parameters: [                       // блики (окна, фонари) мягко прижаты
            "inputPoint0": CIVector(x: 0, y: 0), "inputPoint1": CIVector(x: 0.2, y: 0.2), "inputPoint2": CIVector(x: 0.4, y: 0.37),
            "inputPoint3": CIVector(x: 0.7, y: 0.5), "inputPoint4": CIVector(x: 1, y: 0.58)])
    // тень под текстом: слева направо от 55% к 0%, сверху ещё немного
    let shade = CIFilter(name: "CILinearGradient", parameters: [
        "inputPoint0": CIVector(x: 0, y: H * 0.5), "inputPoint1": CIVector(x: W * 0.75, y: H * 0.5),
        "inputColor0": CIColor(red: 0, green: 0, blue: 0, alpha: 0.32), "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: 0)])!.outputImage!.cropped(to: extent)
    let top = CIFilter(name: "CILinearGradient", parameters: [
        "inputPoint0": CIVector(x: 0, y: H), "inputPoint1": CIVector(x: 0, y: H * 0.55),
        "inputColor0": CIColor(red: 0, green: 0, blue: 0, alpha: 0.18), "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: 0)])!.outputImage!.cropped(to: extent)
    let out = top.composited(over: shade.composited(over: graded))
    return ci.createCGImage(out, from: extent, format: .RGBA16, colorSpace: cs)!
}

let out = terminalGrade(img)
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: args[2]) as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ci.createCGImage(CIImage(cgImage: out), from: extent, format: .RGBA8, colorSpace: cs)!, nil)
guard CGImageDestinationFinalize(dest) else { print("не удалось записать \(args[2])"); exit(1) }
