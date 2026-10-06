// Обои «Переезд»: железнодорожный переезд в сумерках — рельсы уходят к горизонту, светофор с двумя
// красными фонарями (один горит), знак-крест, столбы с проводами. Ночью фонарь ярче, небо в звёздах. Собирается через wall.

func crossingKeys(_ hour: CGFloat) -> (zenith: Int, horizon: Int, light: CGFloat) {
    let keys: [(CGFloat, Int, Int, CGFloat)] = [
        (0, 0x060918, 0x1c2140, 1.0), (5, 0x10163a, 0x5a4a78, 0.8), (7, 0x3a5aa0, 0xf0b090, 0.3),
        (12, 0x4a7ac0, 0xbcd4ec, 0.1), (17, 0x3a4c90, 0xf4a070, 0.4), (19, 0x1c1f58, 0xe8704e, 0.8),
        (21, 0x0b0e2a, 0x3c2850, 1.0), (24, 0x060918, 0x1c2140, 1.0)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), lerp(keys[i].3, keys[i + 1].3, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3)
}

runWallpaper { hour in
    let ctx = canvas()
    let (zen, hor, light) = crossingKeys(hour)
    var rng = Rng(seed: 0xC705)
    let horizon = H * 0.34, vp = CGPoint(x: W * 0.42, y: horizon)
    let ink = mix(zen, 0x020308, 0.88)

    let sky = CGGradient(colorsSpace: cs, colors: [rgb(hor), rgb(mix(hor, zen, 0.55)), rgb(zen)] as CFArray, locations: [0, 0.3, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: horizon), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])
    stars(ctx, count: 500, alpha: light * 0.8, seed: 0xC7)
    radialGlow(ctx, CGPoint(x: vp.x, y: horizon), W * 0.5, mix(hor, 0xffffff, 0.2), 0.35)
    // тонкие облака-полосы, подсвеченные снизу
    ctx.draw(blurLayer(5) { l in
        var r2 = Rng(seed: 0xC1)
        for _ in 0..<12 {
            let y = H * (0.5 + r2.next() * 0.4), x = r2.next() * W, w = (400 + r2.next() * 700) * S
            l.setFillColor(rgb(mix(zen, hor, 0.6), 0.5)); l.fillEllipse(in: CGRect(x: x - w / 2, y: y, width: w, height: (10 + r2.next() * 18) * S))
        }
    }, in: extent)

    // дальний лес и холмы у горизонта
    ctx.setFillColor(rgb(mix(ink, hor, 0.25)))
    for i in 0..<120 { let x = CGFloat(i) / 120 * W * 1.05, r = (14 + rng.next() * 30) * S; ctx.fillEllipse(in: CGRect(x: x - r, y: horizon + rng.next() * 16 * S - r, width: r * 2, height: r * 2)) }
    // земля
    ctx.setFillColor(rgb(ink)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: horizon))
    // насыпь и рельсы в перспективе к точке схода
    let bed = CGMutablePath()
    bed.move(to: CGPoint(x: W * 0.05, y: 0)); bed.addLine(to: CGPoint(x: W * 0.8, y: 0)); bed.addLine(to: CGPoint(x: vp.x + 12 * S, y: horizon)); bed.addLine(to: CGPoint(x: vp.x - 12 * S, y: horizon)); bed.closeSubpath()
    ctx.addPath(bed); ctx.setFillColor(rgb(mix(ink, hor, 0.12))); ctx.fillPath()
    for (i, t) in stride(from: 0.0, to: 1.0, by: 0.03).enumerated() {   // шпалы
        let y = horizon * (1 - pow(1 - CGFloat(t), 1.0)), k = 1 - CGFloat(t)
        let half = lerp(W * 0.3, 8 * S, CGFloat(t)), cx = lerp(W * 0.425, vp.x, CGFloat(t))
        ctx.setFillColor(rgb(mix(ink, hor, 0.05))); ctx.fill(CGRect(x: cx - half, y: y, width: half * 2, height: max(1, 10 * S * k)))
        _ = i
    }
    ctx.setStrokeColor(rgb(mix(hor, 0xffffff, 0.3), 0.85)); ctx.setLineWidth(5 * S)   // рельсы ловят свет неба
    for x0 in [W * 0.24, W * 0.61] {
        ctx.move(to: CGPoint(x: x0, y: 0)); ctx.addLine(to: CGPoint(x: vp.x + (x0 - W * 0.425) * 0.02, y: horizon)); ctx.strokePath()
    }
    // дорога поперёк путей
    let road = CGMutablePath()
    road.move(to: CGPoint(x: 0, y: horizon * 0.42)); road.addLine(to: CGPoint(x: W, y: horizon * 0.5)); road.addLine(to: CGPoint(x: W, y: horizon * 0.62)); road.addLine(to: CGPoint(x: 0, y: horizon * 0.56)); road.closeSubpath()
    ctx.addPath(road); ctx.setFillColor(rgb(mix(ink, hor, 0.18))); ctx.fillPath()

    // столбы с проводами вдоль путей
    for (i, t) in ([0.0, 0.35, 0.6, 0.78, 0.9] as [CGFloat]).enumerated() {
        let x = lerp(W * 0.86, vp.x + 60 * S, t), base = horizon * t * 0.98, h = lerp(H * 0.9, H * 0.08, t)
        ctx.setFillColor(rgb(ink)); ctx.fill(CGRect(x: x - 7 * S * (1 - t), y: base, width: max(2, 14 * S * (1 - t)), height: h))
        ctx.fill(CGRect(x: x - 70 * S * (1 - t * 0.9), y: base + h * 0.95, width: 140 * S * (1 - t * 0.9), height: max(2, 8 * S * (1 - t))))
        if i < 4 {
            let t2: CGFloat = [0.35, 0.6, 0.78, 0.9][i]
            let x2 = lerp(W * 0.86, vp.x + 60 * S, t2), h2 = lerp(H * 0.9, H * 0.08, t2), b2 = horizon * t2 * 0.98
            for off in [-0.8, -0.3, 0.3, 0.8] as [CGFloat] {
                wire(ctx, CGPoint(x: x + off * 70 * S * (1 - t * 0.9), y: base + h * 0.95), CGPoint(x: x2 + off * 70 * S * (1 - t2 * 0.9), y: b2 + h2 * 0.95),
                     sag: H * 0.03 * (1 - t), ink, 0.9, max(0.8, 2.2 * (1 - t)))
            }
        }
    }

    // светофор переезда слева: столб, знак-крест, два фонаря, мигает левый
    let px = W * 0.16, py = horizon * 0.5
    ctx.setFillColor(rgb(ink)); ctx.fill(CGRect(x: px - 9 * S, y: 0, width: 18 * S, height: py + H * 0.46))
    let cross = CGPoint(x: px, y: py + H * 0.43)
    for a in [0.55, -0.55] as [CGFloat] {
        ctx.saveGState(); ctx.translateBy(x: cross.x, y: cross.y); ctx.rotate(by: a)
        ctx.setFillColor(rgb(0xe8e0d0, 0.85)); ctx.fill(CGRect(x: -150 * S, y: -16 * S, width: 300 * S, height: 32 * S))
        ctx.setFillColor(rgb(0x1a1a1a, 0.9))
        var sx: CGFloat = -150 * S
        while sx < 150 * S { ctx.fill(CGRect(x: sx, y: -16 * S, width: 34 * S, height: 32 * S)); sx += 68 * S }
        ctx.restoreGState()
    }
    let lampsY = py + H * 0.3
    ctx.setFillColor(rgb(ink)); ctx.fill(CGRect(x: px - 120 * S, y: lampsY - 6 * S, width: 240 * S, height: 12 * S))
    for (dx, on) in [(-80.0, 1.0), (80.0, 0.15)] as [(CGFloat, CGFloat)] {
        let c = CGPoint(x: px + dx * S, y: lampsY)
        ctx.setFillColor(rgb(0x050505)); ctx.fillEllipse(in: CGRect(x: c.x - 46 * S, y: c.y - 46 * S, width: 92 * S, height: 92 * S))
        if on > 0.5 { radialGlow(ctx, c, 420 * S, 0xff2a1a, 0.45 * (0.5 + light * 0.5)) }
        ctx.setFillColor(rgb(mix(0x3a0806, 0xff3a26, on))); ctx.fillEllipse(in: CGRect(x: c.x - 34 * S, y: c.y - 34 * S, width: 68 * S, height: 68 * S))
        // козырёк над фонарём
        ctx.setFillColor(rgb(ink)); ctx.fillEllipse(in: CGRect(x: c.x - 48 * S, y: c.y + 20 * S, width: 96 * S, height: 40 * S))
    }
    // красный отсвет на рельсах и дороге
    ctx.draw(blurLayer(30) { l in
        l.setFillColor(rgb(0xff3020, 0.25 * (0.4 + light * 0.6))); l.fillEllipse(in: CGRect(x: px - 300 * S, y: horizon * 0.3, width: 900 * S, height: horizon * 0.45))
    }, in: extent)
    // трава на переднем плане
    ctx.setStrokeColor(rgb(ink)); ctx.setLineCap(.round)
    for _ in 0..<500 {
        let x = rng.next() * W, h = (30 + rng.next() * 90) * S, lean = (rng.next() - 0.5) * 30 * S
        if x > W * 0.05 && x < W * 0.8 && rng.next() < 0.7 { continue }      // на насыпи травы меньше
        ctx.setLineWidth((1.5 + rng.next() * 2) * S); ctx.move(to: CGPoint(x: x, y: 0)); ctx.addQuadCurve(to: CGPoint(x: x + lean, y: h), control: CGPoint(x: x, y: h * 0.6)); ctx.strokePath()
    }
    return filmic(bloom(ctx.makeImage()!, near: 8, far: 60, strength: 0.7), grain: 0.04, vignette: 0.45)
}
