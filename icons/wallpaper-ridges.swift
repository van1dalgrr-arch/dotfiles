// Обои «Гребни»: стопка линий с пиками в центре — как «Unknown Pleasures» (Joy Division),
// цвет плавно уходит от фиолетового к синему. Пики немного смещаются за сутки.
// Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let shift = sin(hour / 24 * 2 * .pi) * 0.04
    let lines = 46, x0 = W * 0.30, x1 = W * 0.70
    let top = H * 0.80, bottom = H * 0.18
    let bg = rgb(0x050507)

    // рисуем от дальней (верхней) к ближней: каждая линия закрывает фон под собой
    for i in 0..<lines {
        var r = Rng(seed: UInt64(0x4D7 + i * 7919))
        let bumps = (0..<5).map { _ in (c: 0.38 + r.next() * 0.24 + shift, w: 0.015 + r.next() * 0.05, h: r.next()) }
        let t = CGFloat(i) / CGFloat(lines - 1)
        let base = top - (top - bottom) * t
        let path = CGMutablePath()
        var pts: [CGPoint] = []
        for k in 0...300 {
            let u = CGFloat(k) / 300
            let env = exp(-pow((u - 0.5) / 0.16, 2))                       // пики только в середине
            var y = bumps.reduce(0) { $0 + $1.h * exp(-pow((u - $1.c) / $1.w, 2)) } * 90 * S * env
            y += (r.next() - 0.5) * 6 * S * env                            // мелкая дрожь
            pts.append(CGPoint(x: x0 + (x1 - x0) * u, y: base + max(0, y)))
        }
        path.addLines(between: pts)
        let fill = path.mutableCopy()!
        fill.addLine(to: CGPoint(x: x1, y: base - 30 * S)); fill.addLine(to: CGPoint(x: x0, y: base - 30 * S)); fill.closeSubpath()
        ctx.addPath(fill); ctx.setFillColor(bg); ctx.fillPath()
        ctx.addPath(path)
        ctx.setStrokeColor(rgb(mix(a, b, t), 0.55 + 0.35 * (1 - abs(t - 0.5) * 2)))
        ctx.setLineWidth(max(1, 1.6 * S)); ctx.setLineJoin(.round)
        ctx.strokePath()
    }
    return bloom(ctx.makeImage()!, near: 3, far: 30, strength: 0.6)
}
