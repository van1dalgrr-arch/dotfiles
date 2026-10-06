// Обои «Снегопад»: ночной двор, высотки в снежной мгле, ветки под снегом, машины-сугробы и падающий снег.
// Снег в три слоя: дальний — мелкая пыль, ближний — крупные размытые хлопья. Ночью синее, днём серо-белое.

func snowKeys(_ hour: CGFloat) -> (fog: Int, deep: Int, snow: Int, lit: CGFloat) {
    let keys: [(CGFloat, Int, Int, Int, CGFloat)] = [
        (0, 0x2a323d, 0x12171e, 0xc9d2dc, 0.28), (6, 0x343e4b, 0x19202a, 0xd2dae3, 0.2), (9, 0x7c8792, 0x58626e, 0xe8edf2, 0.04),
        (13, 0x9aa3ad, 0x707a86, 0xf1f4f7, 0.02), (16, 0x7a8592, 0x55606d, 0xe5eaf0, 0.08), (18, 0x4a5563, 0x2a323e, 0xd6dde5, 0.2),
        (21, 0x323a46, 0x171c24, 0xccd4de, 0.3), (24, 0x2a323d, 0x12171e, 0xc9d2dc, 0.28)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), mix(keys[i].3, keys[i + 1].3, t), lerp(keys[i].4, keys[i + 1].4, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3, keys[0].4)
}

// голое дерево под снегом: тёмная ветка, сверху на ней — белая шапка
func snowyBranches(_ ctx: CGContext, from p0: CGPoint, angle: CGFloat, len: CGFloat, width: CGFloat, depth: Int,
                   bark: Int, snow: Int, rng: inout Rng) {
    var p = p0, a = angle
    let steps = 6
    for s in 0..<steps {
        a += (rng.next() - 0.5) * 0.5
        let q = CGPoint(x: p.x + cos(a) * len / CGFloat(steps), y: p.y + sin(a) * len / CGFloat(steps))
        let w = max(0.8 * S, width * (1 - CGFloat(s) / CGFloat(steps) * 0.5))
        ctx.setLineCap(.round)
        ctx.setStrokeColor(rgb(bark)); ctx.setLineWidth(w)
        ctx.move(to: p); ctx.addLine(to: q); ctx.strokePath()
        // снег лежит сверху: светлая линия, сдвинутая вверх, тем толще, чем горизонтальнее ветка
        let flat = max(0, cos(a) * cos(a))
        ctx.setStrokeColor(rgb(snow, 0.92 * min(1, max(0, (flat - 0.2) * 2.5)))); ctx.setLineWidth(w * 0.7 * flat + 0.6 * S)
        ctx.move(to: CGPoint(x: p.x, y: p.y + w * 0.45 * flat)); ctx.addLine(to: CGPoint(x: q.x, y: q.y + w * 0.45 * flat)); ctx.strokePath()
        // мелкие веточки
        if depth >= 2 && rng.next() < 0.6 {
            let ta = a + (rng.next() < 0.5 ? 1 : -1) * (0.6 + rng.next() * 0.6), tl = len * 0.25 * (0.5 + rng.next())
            ctx.setStrokeColor(rgb(bark, 0.9)); ctx.setLineWidth(max(0.7 * S, w * 0.35))
            let t = CGPoint(x: q.x + cos(ta) * tl, y: q.y + sin(ta) * tl)
            ctx.move(to: q); ctx.addLine(to: t); ctx.strokePath()
            ctx.setStrokeColor(rgb(snow, 0.8)); ctx.setLineWidth(max(0.6 * S, w * 0.25))
            ctx.move(to: CGPoint(x: q.x, y: q.y + 1.5 * S)); ctx.addLine(to: CGPoint(x: t.x, y: t.y + 1.5 * S)); ctx.strokePath()
        }
        p = q
    }
    if depth < 5 {
        for _ in 0..<(depth < 2 ? 3 : 2) {
            snowyBranches(ctx, from: p, angle: a + (rng.next() - 0.5) * 1.4, len: len * (0.55 + rng.next() * 0.2),
                          width: width * 0.6, depth: depth + 1, bark: bark, snow: snow, rng: &rng)
        }
    }
}

// падающий снег: слой хлопьев заданного размера, потом размытие (чем ближе — тем сильнее)
func snowLayer(_ count: Int, size: ClosedRange<CGFloat>, alpha: CGFloat, blur: CGFloat, color: Int, seed: UInt64) -> CGImage {
    let layer = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8, bytesPerRow: 0,
                          space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    var r = Rng(seed: seed)
    for _ in 0..<count {
        let x = r.next() * W, y = r.next() * H, s = lerp(size.lowerBound, size.upperBound, pow(r.next(), 2)) * S
        layer.setFillColor(rgb(color, alpha * (0.4 + r.next() * 0.6)))
        layer.fillEllipse(in: CGRect(x: x - s, y: y - s, width: s * 2, height: s * 2))
    }
    let img = layer.makeImage()!
    guard blur > 0 else { return img }
    return ci.createCGImage(CIImage(cgImage: img).applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: blur * S]).cropped(to: extent),
                            from: extent)!
}

runWallpaper { hour in
    let ctx = canvas()
    let (fog, deep, snow, lit) = snowKeys(hour)
    let ground = H * 0.17
    var rng = Rng(seed: 0x5E0F)

    let sky = CGGradient(colorsSpace: cs, colors: [rgb(fog), rgb(deep)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: ground), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])

    // дальние дома
    tower(ctx, W * 0.40, W * 0.06, H * 0.5, base: ground, k: 0.6, facade: 0x3c434d, fog: fog, fogMix: 0.85, lit: lit * 0.4, rng: &rng)
    haze(ctx, fog, bottom: 0.5, top: 0.3, from: ground, to: H)
    soften(ctx, 6)
    // две высотки: слева и справа-по-центру
    tower(ctx, -W * 0.02, W * 0.27, H * 0.74, base: ground, k: 1.1, facade: 0x4a525d, fog: fog, fogMix: 0.55, lit: lit, rng: &rng)
    tower(ctx, W * 0.46, W * 0.36, H * 0.6, base: ground, k: 1.05, facade: 0x47505b, fog: fog, fogMix: 0.6, lit: lit, rng: &rng)
    haze(ctx, fog, bottom: 0.55, top: 0.0, from: ground, to: H * 0.55)
    haze(ctx, fog, bottom: 0.0, top: 0.45, from: H * 0.5, to: H)
    soften(ctx, 2.5)

    // заснеженные кроны во дворе — мягкий светлый вал, сильно размытый
    ctx.draw(blurLayer(10) { l in
        var r2 = Rng(seed: 0xB05)
        for _ in 0..<420 {
            let x = r2.next() * W, y = ground + pow(r2.next(), 1.6) * H * 0.2, r = (14 + r2.next() * 34) * S
            l.setFillColor(rgb(mix(fog, snow, 0.3 + r2.next() * 0.45), 0.55)); l.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
        // тёмные стволы и тени внутри кустов
        for _ in 0..<60 {
            let x = r2.next() * W, y = ground + r2.next() * H * 0.1
            l.setFillColor(rgb(deep, 0.35)); l.fill(CGRect(x: x, y: y, width: (3 + r2.next() * 5) * S, height: (30 + r2.next() * 60) * S))
        }
    }, in: extent)
    // фонари двора: столб и свет в снежной мгле
    for (lx, ly) in [(0.33, 0.1), (0.8, 0.12)] as [(CGFloat, CGFloat)] {
        ctx.setFillColor(rgb(mix(deep, 0x000000, 0.4), 0.8)); ctx.fill(CGRect(x: W * lx - 3 * S, y: ground * 0.6, width: 6 * S, height: ground * 0.4 + H * ly))
        radialGlow(ctx, CGPoint(x: W * lx, y: ground + H * ly), 160 * S, 0xfff0d0, 0.12 + lit * 0.4)
        lamp(ctx, CGPoint(x: W * lx, y: ground + H * ly), 6 * S, 0xfff1d6, 0.7 + lit)
    }

    // земля: волнистые сугробы, светлые пятна под фонарями, в лёгком расфокусе
    ctx.draw(blurLayer(3) { l in
        l.setFillColor(rgb(mix(snow, deep, 0.32))); l.fill(CGRect(x: 0, y: 0, width: W, height: ground))
        for (i, (base, amp, shade)) in [(0.95, 0.08, 0.22), (0.7, 0.1, 0.14), (0.42, 0.12, 0.06)].enumerated() {
            let drift = CGMutablePath(); drift.move(to: CGPoint(x: 0, y: 0))
            for k in 0...64 {
                let x = CGFloat(k) / 64 * W
                let y = ground * (CGFloat(base) + CGFloat(amp) * sin(x / W * 9 + CGFloat(i) * 2.1) * cos(x / W * 4.3 + CGFloat(i)))
                drift.addLine(to: CGPoint(x: x, y: y))
            }
            drift.addLine(to: CGPoint(x: W, y: 0)); drift.closeSubpath()
            l.addPath(drift); l.setFillColor(rgb(mix(snow, deep, CGFloat(shade)))); l.fillPath()
        }
        for lx in [0.33, 0.8] as [CGFloat] {
            l.saveGState(); l.translateBy(x: W * lx, y: ground * 0.55); l.scaleBy(x: 3, y: 0.7)
            radialGlow(l, .zero, 90 * S, 0xfff3dc, 0.18 + lit * 0.5); l.restoreGState()
        }
    }, in: extent)
    haze(ctx, fog, bottom: 0.25, top: 0.0, from: 0, to: ground * 1.5)

    // дальний снег
    ctx.draw(snowLayer(4200, size: 0.8...1.7, alpha: 0.6, blur: 0.6, color: snow, seed: 1), in: extent)

    // ветки над кадром: справа большое дерево, слева сверху — одна ветка
    let bark = mix(deep, 0x000000, 0.55)
    snowyBranches(ctx, from: CGPoint(x: W * 1.02, y: H * 0.2), angle: 1.95, len: H * 0.5, width: 46 * S, depth: 0, bark: bark, snow: snow, rng: &rng)
    snowyBranches(ctx, from: CGPoint(x: W * 0.98, y: H * 0.72), angle: 2.7, len: W * 0.22, width: 20 * S, depth: 1, bark: bark, snow: snow, rng: &rng)
    snowyBranches(ctx, from: CGPoint(x: W * 0.08, y: H * 1.02), angle: -0.15, len: W * 0.16, width: 9 * S, depth: 2, bark: bark, snow: snow, rng: &rng)

    // ближний снег — крупные размытые хлопья
    ctx.draw(snowLayer(1100, size: 1.8...3.6, alpha: 0.75, blur: 1.2, color: snow, seed: 2), in: extent)
    ctx.draw(snowLayer(70, size: 6...12, alpha: 0.5, blur: 6, color: snow, seed: 3), in: extent)
    return filmic(bloom(ctx.makeImage()!, near: 6, far: 40, strength: 0.6), grain: 0.05, vignette: 0.5)
}
