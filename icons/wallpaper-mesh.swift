// Обои «Меш»: большие размытые цветовые пятна на чёрном, как у абстрактных обоев Apple.
// Пятна медленно дрейфуют за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let day = daylight(hour)
    let turn = hour / 24 * 2 * .pi

    // пятно: базовая точка, радиус, цвет, направление дрейфа
    let blobs: [(CGFloat, CGFloat, CGFloat, Int, CGFloat)] = [
        (0.22, 0.30, 0.42, a, 0.0), (0.78, 0.70, 0.46, b, 1.7), (0.60, 0.22, 0.30, violet, 3.1),
        (0.35, 0.82, 0.28, mix(b, pink, 0.4), 4.4), (0.88, 0.25, 0.22, indigo, 5.6),
    ]
    for (x, y, r, c, ph) in blobs {
        let p = CGPoint(x: W * (x + 0.07 * cos(turn + ph)), y: H * (y + 0.09 * sin(turn * 1.3 + ph)))
        ctx.setFillColor(rgb(c, 0.8))
        ctx.fillEllipse(in: CGRect(x: p.x - W * r, y: p.y - W * r * 0.75, width: W * r * 2, height: W * r * 1.5))
    }
    // сильное размытие и затемнение — остаётся мягкий цветной свет на почти чёрном
    let soft = blurred(ctx.makeImage()!, 190 * S)
        .applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0.32 + 0.08 * day, y: 0, z: 0, w: 0), "inputGVector": CIVector(x: 0, y: 0.32 + 0.08 * day, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: 0.32 + 0.08 * day, w: 0), "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)])
    let vignette = CIFilter(name: "CIVignette", parameters: [kCIInputImageKey: soft, kCIInputIntensityKey: 1.1, kCIInputRadiusKey: 2.2])!.outputImage!
    return ci.createCGImage(vignette.cropped(to: extent), from: extent, format: .RGBA16, colorSpace: cs)!
}
