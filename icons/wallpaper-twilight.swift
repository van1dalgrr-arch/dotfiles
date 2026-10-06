// Обои «Сумерки» (аниме-небо): огромные кучевые облака, подсвеченные уходящим солнцем, первые звёзды,
// столбы с проводами и крыши маленького городка силуэтами. Цвет неба идёт по суткам. Собирается через wall.

func twilightKeys(_ hour: CGFloat) -> (zenith: Int, horizon: Int, sun: Int, stars: CGFloat) {
    let keys: [(CGFloat, Int, Int, Int, CGFloat)] = [
        (0, 0x05081a, 0x1a1d3e, 0x4a3d6e, 1.0), (4, 0x0a0f2a, 0x2a2a55, 0x6a4a80, 0.8), (6, 0x24306a, 0xe08a7a, 0xffb27a, 0.2),
        (9, 0x3a6ab8, 0xa8c8e8, 0xfff0d0, 0.0), (14, 0x3d70c0, 0xb0d0ee, 0xfff4dc, 0.0), (17, 0x2f4f9a, 0xf0a878, 0xffc27a, 0.0),
        (19, 0x1d2460, 0xf07a5a, 0xff8a50, 0.35), (21, 0x0b1030, 0x4a2a5a, 0xc0587a, 0.85), (24, 0x05081a, 0x1a1d3e, 0x4a3d6e, 1.0)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), mix(keys[i].3, keys[i + 1].3, t), lerp(keys[i].4, keys[i + 1].4, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3, keys[0].4)
}

// кучевое облако: сплошной силуэт из шаров в тени, внутри — мягкий тёплый свет со стороны солнца
// (у аниме-сумерек светится «брюхо» облака), край чуть размыт
func cumulus(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat, shade: Int, lit: Int, sun: CGPoint, rng: inout Rng) {
    var balls: [(CGPoint, CGFloat)] = []
    for _ in 0..<60 {
        let u = rng.next(), x = cx + (u - 0.5) * w
        let top = h * (1 - pow(abs(u - 0.5) * 2, 1.4))
        let r = (0.12 + rng.next() * 0.2) * h * (0.6 + 0.4 * (1 - abs(u - 0.5) * 2))
        balls.append((CGPoint(x: x, y: cy + r * 0.6 + rng.next() * max(0, top - r * 1.6)), r))
    }
    let shape = CGMutablePath()
    for (p, r) in balls { shape.addEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)) }
    shape.addRect(CGRect(x: cx - w * 0.42, y: cy, width: w * 0.84, height: h * 0.12))      // ровное дно
    let layer = blurLayer(2.5) { l in
        l.addPath(shape); l.setFillColor(rgb(shade)); l.fillPath()
        l.saveGState(); l.addPath(shape); l.clip()
        // объём: верх каждого шара светлее (небо), низ и бок к солнцу — тёплый свет
        for (p, r) in balls { radialGlow(l, CGPoint(x: p.x - r * 0.2, y: p.y + r * 0.45), r * 0.9, mix(shade, 0xffffff, 0.25), 0.35) }
        for (p, r) in balls {
            let dir = CGPoint(x: sun.x - p.x, y: sun.y - p.y), len = max(1, hypot(dir.x, dir.y))
            radialGlow(l, CGPoint(x: p.x + dir.x / len * r * 0.7, y: p.y + dir.y / len * r * 0.7), r * 1.1, lit, 0.55)
        }
        let under = CGGradient(colorsSpace: cs, colors: [rgb(lit, 0.75), rgb(lit, 0)] as CFArray, locations: [0, 1])!
        l.drawLinearGradient(under, start: CGPoint(x: 0, y: cy - h * 0.15), end: CGPoint(x: 0, y: cy + h * 0.35), options: [.drawsBeforeStartLocation])
        l.restoreGState()
    }
    ctx.draw(layer, in: extent)
}

runWallpaper { hour in
    let ctx = canvas()
    let (zen, hor, sunC, starA) = twilightKeys(hour)
    var rng = Rng(seed: 0x7311)
    let ground = H * 0.2
    let sun = CGPoint(x: W * 0.78, y: ground - H * 0.04)

    // небо: зенит → горизонт, плюс тёплое зарево у солнца
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(hor), rgb(mix(hor, zen, 0.6)), rgb(zen)] as CFArray, locations: [0, 0.35, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: ground), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])
    radialGlow(ctx, sun, W * 0.55, sunC, 0.45)
    stars(ctx, count: 600, alpha: starA, seed: 0x5A7)

    // облака: дальние плоские полосы и две большие кучевые башни
    ctx.draw(blurLayer(6) { l in
        var r2 = Rng(seed: 0xC10D)
        for _ in 0..<14 {
            let y = H * (0.45 + r2.next() * 0.35), x = r2.next() * W, w = (300 + r2.next() * 600) * S
            l.setFillColor(rgb(mix(zen, sunC, 0.35), 0.35)); l.fillEllipse(in: CGRect(x: x - w / 2, y: y, width: w, height: (14 + r2.next() * 20) * S))
        }
    }, in: extent)
    let shade = mix(mix(zen, hor, 0.35), 0x2a1f3a, 0.3), lit = mix(sunC, 0xffffff, 0.2)
    cumulus(ctx, cx: W * 0.32, cy: H * 0.36, w: W * 0.42, h: H * 0.42, shade: shade, lit: lit, sun: sun, rng: &rng)
    cumulus(ctx, cx: W * 0.72, cy: H * 0.5, w: W * 0.3, h: H * 0.3, shade: mix(shade, zen, 0.3), lit: mix(lit, zen, 0.2), sun: sun, rng: &rng)
    haze(ctx, hor, bottom: 0.35, top: 0.0, from: ground, to: H * 0.45)

    // городок: дома с двускатными и плоскими крышами, между ними кроны деревьев, редкие окна
    let roofs = mix(zen, 0x05060c, 0.8)
    ctx.setFillColor(rgb(roofs))
    for _ in 0..<26 {   // кроны: каждая — гроздь мелких шаров, а не один круг
        let tx = rng.next() * W, ty = ground * (0.45 + rng.next() * 0.35), size = (40 + rng.next() * 50) * S
        for _ in 0..<14 {
            let r = size * (0.25 + rng.next() * 0.25), a = rng.next() * .pi, d = size * rng.next() * 0.7
            ctx.fillEllipse(in: CGRect(x: tx + cos(a) * d - r, y: ty + sin(a) * d * 0.8 - r, width: r * 2, height: r * 2))
        }
    }
    var x: CGFloat = -30 * S
    while x < W {
        let w = (70 + rng.next() * 120) * S, h = ground * (0.35 + rng.next() * 0.45)
        ctx.setFillColor(rgb(roofs)); ctx.fill(CGRect(x: x, y: 0, width: w, height: h))
        if rng.next() < 0.65 {
            let roof = CGMutablePath()
            roof.move(to: CGPoint(x: x - 8 * S, y: h)); roof.addLine(to: CGPoint(x: x + w * 0.5, y: h + w * 0.16)); roof.addLine(to: CGPoint(x: x + w + 8 * S, y: h)); roof.closeSubpath()
            ctx.addPath(roof); ctx.fillPath()
        } else {
            ctx.fill(CGRect(x: x + w * 0.6, y: h, width: 14 * S, height: 30 * S))    // бак на плоской крыше
        }
        if rng.next() < 0.55 {
            ctx.setFillColor(rgb(0xffc98a, 0.45 + starA * 0.45)); ctx.fill(CGRect(x: x + w * (0.2 + rng.next() * 0.5), y: h * (0.35 + rng.next() * 0.3), width: 12 * S, height: 10 * S))
        }
        x += w + rng.next() * 30 * S
    }

    // столбы и провода — главный мотив аниме-сумерек
    let pole = mix(zen, 0x020308, 0.9)
    let poles: [CGFloat] = [0.07, 0.38, 0.69, 1.0]
    for (i, px) in poles.enumerated() {
        let base = CGPoint(x: W * px, y: 0), topY = H * (0.62 - CGFloat(i) * 0.05)
        ctx.setFillColor(rgb(pole)); ctx.fill(CGRect(x: base.x - 6 * S, y: 0, width: 12 * S, height: topY))
        for (k, cy) in [0.0, 0.035, 0.07].enumerated() {   // траверсы
            let y = topY - H * CGFloat(cy), half = (90 - CGFloat(k) * 18) * S
            ctx.fill(CGRect(x: base.x - half, y: y - 4 * S, width: half * 2, height: 7 * S))
        }
        ctx.fill(CGRect(x: base.x - 22 * S, y: topY - H * 0.16, width: 44 * S, height: 50 * S))   // трансформатор
        if i + 1 < poles.count {
            let nx = W * poles[i + 1], ny = H * (0.62 - CGFloat(i + 1) * 0.05)
            for (k, cy) in [0.0, 0.035, 0.07].enumerated() {
                for off in [-1.0, 1.0] as [CGFloat] {
                    let half = (90 - CGFloat(k) * 18) * S * 0.8 * off
                    wire(ctx, CGPoint(x: base.x + half, y: topY - H * CGFloat(cy)), CGPoint(x: nx + half, y: ny - H * CGFloat(cy)),
                         sag: H * 0.035, pole, 0.95, 2.0)
                }
            }
        }
    }
    // пара птиц
    ctx.setStrokeColor(rgb(pole, 0.8)); ctx.setLineWidth(3 * S)
    for (bx, by, s) in [(0.55, 0.72, 1.0), (0.58, 0.75, 0.7)] as [(CGFloat, CGFloat, CGFloat)] {
        let c = CGPoint(x: W * bx, y: H * by), w = 22 * S * s
        ctx.move(to: CGPoint(x: c.x - w, y: c.y + w * 0.4)); ctx.addQuadCurve(to: c, control: CGPoint(x: c.x - w * 0.5, y: c.y + w * 0.5))
        ctx.addQuadCurve(to: CGPoint(x: c.x + w, y: c.y + w * 0.4), control: CGPoint(x: c.x + w * 0.5, y: c.y + w * 0.5)); ctx.strokePath()
    }
    return filmic(bloom(ctx.makeImage()!, near: 8, far: 60, strength: 0.6), grain: 0.035, vignette: 0.35)
}
