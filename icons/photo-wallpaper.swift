// Фото → обои под экран: swift photo-wallpaper.swift <фото> <выход.heic|png> [ширина высота]
// Шумоподавление → Lanczos в два шага → кадр по центру → лёгкая резкость (MetalFX пробовал: ореолы на JPEG).
import AppKit
import CoreImage
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count >= 3 else { print("swift photo-wallpaper.swift <фото> <выход.heic|png> [w h]"); exit(2) }
let input = URL(fileURLWithPath: args[1]), output = URL(fileURLWithPath: args[2])

// размер экрана в пикселях (Retina), если не задан явно
var W = 2560.0, H = 1664.0
if args.count >= 5, let w = Double(args[3]), let h = Double(args[4]) { (W, H) = (w, h) }
else if let screen = NSScreen.main {
    let f = screen.frame, s = screen.backingScaleFactor
    (W, H) = (f.width * s, f.height * s)
}

guard let src = CIImage(contentsOf: input) else { print("не открыл: \(input.path)"); exit(1) }
let w = src.extent.width, h = src.extent.height
let scale = max(W / w, H / h)

// 1. шумоподавление — сильнее, чем сильнее будем увеличивать (артефакты JPEG растут вместе с картинкой)
var img = src.applyingFilter("CINoiseReduction", parameters: [
    "inputNoiseLevel": min(0.04, 0.008 * scale), "inputSharpness": 0.35])

// 2. увеличение Lanczos в два шага (половина масштаба + шумоподавление между ними —
//    так меньше «лестниц» на контурах, чем одним прыжком в 3–4 раза)
let ctx = CIContext(options: [.workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
let step = scale.squareRoot()
img = img.applyingFilter("CILanczosScaleTransform", parameters: [kCIInputScaleKey: step, kCIInputAspectRatioKey: 1.0])
    .applyingFilter("CINoiseReduction", parameters: ["inputNoiseLevel": 0.01, "inputSharpness": 0.4])
    .applyingFilter("CILanczosScaleTransform", parameters: [kCIInputScaleKey: scale / step, kCIInputAspectRatioKey: 1.0])

// 3. кадр по центру под пропорции экрана
let e = img.extent
img = img.cropped(to: CGRect(x: e.minX + (e.width - W) / 2, y: e.minY + (e.height - H) / 2, width: W, height: H))
    .transformed(by: CGAffineTransform(translationX: -(e.minX + (e.width - W) / 2), y: -(e.minY + (e.height - H) / 2)))

// 4. мягкая резкость: вернуть контуры после увеличения, не рисуя ореолов
img = img.applyingFilter("CIUnsharpMask", parameters: [
    kCIInputRadiusKey: 2.0, kCIInputIntensityKey: 0.45])

guard let cg = ctx.createCGImage(img, from: CGRect(x: 0, y: 0, width: W, height: H), format: .RGBA8,
                                colorSpace: CGColorSpace(name: CGColorSpace.sRGB)) else { exit(1) }
let type = output.pathExtension.lowercased() == "png" ? UTType.png : UTType.heic
guard let dest = CGImageDestinationCreateWithURL(output as CFURL, type.identifier as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(dest, cg, [kCGImageDestinationLossyCompressionQuality: 0.92] as CFDictionary)
guard CGImageDestinationFinalize(dest) else { print("не записал: \(output.path)"); exit(1) }
print("\(input.lastPathComponent) \(Int(w))×\(Int(h)) → ×\(String(format: "%.2f", scale)) → \(Int(W))×\(Int(H)) \(output.lastPathComponent)")
