// Обои «Лепестки»: абстрактный цветок из полупрозрачных лепестков в три слоя.
// Цветок медленно поворачивается и меняет цвет за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let (a, b) = tint(hour)
    let c = CGPoint(x: W * 0.66, y: H * 0.50)
    let turn = hour / 24 * .pi / 3                                   // за сутки — 60°

    func layer(count: Int, length: CGFloat, width: CGFloat, offset: CGFloat, inner: Int, outer: Int, alpha: CGFloat) -> CGImage {
        let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 16, bytesPerRow: 0,
                            space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        for i in 0..<count {
            let ang = CGFloat(i) / CGFloat(count) * 2 * .pi + offset + turn
            ctx.saveGState()
            ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: ang)
            let petal = CGPath(ellipseIn: CGRect(x: 0, y: -width / 2, width: length, height: width), transform: nil)
            ctx.addPath(petal); ctx.clip()
            let g = CGGradient(colorsSpace: cs, colors: [rgb(inner, alpha), rgb(outer, alpha * 0.85), rgb(outer, alpha * 0.2)] as CFArray,
                               locations: [0, 0.6, 1])!
            ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: length, y: 0), options: [])
            ctx.restoreGState()
        }
        return ctx.makeImage()!
    }

    let base = canvas()
    radialGlow(base, c, 520 * S, a, 0.12)
    // задний слой размыт — глубина; передние резкие
    let back = blurred(layer(count: 10, length: 470 * S, width: 170 * S, offset: 0.3, inner: b, outer: a, alpha: 0.35), 18 * S)
    base.draw(ci.createCGImage(back, from: extent)!, in: extent)
    base.draw(layer(count: 12, length: 380 * S, width: 120 * S, offset: 0, inner: violet, outer: b, alpha: 0.42), in: extent)
    base.draw(layer(count: 8, length: 220 * S, width: 80 * S, offset: 0.2, inner: pink, outer: violet, alpha: 0.5), in: extent)
    radialGlow(base, c, 60 * S, mix(pink, 0xffffff, 0.4), 0.8)
    return bloom(base.makeImage()!, near: 6, far: 40, strength: 0.5)
}
