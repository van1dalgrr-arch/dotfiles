// Обои «Горизонт»: сетка-пол уходит к светящейся линии горизонта, сверху тёмное небо со звёздами.
// Сдержанный synthwave. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let day = daylight(hour)
    let hy = H * 0.38                                  // линия горизонта
    let vp = CGPoint(x: W / 2, y: hy)                  // точка схода

    stars(ctx, count: 220, alpha: 0.9 - 0.4 * day)
    radialGlow(ctx, CGPoint(x: W / 2, y: hy), W * 0.55, a, 0.16 + 0.08 * day)   // зарево над горизонтом

    // пол: тёмный
    ctx.setFillColor(rgb(0x040406)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: hy))

    // линии к точке схода — к краям тусклее
    ctx.setLineWidth(max(1, 1.2 * S))
    for i in -22...22 {
        let xb = W / 2 + CGFloat(i) * 180 * S
        let alpha = 0.22 * (1 - abs(CGFloat(i)) / 24)
        ctx.setStrokeColor(rgb(mix(a, b, 0.4), alpha))
        ctx.move(to: CGPoint(x: xb, y: -40 * S)); ctx.addLine(to: vp); ctx.strokePath()
    }
    // поперечные линии: чем ближе к зрителю, тем реже и ярче
    for k in 1...22 {
        let t = CGFloat(k) / 22
        let y = hy - hy * pow(t, 2.2)
        ctx.setStrokeColor(rgb(mix(a, b, 0.4), 0.05 + 0.22 * t))
        ctx.move(to: CGPoint(x: 0, y: y)); ctx.addLine(to: CGPoint(x: W, y: y)); ctx.strokePath()
    }
    // сетка растворяется у горизонта
    let fade = CGGradient(colorsSpace: cs, colors: [rgb(0x040406, 1), rgb(0x040406, 0)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(fade, start: CGPoint(x: 0, y: hy), end: CGPoint(x: 0, y: hy - 160 * S), options: [])

    // светящаяся линия горизонта
    let line = CGGradient(colorsSpace: cs, colors: [rgb(a, 0), rgb(mix(a, 0xffffff, 0.3), 0.95), rgb(b, 0)] as CFArray, locations: [0, 0.5, 1])!
    ctx.saveGState(); ctx.clip(to: CGRect(x: 0, y: hy - 1.5 * S, width: W, height: 3 * S))
    ctx.drawLinearGradient(line, start: CGPoint(x: 0, y: 0), end: CGPoint(x: W, y: 0), options: [])
    ctx.restoreGState()
    return bloom(ctx.makeImage()!, near: 6, far: 45, strength: 0.9)
}
