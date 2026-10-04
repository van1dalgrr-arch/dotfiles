// Обои «Сияние»: полярное сияние — тонкие светящиеся занавесы над тёмным горизонтом.
// Ночью ярче, днём почти гаснет. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let strength = 1 - 0.45 * daylight(hour)

    stars(ctx, count: 300, alpha: 0.4 + 0.6 * strength)

    // занавесы: вертикальные штрихи, низ ярче, вверх гаснут; волна по горизонтали
    let n = 1100
    var rays = Rng(seed: 0xA0A0)            // у каждого луча своя яркость и длина — фактура занавеса
    ctx.setLineCap(.butt)
    for i in 0..<n {
        let u = CGFloat(i) / CGFloat(n)
        let base = H * 0.36 + 90 * S * sin(u * .pi * 2.4 + 0.7) + 35 * S * sin(u * .pi * 6.1 + 2.0)
        let ray = pow(rays.next(), 1.8)
        let height = (220 + 420 * pow((sin(u * .pi * 3.1 + 1.2) + 1) / 2, 1.5)) * S * (0.6 + 0.6 * rays.next())
        let col = mix(a, b, (sin(u * .pi * 1.7) + 1) / 2)
        // низ луча проявляется плавно — без резкого края (иначе под сиянием читаются «холмы»)
        let peak = (0.12 + 0.5 * ray) * strength
        let g = CGGradient(colorsSpace: cs, colors: [rgb(col, 0), rgb(col, peak), rgb(col, peak * 0.35), rgb(col, 0)] as CFArray,
                           locations: [0, 0.12, 0.4, 1])!
        let x = u * W
        ctx.saveGState()
        ctx.clip(to: CGRect(x: x, y: base, width: max(1, 2.6 * S), height: height))
        ctx.drawLinearGradient(g, start: CGPoint(x: x, y: base), end: CGPoint(x: x, y: base + height), options: [])
        ctx.restoreGState()
    }

    return bloom(ctx.makeImage()!, near: 3, far: 28, strength: 0.6)
}
