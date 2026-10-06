// Обои «Ночь гуля» (dark anime): ночной город под дождём, огромная красная луна, на краю крыши — силуэт
// с горящим красным глазом и четырьмя щупальцами за спиной. Свой персонаж, без копирования.
// За сутки луна поднимается и бледнеет днём, ночью краснее и ярче. Собирается через wall (с wallpaper-kit.swift).

func ghoulKeys(_ hour: CGFloat) -> (top: Int, low: Int, moon: Int, glow: CGFloat) {
    let keys: [(CGFloat, Int, Int, Int, CGFloat)] = [
        (0, 0x030204, 0x2a070d, 0xd8202e, 1.0), (5, 0x07070c, 0x2c0c14, 0xd02a34, 0.9), (8, 0x16161c, 0x3a2228, 0xb84a50, 0.55),
        (13, 0x1c1c22, 0x41303a, 0xa9666a, 0.45), (17, 0x120d12, 0x3c1418, 0xc43038, 0.7), (20, 0x07060a, 0x30080f, 0xd8202e, 0.95),
        (24, 0x030204, 0x2a070d, 0xd8202e, 1.0)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), mix(keys[i].3, keys[i + 1].3, t), lerp(keys[i].4, keys[i + 1].4, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3, keys[0].4)
}

// точка кубической кривой
func bez(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint, _ t: CGFloat) -> CGPoint {
    let u = 1 - t
    return CGPoint(x: u * u * u * a.x + 3 * u * u * t * b.x + 3 * u * t * t * c.x + t * t * t * d.x,
                   y: u * u * u * a.y + 3 * u * u * t * b.y + 3 * u * t * t * c.y + t * t * t * d.y)
}

// щупальце: сужающаяся кривая из сегментов — тёмная сердцевина, красные прожилки, шипы по краю
func tendril(_ ctx: CGContext, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint, width: CGFloat, red: Int, rng: inout Rng) {
    let n = 60
    ctx.setLineCap(.round)
    for pass in 0..<3 {
        for i in 0..<n {
            let t0 = CGFloat(i) / CGFloat(n), t1 = CGFloat(i + 1) / CGFloat(n)
            let p0 = bez(a, b, c, d, t0), p1 = bez(a, b, c, d, t1)
            let w = width * pow(1 - t0, 0.65) + 1.5 * S
            switch pass {
            case 0: ctx.setStrokeColor(rgb(red, 0.35)); ctx.setLineWidth(w * 1.6)                       // свечение вокруг
            case 1: ctx.setStrokeColor(rgb(mix(0x16040a, red, 0.25))); ctx.setLineWidth(w)               // тело
            default: ctx.setStrokeColor(rgb(mix(red, 0xff6a6a, 0.3), 0.85)); ctx.setLineWidth(max(1, w * 0.18))   // прожилка
            }
            ctx.move(to: p0); ctx.addLine(to: p1); ctx.strokePath()
        }
    }
    // шипы-чешуйки вдоль щупальца
    ctx.setFillColor(rgb(mix(0x16040a, red, 0.35)))
    for i in stride(from: 6, to: n - 4, by: 4) {
        let t = CGFloat(i) / CGFloat(n), p = bez(a, b, c, d, t), q = bez(a, b, c, d, t + 0.02)
        let ang = atan2(q.y - p.y, q.x - p.x) + (rng.next() < 0.5 ? 1 : -1) * (.pi / 2.4)
        let w = width * pow(1 - t, 0.8) * 0.5, l = w * (1.4 + rng.next())
        let tri = CGMutablePath()
        tri.move(to: CGPoint(x: p.x + cos(ang + 1.4) * w * 0.5, y: p.y + sin(ang + 1.4) * w * 0.5))
        tri.addLine(to: CGPoint(x: p.x + cos(ang) * (w + l), y: p.y + sin(ang) * (w + l)))
        tri.addLine(to: CGPoint(x: p.x + cos(ang - 1.4) * w * 0.5, y: p.y + sin(ang - 1.4) * w * 0.5))
        ctx.addPath(tri); ctx.fillPath()
    }
}

runWallpaper { hour in
    let ctx = canvas()
    let (top, low, moonC, glow) = ghoulKeys(hour)
    var rng = Rng(seed: 0x6A0E1)

    // небо
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(low), rgb(top)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H * 0.25), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])

    // луна: огромная, за силуэтом; за сутки чуть поднимается
    let mc = CGPoint(x: W * 0.68, y: H * (0.6 + 0.04 * sin((hour - 6) / 24 * 2 * .pi)))
    let mr = H * 0.2
    radialGlow(ctx, mc, mr * 3.2, moonC, 0.35 * glow)
    let disc = CGGradient(colorsSpace: cs, colors: [rgb(mix(moonC, 0xffb0a0, 0.35)), rgb(moonC), rgb(mix(moonC, 0x000000, 0.35))] as CFArray, locations: [0, 0.6, 1])!
    ctx.saveGState(); ctx.addEllipse(in: CGRect(x: mc.x - mr, y: mc.y - mr, width: mr * 2, height: mr * 2)); ctx.clip()
    ctx.drawRadialGradient(disc, startCenter: CGPoint(x: mc.x - mr * 0.3, y: mc.y + mr * 0.3), startRadius: 0, endCenter: mc, endRadius: mr, options: [])
    for _ in 0..<26 {   // «моря» на луне
        let p = CGPoint(x: mc.x + (rng.next() - 0.5) * mr * 1.8, y: mc.y + (rng.next() - 0.5) * mr * 1.8), r = mr * (0.05 + rng.next() * 0.2)
        ctx.setFillColor(rgb(mix(moonC, 0x000000, 0.45), 0.25)); ctx.fillEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
    }
    ctx.restoreGState()
    // облака-полосы поперёк луны
    ctx.draw(blurLayer(14) { l in
        for (y, a) in [(0.66, 0.5), (0.55, 0.35), (0.78, 0.3)] as [(CGFloat, CGFloat)] {
            l.setFillColor(rgb(mix(top, low, 0.4), a)); l.fill(CGRect(x: W * 0.3, y: H * y, width: W * 0.75, height: 26 * S))
        }
    }, in: extent)

    // город: три плана силуэтов, редкие окна — тусклые и красноватые
    for (layer, (base, hmax, shade, lit)) in [(0.3, 0.42, 0.55, 0.05), (0.22, 0.34, 0.35, 0.08), (0.12, 0.3, 0.12, 0.1)].enumerated() {
        var x: CGFloat = -20 * S
        let col = mix(top, low, CGFloat(shade))
        while x < W {
            let w = (60 + rng.next() * 140) * S, h = H * (CGFloat(base) + rng.next() * CGFloat(hmax - base))
            ctx.setFillColor(rgb(mix(col, 0x000000, 0.3))); ctx.fill(CGRect(x: x, y: 0, width: w, height: h))
            if rng.next() < 0.3 { ctx.fill(CGRect(x: x + w * 0.5, y: h, width: 2 * S, height: (30 + rng.next() * 60) * S)) }   // антенна
            var wy = h - 20 * S
            while wy > 10 * S {
                var wx = x + 8 * S
                while wx < x + w - 10 * S {
                    if rng.next() < CGFloat(lit) {
                        ctx.setFillColor(rgb(rng.next() < 0.6 ? 0xffb37a : 0xff4a4a, 0.25 + CGFloat(layer) * 0.15))
                        ctx.fill(CGRect(x: wx, y: wy, width: 6 * S, height: 8 * S))
                    }
                    wx += 14 * S
                }
                wy -= 18 * S
            }
            x += w + rng.next() * 12 * S
        }
        if layer == 0 { soften(ctx, 3) }
        haze(ctx, low, bottom: 0.25 - CGFloat(layer) * 0.07, top: 0, from: 0, to: H * 0.4)
    }

    // ближняя крыша: край справа, перила
    let roofY = H * 0.24
    let roof = CGMutablePath()
    roof.move(to: CGPoint(x: W * 0.46, y: 0)); roof.addLine(to: CGPoint(x: W * 0.5, y: roofY)); roof.addLine(to: CGPoint(x: W, y: roofY + 10 * S)); roof.addLine(to: CGPoint(x: W, y: 0)); roof.closeSubpath()
    ctx.addPath(roof); ctx.setFillColor(rgb(0x050306)); ctx.fillPath()
    ctx.setStrokeColor(rgb(mix(moonC, 0x000000, 0.6), 0.6)); ctx.setLineWidth(2 * S)                // кромка, подсвеченная луной
    ctx.move(to: CGPoint(x: W * 0.5, y: roofY)); ctx.addLine(to: CGPoint(x: W, y: roofY + 10 * S)); ctx.strokePath()
    ctx.setStrokeColor(rgb(0x0a0609)); ctx.setLineWidth(4 * S)
    for i in 0..<9 {
        let x = W * (0.86 + CGFloat(i) * 0.02)
        ctx.move(to: CGPoint(x: x, y: roofY + 8 * S)); ctx.addLine(to: CGPoint(x: x, y: roofY + 90 * S)); ctx.strokePath()
    }
    ctx.move(to: CGPoint(x: W * 0.85, y: roofY + 90 * S)); ctx.addLine(to: CGPoint(x: W, y: roofY + 92 * S)); ctx.strokePath()

    // силуэт на краю крыши: ступни на кромке, голова на фоне луны
    let fx = W * 0.64, fy = roofY + 4 * S, fh = H * 0.36
    let red = 0xe0182c
    func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: fx + fh * x, y: fy + fh * y) }
    // щупальца — из поясницы, дугой вверх и в стороны, разной длины, с завитком на конце; рисуются до тела
    let back = P(0.01, 0.5)
    for (c1, c2, tip, w) in [((-0.35, 0.05), (-0.75, 0.75), (-0.95, 0.55), 0.10), ((-0.3, -0.15), (-0.9, 0.05), (-1.15, 0.28), 0.085),
                              ((0.35, 0.0), (0.8, 0.85), (1.05, 0.62), 0.10), ((0.3, -0.2), (0.95, -0.05), (1.25, 0.18), 0.08)]
        as [((CGFloat, CGFloat), (CGFloat, CGFloat), (CGFloat, CGFloat), CGFloat)] {
        tendril(ctx, back, P(c1.0, 0.5 + c1.1), P(c2.0, 0.5 + c2.1), P(tip.0, 0.5 + tip.1), width: fh * w, red: red, rng: &rng)
    }
    let ink = rgb(0x040305)
    ctx.setFillColor(ink)
    // ноги
    for side in [-1.0, 1.0] as [CGFloat] {
        let leg = CGMutablePath()
        leg.move(to: P(side * 0.012, 0.0)); leg.addLine(to: P(side * 0.065, 0.0)); leg.addLine(to: P(side * 0.055, 0.34)); leg.addLine(to: P(side * 0.005, 0.34)); leg.closeSubpath()
        ctx.addPath(leg); ctx.fillPath()
    }
    // плащ: широкие плечи, талия, расклёшенный рваный подол
    let coat = CGMutablePath()
    coat.move(to: P(-0.05, 0.8))
    coat.addQuadCurve(to: P(-0.13, 0.75), control: P(-0.11, 0.8))                       // плечо
    coat.addLine(to: P(-0.095, 0.55))                                                   // талия
    coat.addLine(to: P(-0.17, 0.24))                                                    // подол
    for (i, x) in stride(from: -0.17, through: 0.17, by: 0.034).enumerated() {
        coat.addLine(to: P(CGFloat(x), i % 2 == 0 ? 0.24 : 0.28))
    }
    coat.addLine(to: P(0.095, 0.55)); coat.addLine(to: P(0.13, 0.75))
    coat.addQuadCurve(to: P(0.05, 0.8), control: P(0.11, 0.8)); coat.closeSubpath()
    ctx.addPath(coat); ctx.fillPath()
    // руки вдоль тела, чуть отведены
    for side in [-1.0, 1.0] as [CGFloat] {
        let arm = CGMutablePath()
        arm.move(to: P(side * 0.11, 0.76)); arm.addLine(to: P(side * 0.15, 0.74)); arm.addLine(to: P(side * 0.16, 0.42)); arm.addLine(to: P(side * 0.125, 0.4)); arm.closeSubpath()
        ctx.addPath(arm); ctx.fillPath()
    }
    ctx.fill(CGRect(x: fx - fh * 0.022, y: fy + fh * 0.78, width: fh * 0.044, height: fh * 0.06))   // шея
    // голова и объёмные острые пряди, падающие на лицо
    let head = P(0, 0.885)
    ctx.fillEllipse(in: CGRect(x: head.x - fh * 0.058, y: head.y - fh * 0.07, width: fh * 0.116, height: fh * 0.135))
    let hair = CGMutablePath()
    let strands: [(CGFloat, CGFloat)] = [(-0.075, -0.045), (-0.1, 0.01), (-0.08, 0.03), (-0.11, 0.07), (-0.07, 0.07), (-0.085, 0.115), (-0.04, 0.095),
                                         (-0.03, 0.135), (0.0, 0.1), (0.03, 0.14), (0.035, 0.1), (0.08, 0.12), (0.065, 0.075), (0.11, 0.06), (0.075, 0.03),
                                         (0.1, -0.01), (0.07, -0.02), (0.075, -0.06), (0.045, -0.025), (0.02, -0.07), (0.0, -0.02), (-0.03, -0.065), (-0.035, -0.02)]
    hair.move(to: CGPoint(x: head.x + fh * strands[0].0, y: head.y + fh * strands[0].1))
    for (x, y) in strands.dropFirst() { hair.addLine(to: CGPoint(x: head.x + fh * x, y: head.y + fh * y)) }
    hair.closeSubpath(); ctx.addPath(hair); ctx.fillPath()
    // контровой свет луны по силуэту
    ctx.setStrokeColor(rgb(mix(moonC, 0xffffff, 0.25), 0.6 * glow)); ctx.setLineWidth(1.8 * S)
    for path in [hair, coat] as [CGPath] { ctx.addPath(path); ctx.strokePath() }
    // красный глаз (один) между прядями и его свечение
    let eye = CGPoint(x: head.x - fh * 0.024, y: head.y - fh * 0.005)
    radialGlow(ctx, eye, fh * 0.09, 0xff2030, 0.8)
    ctx.setFillColor(rgb(0xff6060)); ctx.fillEllipse(in: CGRect(x: eye.x - fh * 0.011, y: eye.y - fh * 0.005, width: fh * 0.022, height: fh * 0.01))

    // дождь: косые штрихи в два слоя
    for (count, len, alpha, blur) in [(1400, 26.0, 0.18, 0.8), (260, 70.0, 0.22, 2.0)] as [(Int, CGFloat, CGFloat, CGFloat)] {
        ctx.draw(blurLayer(blur) { l in
            var r2 = Rng(seed: UInt64(count))
            l.setLineCap(.round); l.setLineWidth(1.4 * S)
            for _ in 0..<count {
                let x = r2.next() * W * 1.1, y = r2.next() * H, ln = len * S * (0.6 + r2.next() * 0.8)
                l.setStrokeColor(rgb(0xc8b8c8, alpha * (0.4 + r2.next() * 0.6)))
                l.move(to: CGPoint(x: x, y: y)); l.addLine(to: CGPoint(x: x - ln * 0.25, y: y - ln)); l.strokePath()
            }
        }, in: extent)
    }
    return filmic(bloom(ctx.makeImage()!, near: 8, far: 50, strength: 0.9), grain: 0.06, vignette: 0.6)
}
