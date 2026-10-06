// Обои «Луг в дымке»: высокая трава гнётся под ветром, за ней — пологий холм, тонущий в тумане.
// Тысячи травинок в несколько планов; дальние в дымке, ближние крупные и в расфокусе. Утром светлее, ночью почти чёрно-зелёное.

func steppeKeys(_ hour: CGFloat) -> (fog: Int, grass: Int, tip: Int) {
    let keys: [(CGFloat, Int, Int, Int)] = [
        (0, 0x1d2124, 0x0c110d, 0x2a3328), (5, 0x2c3134, 0x111812, 0x3a4636), (8, 0x8a8f90, 0x223122, 0x6f7f5e),
        (13, 0x9fa3a3, 0x2a3a28, 0x84956c), (17, 0x8b8c88, 0x283423, 0x7a865f), (20, 0x4a4d50, 0x162017, 0x46523e),
        (24, 0x1d2124, 0x0c110d, 0x2a3328)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), mix(keys[i].3, keys[i + 1].3, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3)
}

// полоса травы: основание на кривой холма base(x), высота h, наклон ветра wind
func grassBand(_ ctx: CGContext, count: Int, base: (CGFloat) -> CGFloat, height: ClosedRange<CGFloat>, width: CGFloat,
               color: Int, tip: Int, fogMix: CGFloat, fog: Int, wind: CGFloat, rng: inout Rng) {
    ctx.setLineCap(.round)
    for _ in 0..<count {
        let x = rng.next() * W * 1.1 - W * 0.05, y = base(x) - rng.next() * 30 * S
        let h = lerp(height.lowerBound, height.upperBound, rng.next()) * S
        let bend = (wind + (rng.next() - 0.5) * 0.35) * h
        let end = CGPoint(x: x + bend, y: y + h * (1 - abs(wind) * 0.25))
        let c = mix(mix(color, tip, rng.next() * 0.6), fog, fogMix)
        // травинка — сужающаяся кривая: две линии разной толщины
        let path = CGMutablePath(); path.move(to: CGPoint(x: x, y: y))
        path.addQuadCurve(to: end, control: CGPoint(x: x + bend * 0.15, y: y + h * 0.6))
        ctx.addPath(path); ctx.setStrokeColor(rgb(c, 0.85)); ctx.setLineWidth(width * S * (0.6 + rng.next() * 0.8)); ctx.strokePath()
        // метёлка у некоторых
        if rng.next() < 0.015 {
            ctx.setFillColor(rgb(mix(mix(tip, 0xb8b496, 0.25), fog, fogMix), 0.6))
            for k in 0..<6 {
                let t = CGFloat(k) / 6
                ctx.fillEllipse(in: CGRect(x: end.x - bend * 0.08 * t + (rng.next() - 0.5) * 4 * S, y: end.y - h * 0.12 * t, width: 3 * S * width, height: 5 * S * width))
            }
        }
    }
}

runWallpaper { hour in
    let ctx = canvas()
    let (fog, grass, tip) = steppeKeys(hour)
    var rng = Rng(seed: 0x57E9)
    let wind: CGFloat = 0.32

    // небо-туман
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(mix(fog, 0xffffff, 0.05)), rgb(mix(fog, 0x000000, 0.1))] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H * 0.5), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])

    // дальний холм: пологая линия слева направо, почти растворена
    let hill: (CGFloat) -> CGFloat = { x in H * (0.6 + 0.08 * (x / W) + 0.015 * sin(x / W * 7)) }
    let far = CGMutablePath(); far.move(to: CGPoint(x: 0, y: 0))
    for k in 0...80 { let x = CGFloat(k) / 80 * W; far.addLine(to: CGPoint(x: x, y: hill(x) - H * 0.07 - (x < W * 0.4 ? H * 0.04 * (1 - x / (W * 0.4)) : 0))) }
    far.addLine(to: CGPoint(x: W, y: 0)); far.closeSubpath()
    ctx.addPath(far); ctx.setFillColor(rgb(mix(grass, fog, 0.72))); ctx.fillPath()
    soften(ctx, 10)

    // планы травы от дальнего к ближнему
    let bands: [(CGFloat, Int, ClosedRange<CGFloat>, CGFloat, CGFloat)] = [
        (0.0, 6000, 30...70, 1.2, 0.6), (0.08, 5000, 60...130, 1.6, 0.45), (0.18, 4200, 110...220, 2.2, 0.3),
        (0.3, 3200, 180...340, 2.8, 0.16), (0.44, 2400, 260...460, 3.4, 0.05)]
    for (i, (drop, n, h, w, fm)) in bands.enumerated() {
        let shift = H * drop
        // земля только под дальним планом; дальше травы перекрывают друг друга без швов
        ctx.setFillColor(rgb(mix(grass, fog, fm)))
        let ground = CGMutablePath(); ground.move(to: CGPoint(x: 0, y: 0))
        for k in 0...80 { let x = CGFloat(k) / 80 * W; ground.addLine(to: CGPoint(x: x, y: hill(x) - shift - H * 0.08)) }
        ground.addLine(to: CGPoint(x: W, y: 0)); ground.closeSubpath()
        if i == 0 {   // земля: у горизонта в дымке, у ног — тёмная трава
            ctx.saveGState(); ctx.addPath(ground); ctx.clip()
            let g = CGGradient(colorsSpace: cs, colors: [rgb(mix(grass, 0x000000, 0.2)), rgb(mix(grass, fog, fm))] as CFArray, locations: [0, 1])!
            ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: H * 0.6), options: [])
            ctx.restoreGState()
        }
        grassBand(ctx, count: n, base: { x in hill(x) - shift - H * 0.08 }, height: h, width: w, color: grass, tip: tip,
                  fogMix: fm, fog: fog, wind: wind, rng: &rng)
        haze(ctx, fog, bottom: 0.0, top: 0.3 - CGFloat(i) * 0.05, from: H * 0.1, to: H * 0.75)
        soften(ctx, i == 0 ? 3 : 1)
    }
    // ближайшая трава — крупная и размытая, по нижнему краю кадра
    ctx.draw(blurLayer(6) { l in
        var r2 = Rng(seed: 0x6A55)
        grassBand(l, count: 700, base: { _ in -40 * S }, height: 300...560, width: 6, color: grass, tip: tip, fogMix: 0.0, fog: fog, wind: wind, rng: &r2)
    }, in: extent)
    // дымка поверх всего — трава у горизонта тонет в тумане
    haze(ctx, fog, bottom: 0.06, top: 0.3, from: 0, to: H * 0.7)
    return filmic(ctx.makeImage()!, grain: 0.06, vignette: 0.55)
}
