// Обои «Кольца»: тонкие концентрические кольца, как радар или портал. Часть колец —
// дуги, которые за сутки медленно поворачиваются. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let day = daylight(hour)
    let c = CGPoint(x: W * 0.70, y: H * 0.46)
    let turn = hour / 24 * 2 * .pi

    stars(ctx, count: 160, alpha: 0.7 - 0.3 * day)
    radialGlow(ctx, c, 420 * S, a, 0.14 + 0.06 * day)

    var r = Rng(seed: 0x21A6)
    ctx.setLineCap(.round)
    for k in 0..<26 {
        let rad = 26 * S * pow(1.17, CGFloat(k))
        let t = CGFloat(k) / 25
        let alpha = 0.55 * pow(1 - t, 1.3) + 0.04
        ctx.setStrokeColor(rgb(mix(a, b, t), alpha))
        ctx.setLineWidth(max(1, (k % 4 == 0 ? 2.0 : 1.1) * S))
        if k % 3 == 1 {
            // дуга: свой размер и направление вращения
            let len = (0.5 + r.next() * 1.3) * .pi
            let start = r.next() * 2 * .pi + turn * (k % 2 == 0 ? 1 : -0.6)
            ctx.addArc(center: c, radius: rad, startAngle: start, endAngle: start + len, clockwise: false)
        } else {
            ctx.addEllipse(in: CGRect(x: c.x - rad, y: c.y - rad, width: rad * 2, height: rad * 2))
        }
        ctx.strokePath()
    }
    // яркая точка в центре
    radialGlow(ctx, c, 26 * S, mix(a, 0xffffff, 0.5), 0.9)
    return bloom(ctx.makeImage()!, near: 5, far: 40, strength: 0.85)
}
