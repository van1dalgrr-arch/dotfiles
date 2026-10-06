// Обои «Космеи»: поле розовых космей уходит в густой туман, вдали едва видны деревья.
// Ближние цветы крупные и в расфокусе, дальние — россыпь точек. Утром туман светлый, вечером сиреневый.

func cosmeaKeys(_ hour: CGFloat) -> (fog: Int, ground: Int, light: CGFloat) {
    let keys: [(CGFloat, Int, Int, CGFloat)] = [
        (0, 0x262833, 0x14161a, 0.35), (5, 0x3a3a48, 0x1c1e22, 0.5), (7, 0x8d8a96, 0x34372f, 0.85),
        (12, 0xa7a6ab, 0x3b4034, 1.0), (16, 0x9a96a2, 0x383b31, 0.95), (19, 0x6e6578, 0x2a2a2b, 0.7),
        (21, 0x3c3846, 0x1a1b1f, 0.45), (24, 0x262833, 0x14161a, 0.35)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), lerp(keys[i].3, keys[i + 1].3, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3)
}

let cosmosPinks = [0xd98bc2, 0xe8aad6, 0xc46aa9, 0xf1d3e8, 0xb0569a, 0xe6b9dc]

// цветок космеи: восемь лепестков с зубчиками, тёмно-жёлтая серединка. tilt — наклон к зрителю (сплюснут)
func cosmos(_ ctx: CGContext, _ p: CGPoint, _ r: CGFloat, _ color: Int, tilt: CGFloat, rot: CGFloat, alpha: CGFloat) {
    ctx.saveGState(); ctx.translateBy(x: p.x, y: p.y); ctx.scaleBy(x: 1, y: tilt); ctx.rotate(by: rot)
    for i in 0..<8 {
        ctx.saveGState(); ctx.rotate(by: CGFloat(i) / 8 * 2 * .pi)
        let petal = CGMutablePath()
        petal.move(to: CGPoint(x: 0, y: r * 0.1))
        petal.addCurve(to: CGPoint(x: r, y: r * 0.22), control1: CGPoint(x: r * 0.35, y: r * 0.32), control2: CGPoint(x: r * 0.8, y: r * 0.34))
        petal.addLine(to: CGPoint(x: r * 0.93, y: 0)); petal.addLine(to: CGPoint(x: r, y: -r * 0.22))   // зубчатый край
        petal.addCurve(to: CGPoint(x: 0, y: -r * 0.1), control1: CGPoint(x: r * 0.8, y: -r * 0.34), control2: CGPoint(x: r * 0.35, y: -r * 0.32))
        ctx.addPath(petal); ctx.setFillColor(rgb(mix(color, 0xffffff, CGFloat(i % 3) * 0.06), alpha)); ctx.fillPath()
        ctx.restoreGState()
    }
    ctx.setFillColor(rgb(0x8a6a2a, alpha)); ctx.fillEllipse(in: CGRect(x: -r * 0.2, y: -r * 0.2, width: r * 0.4, height: r * 0.4))
    ctx.setFillColor(rgb(0xd8b448, alpha * 0.8)); ctx.fillEllipse(in: CGRect(x: -r * 0.1, y: -r * 0.1, width: r * 0.2, height: r * 0.2))
    ctx.restoreGState()
}

// ряд поля на глубине d (0 — горизонт, 1 — у ног): стебли, перистая листва, цветы
func fieldRow(_ ctx: CGContext, d: CGFloat, horizon: CGFloat, fog: Int, ground: Int, light: CGFloat, rng: inout Rng) {
    let y0 = horizon * pow(1 - d, 1.25) - 20 * S, scale = lerp(0.12, 3.2, pow(d, 2.2))
    let fogMix = pow(1 - d, 1.4) * 0.85
    let n = Int(lerp(320, 26, pow(d, 0.7)))
    for _ in 0..<n {
        let x = rng.next() * W * 1.1 - W * 0.05, y = y0 + (rng.next() - 0.5) * 60 * S * scale
        let stemH = (90 + rng.next() * 110) * S * scale
        // стебель и листья-ниточки
        ctx.setStrokeColor(rgb(mix(mix(ground, 0x3f5a2c, 0.5), fog, fogMix), 0.9)); ctx.setLineWidth(max(0.6, 1.6 * S * scale))
        let lean = (rng.next() - 0.3) * 0.25
        ctx.move(to: CGPoint(x: x, y: y - stemH)); ctx.addQuadCurve(to: CGPoint(x: x + stemH * lean, y: y), control: CGPoint(x: x, y: y - stemH * 0.4)); ctx.strokePath()
        ctx.setLineWidth(max(0.5, 1.0 * S * scale))
        for _ in 0..<3 {
            let ly = y - stemH * (0.3 + rng.next() * 0.5), dir: CGFloat = rng.next() < 0.5 ? -1 : 1, ll = (14 + rng.next() * 18) * S * scale
            ctx.move(to: CGPoint(x: x + stemH * lean * 0.5, y: ly)); ctx.addLine(to: CGPoint(x: x + dir * ll, y: ly + ll * 0.5)); ctx.strokePath()
        }
        // цветок — не у каждого стебля
        if rng.next() < 0.7 {
            let c = cosmosPinks[Int(rng.next() * CGFloat(cosmosPinks.count)) % cosmosPinks.count]
            let col = mix(mix(c, 0x6a5a6a, (1 - light) * 0.5), fog, fogMix)
            cosmos(ctx, CGPoint(x: x + stemH * lean, y: y), (12 + rng.next() * 7) * S * scale, col,
                   tilt: 0.45 + rng.next() * 0.45, rot: rng.next() * 6.28, alpha: 0.95)
        }
    }
}

runWallpaper { hour in
    let ctx = canvas()
    let (fog, ground, light) = cosmeaKeys(hour)
    let horizon = H * 0.42
    var rng = Rng(seed: 0xC05E)

    // туман-небо: почти ровный, у земли светлее
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(mix(fog, 0xffffff, 0.08)), rgb(mix(fog, 0x000000, 0.12))] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: horizon), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])
    // деревья в тумане справа — силуэты, почти растворились
    for (tx, th, tw) in [(0.73, 0.2, 0.06), (0.8, 0.16, 0.05), (0.92, 0.22, 0.07), (0.3, 0.1, 0.05)] as [(CGFloat, CGFloat, CGFloat)] {
        ctx.setFillColor(rgb(mix(fog, 0x2a2c2a, 0.16)))
        for _ in 0..<40 {
            let r = W * tw * (0.25 + rng.next() * 0.35)
            ctx.fillEllipse(in: CGRect(x: W * tx + (rng.next() - 0.5) * W * tw - r, y: horizon + H * th * (0.3 + rng.next() * 0.7) - r, width: r * 2, height: r * 2))
        }
        ctx.fill(CGRect(x: W * tx - 4 * S, y: horizon - 10 * S, width: 8 * S, height: H * th * 0.5))
    }
    soften(ctx, 14)
    // земля под полем
    ctx.setFillColor(rgb(mix(ground, fog, 0.5))); ctx.fill(CGRect(x: 0, y: 0, width: W, height: horizon))
    let field = CGGradient(colorsSpace: cs, colors: [rgb(ground), rgb(mix(ground, fog, 0.7)), rgb(mix(fog, 0xffffff, 0.06))] as CFArray, locations: [0, 0.75, 1])!
    ctx.drawLinearGradient(field, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: horizon), options: [])

    // поле от горизонта к зрителю; дальнее размываем вместе с туманом
    var d: CGFloat = 0
    while d < 0.55 { fieldRow(ctx, d: d, horizon: horizon, fog: fog, ground: ground, light: light, rng: &rng); d += 0.05 }
    haze(ctx, fog, bottom: 0.0, top: 0.7, from: horizon * 0.4, to: horizon * 1.05)
    soften(ctx, 2)
    while d < 0.9 { fieldRow(ctx, d: d, horizon: horizon, fog: fog, ground: ground, light: light, rng: &rng); d += 0.06 }
    soften(ctx, 1.2)                                   // мягкость объектива: без неё цветы как вырезанные
    // самые ближние цветы — крупно и в расфокусе, как у объектива
    ctx.draw(blurLayer(7) { l in
        var r2 = Rng(seed: 0xF10)
        fieldRow(l, d: 1.0, horizon: horizon, fog: fog, ground: ground, light: light, rng: &r2)
    }, in: extent)
    // несколько высоких резких космей слева — главный акцент кадра, как в кадре с фото
    let stem = mix(ground, 0x3f5a2c, 0.35)
    for (sx, top, r, c, bud) in [(0.085, 0.47, 30.0, 0xd98bc2, false), (0.115, 0.43, 8.0, 0x8a5070, true), (0.135, 0.5, 9.0, 0x8a5070, true),
                                  (0.06, 0.36, 24.0, 0xe8aad6, false), (0.155, 0.4, 10.0, 0x6a4a50, true)] as [(CGFloat, CGFloat, CGFloat, Int, Bool)] {
        let tip = CGPoint(x: W * sx, y: H * top)
        ctx.setStrokeColor(rgb(stem)); ctx.setLineWidth(2.6 * S)
        ctx.move(to: CGPoint(x: W * (sx - 0.02), y: 0)); ctx.addQuadCurve(to: tip, control: CGPoint(x: W * (sx - 0.025), y: H * top * 0.5)); ctx.strokePath()
        if bud { ctx.setFillColor(rgb(mix(c, 0x000000, (1 - light) * 0.4))); ctx.fillEllipse(in: CGRect(x: tip.x - r * S * 0.6, y: tip.y - r * S * 0.4, width: r * S * 1.2, height: r * S * 1.5)) }
        else { cosmos(ctx, tip, CGFloat(r) * S, mix(c, 0x6a5a6a, (1 - light) * 0.4), tilt: 0.75, rot: sx * 9, alpha: 1) }
    }
    return filmic(ctx.makeImage()!, grain: 0.06, vignette: 0.45)
}
