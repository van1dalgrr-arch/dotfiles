// Обои «Звёздные треки»: длинная выдержка — звёзды чертят дуги вокруг полюса.
// Длина треков растёт к ночи. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let pole = CGPoint(x: W * 0.72, y: H * 0.78)
    let night = 1 - 0.6 * daylight(hour)
    let span = (0.25 + 0.55 * night) * .pi                         // длина дуги
    var r = Rng(seed: 0x57A7)
    ctx.setLineCap(.round)
    for _ in 0..<900 {
        let rad = pow(r.next(), 0.7) * W * 0.95
        let start = r.next() * 2 * .pi
        let c = r.next() < 0.5 ? mix(a, 0xffffff, r.next() * 0.6) : mix(b, 0xffffff, r.next() * 0.6)
        ctx.setStrokeColor(rgb(c, (0.12 + pow(r.next(), 2) * 0.6) * night))
        ctx.setLineWidth(max(0.7, (0.5 + pow(r.next(), 3) * 1.6) * S))
        ctx.addArc(center: pole, radius: rad, startAngle: start, endAngle: start + span * (0.6 + 0.4 * r.next()), clockwise: false)
        ctx.strokePath()
    }
    radialGlow(ctx, pole, 40 * S, 0xffffff, 0.35 * night)
    // тёмная земля внизу
    ctx.setFillColor(rgb(0x030304)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H * 0.12))
    let fade = CGGradient(colorsSpace: cs, colors: [rgb(a, 0.18), rgb(a, 0)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(fade, start: CGPoint(x: 0, y: H * 0.12), end: CGPoint(x: 0, y: H * 0.28), options: [])
    return bloom(ctx.makeImage()!, near: 2, far: 20, strength: 0.35)
}
