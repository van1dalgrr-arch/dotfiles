// Обои «Тории»: каменная лестница уходит вверх в туман, на ней — красные ворота тории, по бокам каменные
// фонари и тёмные кедры. Чем дальше, тем гуще туман. Вечером и ночью фонари загораются. Собирается через wall.

func toriiKeys(_ hour: CGFloat) -> (fog: Int, deep: Int, lamp: CGFloat) {
    let keys: [(CGFloat, Int, Int, CGFloat)] = [
        (0, 0x1a1d24, 0x08090c, 1.0), (5, 0x252a33, 0x0d0f13, 0.8), (8, 0x8d9296, 0x3a3f42, 0.0),
        (13, 0xa3a7aa, 0x474c4f, 0.0), (17, 0x8a8584, 0x3a3533, 0.2), (19, 0x4d4a55, 0x1c1a20, 0.8),
        (21, 0x262832, 0x0c0d11, 1.0), (24, 0x1a1d24, 0x08090c, 1.0)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), lerp(keys[i].3, keys[i + 1].3, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3)
}

// ворота тории: два столба, нижняя перекладина нуки, верхняя касаги с изогнутыми концами
func torii(_ ctx: CGContext, cx: CGFloat, base: CGFloat, h: CGFloat, color: Int, dark: Int) {
    let w = h * 1.05, post = h * 0.075
    ctx.setFillColor(rgb(color))
    for side in [-1.0, 1.0] as [CGFloat] {   // столбы, чуть сходятся кверху
        let p = CGMutablePath()
        p.move(to: CGPoint(x: cx + side * w * 0.36 - post * 0.6, y: base)); p.addLine(to: CGPoint(x: cx + side * w * 0.36 + post * 0.6, y: base))
        p.addLine(to: CGPoint(x: cx + side * w * 0.33 + post * 0.45, y: base + h * 0.86)); p.addLine(to: CGPoint(x: cx + side * w * 0.33 - post * 0.45, y: base + h * 0.86))
        p.closeSubpath(); ctx.addPath(p); ctx.fillPath()
        ctx.setFillColor(rgb(dark)); ctx.fill(CGRect(x: cx + side * w * 0.36 - post * 0.75, y: base, width: post * 1.5, height: h * 0.06)); ctx.setFillColor(rgb(color))   // чёрные основания
    }
    ctx.fill(CGRect(x: cx - w * 0.46, y: base + h * 0.68, width: w * 0.92, height: h * 0.06))                      // нуки
    ctx.fill(CGRect(x: cx - post * 0.4, y: base + h * 0.74, width: post * 0.8, height: h * 0.12))                  // табличка-стойка
    let kasagi = CGMutablePath()                                                                                   // касаги
    kasagi.move(to: CGPoint(x: cx - w * 0.6, y: base + h * 0.98))
    kasagi.addQuadCurve(to: CGPoint(x: cx, y: base + h * 0.9), control: CGPoint(x: cx - w * 0.3, y: base + h * 0.9))
    kasagi.addQuadCurve(to: CGPoint(x: cx + w * 0.6, y: base + h * 0.98), control: CGPoint(x: cx + w * 0.3, y: base + h * 0.9))
    kasagi.addLine(to: CGPoint(x: cx + w * 0.58, y: base + h * 1.04))
    kasagi.addQuadCurve(to: CGPoint(x: cx, y: base + h * 0.97), control: CGPoint(x: cx + w * 0.3, y: base + h * 0.97))
    kasagi.addQuadCurve(to: CGPoint(x: cx - w * 0.58, y: base + h * 1.04), control: CGPoint(x: cx - w * 0.3, y: base + h * 0.97))
    kasagi.closeSubpath()
    ctx.addPath(kasagi); ctx.fillPath()
    ctx.setFillColor(rgb(dark)); ctx.addPath(kasagi); ctx.clip()                                                   // чёрный верх касаги
    ctx.fill(CGRect(x: cx - w, y: base + h * 1.0, width: w * 2, height: h * 0.1)); ctx.resetClip()
    ctx.setFillColor(rgb(color)); ctx.fill(CGRect(x: cx - w * 0.5, y: base + h * 0.86, width: w, height: h * 0.05))   // симаги
}

// каменный фонарь торо: основание, стойка, домик с огнём, крыша
func toro(_ ctx: CGContext, cx: CGFloat, base: CGFloat, h: CGFloat, stone: Int, fire: CGFloat) {
    let u = h / 10
    ctx.setFillColor(rgb(stone))
    ctx.fill(CGRect(x: cx - u * 1.8, y: base, width: u * 3.6, height: u))
    ctx.fill(CGRect(x: cx - u * 0.7, y: base + u, width: u * 1.4, height: u * 4))
    ctx.fill(CGRect(x: cx - u * 1.6, y: base + u * 5, width: u * 3.2, height: u * 0.6))
    ctx.fill(CGRect(x: cx - u * 1.2, y: base + u * 5.6, width: u * 2.4, height: u * 2))
    let roof = CGMutablePath()
    roof.move(to: CGPoint(x: cx - u * 2.4, y: base + u * 7.6)); roof.addLine(to: CGPoint(x: cx + u * 2.4, y: base + u * 7.6))
    roof.addLine(to: CGPoint(x: cx, y: base + u * 9.4)); roof.closeSubpath(); ctx.addPath(roof); ctx.fillPath()
    ctx.fillEllipse(in: CGRect(x: cx - u * 0.4, y: base + u * 9.2, width: u * 0.8, height: u * 0.8))
    if fire > 0.01 {
        ctx.setFillColor(rgb(0xffb45c, fire)); ctx.fill(CGRect(x: cx - u * 0.6, y: base + u * 6, width: u * 1.2, height: u * 1.2))
        radialGlow(ctx, CGPoint(x: cx, y: base + u * 6.6), u * 8, 0xff9a3c, 0.35 * fire)
    }
}

// кедр: тёмный узкий конус из ярусов
func cedar(_ ctx: CGContext, cx: CGFloat, base: CGFloat, h: CGFloat, color: Int, rng: inout Rng) {
    ctx.setFillColor(rgb(color))
    ctx.fill(CGRect(x: cx - h * 0.012, y: base, width: h * 0.024, height: h * 0.3))
    for i in 0..<9 {
        let t = CGFloat(i) / 9, y = base + h * (0.15 + t * 0.8), w = h * 0.17 * (1 - t * 0.85) * (0.85 + rng.next() * 0.3)
        let tier = CGMutablePath()
        tier.move(to: CGPoint(x: cx - w, y: y)); tier.addLine(to: CGPoint(x: cx + w, y: y)); tier.addLine(to: CGPoint(x: cx, y: y + h * 0.16)); tier.closeSubpath()
        ctx.addPath(tier); ctx.fillPath()
    }
}

runWallpaper { hour in
    let ctx = canvas()
    let (fog, deep, fire) = toriiKeys(hour)
    var rng = Rng(seed: 0x7041)
    let red = 0xc4352a

    let sky = CGGradient(colorsSpace: cs, colors: [rgb(mix(fog, 0xffffff, 0.06)), rgb(mix(fog, deep, 0.35))] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H * 0.3), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])

    // кедры: три плана, дальние почти растворились
    for (layer, (n, hRange, mixF)) in [(26, (0.5, 0.75), 0.82), (18, (0.65, 0.95), 0.6), (10, (0.9, 1.3), 0.3)].enumerated() {
        for _ in 0..<n {
            var x = rng.next() * W
            if abs(x - W * 0.5) < W * (0.12 + CGFloat(layer) * 0.06) { x += (x < W * 0.5 ? -1 : 1) * W * 0.18 }   // лестницу не закрывать
            cedar(ctx, cx: x, base: H * (0.28 - CGFloat(layer) * 0.08), h: H * lerp(CGFloat(hRange.0), CGFloat(hRange.1), rng.next()),
                  color: mix(deep, fog, CGFloat(mixF)), rng: &rng)
        }
        haze(ctx, fog, bottom: 0.4, top: 0.15, from: 0, to: H)
        soften(ctx, CGFloat(6 - layer * 2))
    }

    // лестница в перспективе: ступени от зрителя вверх к воротам
    let topY = H * 0.42, botY: CGFloat = 0
    for i in 0..<34 {
        let t0 = CGFloat(i) / 34, t1 = CGFloat(i + 1) / 34
        let y0 = lerp(botY, topY, pow(t0, 0.75)), y1 = lerp(botY, topY, pow(t1, 0.75))
        let w0 = lerp(W * 0.42, W * 0.06, t0), w1 = lerp(W * 0.42, W * 0.06, t1)
        let stone = mix(mix(0x3c3f42, deep, 0.3), fog, pow(t0, 0.7) * 0.85)
        let step = CGMutablePath()
        step.move(to: CGPoint(x: W * 0.5 - w0, y: y0)); step.addLine(to: CGPoint(x: W * 0.5 + w0, y: y0))
        step.addLine(to: CGPoint(x: W * 0.5 + w1, y: y1)); step.addLine(to: CGPoint(x: W * 0.5 - w1, y: y1)); step.closeSubpath()
        ctx.addPath(step); ctx.setFillColor(rgb(stone)); ctx.fillPath()
        ctx.setFillColor(rgb(mix(stone, 0xffffff, 0.12))); ctx.fill(CGRect(x: W * 0.5 - w0, y: y0 + (y1 - y0) * 0.7, width: w0 * 2, height: max(1, (y1 - y0) * 0.3)))   // край ступени
    }

    // ворота: дальние в тумане, ближние ярче
    torii(ctx, cx: W * 0.5, base: H * 0.4, h: H * 0.22, color: mix(red, fog, 0.65), dark: mix(0x1a1a1a, fog, 0.65))
    haze(ctx, fog, bottom: 0.3, top: 0.0, from: H * 0.3, to: H * 0.7)
    torii(ctx, cx: W * 0.5, base: H * 0.27, h: H * 0.42, color: mix(red, fog, 0.18), dark: mix(0x141414, fog, 0.2))

    // фонари вдоль лестницы
    for (t, s) in [(0.15, 1.0), (0.4, 0.65), (0.62, 0.45)] as [(CGFloat, CGFloat)] {
        let y = lerp(botY, topY, pow(t, 0.75)), w = lerp(W * 0.42, W * 0.06, t)
        for side in [-1.0, 1.0] as [CGFloat] {
            toro(ctx, cx: W * 0.5 + side * (w + 70 * S * s), base: y, h: H * 0.2 * s, stone: mix(0x2e3033, fog, (1 - s) * 0.7), fire: fire)
        }
    }
    // туман стелется по ступеням и сверху
    haze(ctx, fog, bottom: 0.25, top: 0.0, from: 0, to: H * 0.3)
    haze(ctx, fog, bottom: 0.0, top: 0.35, from: H * 0.6, to: H)
    return filmic(bloom(ctx.makeImage()!, near: 6, far: 40, strength: 0.6), grain: 0.05, vignette: 0.5)
}
