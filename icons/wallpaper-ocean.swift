// Обои «Океан»: ночное море, лунная дорожка из бликов на волнах, ровный горизонт.
// За сутки луна идёт по небу, дорожка смещается за ней. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let hy = H * 0.44
    let moonX = W * (0.15 + 0.7 * hour / 24)
    let moon = CGPoint(x: moonX, y: hy + H * (0.18 + 0.22 * sin(hour / 24 * .pi)))

    // небо: лёгкий градиент к горизонту + звёзды
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(0x050507), rgb(mix(a, 0x050507, 0.93))] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: hy), options: [])
    stars(ctx, count: 200, alpha: 0.6)
    radialGlow(ctx, moon, 260 * S, b, 0.22)
    ctx.setFillColor(rgb(mix(b, 0xffffff, 0.75))); ctx.fillEllipse(in: CGRect(x: moon.x - 34 * S, y: moon.y - 34 * S, width: 68 * S, height: 68 * S))

    // море
    ctx.setFillColor(rgb(0x040406)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: hy))
    var r = Rng(seed: 0x0CE4)
    ctx.setLineCap(.round)
    for _ in 0..<2600 {
        let depth = pow(r.next(), 1.7)                      // 0 у горизонта … 1 у зрителя
        let y = hy - depth * hy
        let spread = (60 + depth * 520) * S                 // дорожка расширяется к зрителю
        let dx = (r.next() + r.next() + r.next() - 1.5) / 1.5 * spread * 2
        let x = moonX + dx
        let near = exp(-pow(dx / spread, 2))                // ближе к дорожке — ярче
        let len = (4 + depth * 40) * S * (0.4 + r.next())
        let alpha = (0.05 + 0.75 * near) * (0.35 + 0.65 * r.next())
        ctx.setStrokeColor(rgb(mix(b, 0xffffff, 0.35 * near), alpha))
        ctx.setLineWidth(max(0.8, (0.6 + depth * 2.2) * S))
        ctx.move(to: CGPoint(x: x - len / 2, y: y)); ctx.addLine(to: CGPoint(x: x + len / 2, y: y)); ctx.strokePath()
    }
    // горизонт
    ctx.setStrokeColor(rgb(mix(a, 0xffffff, 0.2), 0.25)); ctx.setLineWidth(max(1, S))
    ctx.move(to: CGPoint(x: 0, y: hy)); ctx.addLine(to: CGPoint(x: W, y: hy)); ctx.strokePath()
    return bloom(ctx.makeImage()!, near: 4, far: 36, strength: 0.6)
}
