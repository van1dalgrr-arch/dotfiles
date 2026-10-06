// Обои «Стекло»: стеклянные шары с цветными бликами по краю и бликом света, как 3D-рендер.
// Шары медленно дрейфуют за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let turn = hour / 24 * 2 * .pi
    radialGlow(ctx, CGPoint(x: W * 0.70, y: H * 0.50), W * 0.45, a, 0.10)

    // шар: x, y (доли экрана), радиус, сдвиг фазы
    let balls: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (0.70, 0.52, 230, 0), (0.86, 0.78, 120, 1.3), (0.56, 0.24, 90, 2.4),
        (0.90, 0.30, 70, 3.6), (0.60, 0.80, 55, 4.7), (0.48, 0.55, 38, 5.5),
    ]
    for (i, (x, y, rad0, ph)) in balls.enumerated() {
        let rad = rad0 * S
        let p = CGPoint(x: W * x + 18 * S * cos(turn + ph), y: H * y + 22 * S * sin(turn * 1.4 + ph))
        let rim = i % 2 == 0 ? a : b
        let rect = CGRect(x: p.x - rad, y: p.y - rad, width: rad * 2, height: rad * 2)
        ctx.saveGState(); ctx.addEllipse(in: rect); ctx.clip()
        // тело: тёмное, к краю светится цветом (преломление)
        let body = CGGradient(colorsSpace: cs, colors: [rgb(0x08080c, 0.95), rgb(0x0c0c14, 0.9), rgb(rim, 0.55), rgb(mix(rim, 0xffffff, 0.3), 0.8)] as CFArray,
                              locations: [0, 0.6, 0.92, 1])!
        ctx.drawRadialGradient(body, startCenter: CGPoint(x: p.x + rad * 0.15, y: p.y - rad * 0.15), startRadius: 0,
                               endCenter: p, endRadius: rad, options: [])
        // отражение снизу справа
        radialGlow(ctx, CGPoint(x: p.x + rad * 0.45, y: p.y - rad * 0.5), rad * 0.6, mix(rim, pink, 0.4), 0.35)
        ctx.restoreGState()
        // блик сверху слева
        ctx.setFillColor(rgb(0xffffff, 0.75))
        ctx.fillEllipse(in: CGRect(x: p.x - rad * 0.55, y: p.y + rad * 0.35, width: rad * 0.32, height: rad * 0.2))
        ctx.setFillColor(rgb(0xffffff, 0.35))
        ctx.fillEllipse(in: CGRect(x: p.x - rad * 0.30, y: p.y + rad * 0.55, width: rad * 0.12, height: rad * 0.08))
    }
    return bloom(ctx.makeImage()!, near: 5, far: 40, strength: 0.6)
}
