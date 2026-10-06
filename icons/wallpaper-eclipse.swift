// Обои «Затмение»: чёрный диск с короной, лучи, звёзды. На рассвете и закате —
// «бриллиантовое кольцо» (вспышка на краю диска). Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let day = daylight(hour)
    let c = CGPoint(x: W * 0.64, y: H * 0.58), R = 210 * S

    stars(ctx, count: 260, alpha: 1 - 0.5 * day)
    radialGlow(ctx, c, R * 4.2, a, 0.10 + 0.06 * day)            // дальнее сияние
    radialGlow(ctx, c, R * 2.2, b, 0.30 + 0.15 * day)            // корона

    // лучи короны
    var r = Rng(seed: 0xEC11)
    ctx.setLineCap(.round)
    for _ in 0..<90 {
        let ang = r.next() * 2 * .pi, len = R * (0.25 + pow(r.next(), 2) * 1.1)
        ctx.setStrokeColor(rgb(mix(a, b, r.next()), 0.10 + r.next() * 0.12))
        ctx.setLineWidth((0.8 + r.next() * 1.6) * S)
        ctx.move(to: CGPoint(x: c.x + cos(ang) * R * 1.02, y: c.y + sin(ang) * R * 1.02))
        ctx.addLine(to: CGPoint(x: c.x + cos(ang) * (R + len), y: c.y + sin(ang) * (R + len)))
        ctx.strokePath()
    }

    // светящийся край и чёрный диск
    ctx.setStrokeColor(rgb(mix(a, 0xffffff, 0.35), 0.95)); ctx.setLineWidth(3.5 * S)
    ctx.strokeEllipse(in: CGRect(x: c.x - R, y: c.y - R, width: R * 2, height: R * 2))
    ctx.setFillColor(rgb(0x020203))
    ctx.fillEllipse(in: CGRect(x: c.x - R + 2 * S, y: c.y - R + 2 * S, width: (R - 2 * S) * 2, height: (R - 2 * S) * 2))

    // бриллиантовое кольцо около 7:00 и 19:00
    let flare = max(exp(-pow((hour - 7) / 1.2, 2)), exp(-pow((hour - 19) / 1.2, 2)))
    if flare > 0.02 {
        let ang: CGFloat = hour < 12 ? 2.4 : 0.7
        let p = CGPoint(x: c.x + cos(ang) * R, y: c.y + sin(ang) * R)
        radialGlow(ctx, p, 150 * S, 0xffffff, 0.75 * flare)
        radialGlow(ctx, p, 40 * S, 0xffffff, flare)
    }
    return bloom(ctx.makeImage()!, near: 6, far: 50, strength: 0.9)
}
