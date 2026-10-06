// Обои «Ночная сакура»: огромная полная луна, ветви сакуры сверху, гирлянда бумажных фонариков
// и падающие лепестки. Днём небо голубеет, фонарики гаснут. Собирается через wall (с wallpaper-kit.swift).

func sakuraNightKeys(_ hour: CGFloat) -> (top: Int, low: Int, petal: Int, night: CGFloat) {
    let keys: [(CGFloat, Int, Int, Int, CGFloat)] = [
        (0, 0x060a1e, 0x1a2350, 0xf0c6dc, 1.0), (5, 0x111a3c, 0x3a3f72, 0xf3cde0, 0.8), (8, 0x5f86c4, 0xc6d8f0, 0xf8d6e6, 0.0),
        (14, 0x5a84c8, 0xc0d6f2, 0xf8d4e4, 0.0), (18, 0x2e3878, 0xd890a8, 0xf6c8dc, 0.4), (20, 0x0e1436, 0x2e2f68, 0xf0c4da, 0.9),
        (24, 0x060a1e, 0x1a2350, 0xf0c6dc, 1.0)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), mix(keys[i].3, keys[i + 1].3, t), lerp(keys[i].4, keys[i + 1].4, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3, keys[0].4)
}

// бумажный фонарик тётин: овал с рёбрами, тёмные крышечки, тёплое свечение
func chochin(_ ctx: CGContext, _ p: CGPoint, _ r: CGFloat, on: CGFloat) {
    let body = CGRect(x: p.x - r * 0.75, y: p.y - r, width: r * 1.5, height: r * 2)
    if on > 0.01 { radialGlow(ctx, p, r * 5, 0xff7a3c, 0.35 * on) }
    let g = CGGradient(colorsSpace: cs, colors: [rgb(mix(0xc8402e, 0xffd08a, on * 0.6)), rgb(mix(0x8a2a22, 0xe0583a, on * 0.5))] as CFArray, locations: [0, 1])!
    ctx.saveGState(); ctx.addEllipse(in: body); ctx.clip()
    ctx.drawRadialGradient(g, startCenter: p, startRadius: 0, endCenter: p, endRadius: r * 1.1, options: [])
    ctx.setStrokeColor(rgb(0x5a1a14, 0.35)); ctx.setLineWidth(1.2 * S)
    for i in 1..<6 { let y = body.minY + body.height * CGFloat(i) / 6; ctx.move(to: CGPoint(x: body.minX, y: y)); ctx.addLine(to: CGPoint(x: body.maxX, y: y)); ctx.strokePath() }
    ctx.restoreGState()
    ctx.setFillColor(rgb(0x1a0f0c))
    ctx.fill(CGRect(x: p.x - r * 0.45, y: body.maxY - r * 0.12, width: r * 0.9, height: r * 0.2))
    ctx.fill(CGRect(x: p.x - r * 0.45, y: body.minY - r * 0.08, width: r * 0.9, height: r * 0.2))
}

runWallpaper { hour in
    let ctx = canvas()
    let (top, low, petal, night) = sakuraNightKeys(hour)
    var rng = Rng(seed: 0x5A9)

    let sky = CGGradient(colorsSpace: cs, colors: [rgb(low), rgb(top)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H * 0.2), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])
    stars(ctx, count: 900, alpha: night * 0.9, seed: 0x5A9)

    // луна: большая, с ореолом; днём бледная
    let mc = CGPoint(x: W * 0.62, y: H * 0.55), mr = H * 0.22
    radialGlow(ctx, mc, mr * 3, 0xdfe6ff, 0.2 * night + 0.05)
    let disc = CGGradient(colorsSpace: cs, colors: [rgb(0xeee6d6, 0.35 + night * 0.5), rgb(0xc8cede, 0.3 + night * 0.5)] as CFArray, locations: [0, 1])!
    ctx.saveGState(); ctx.addEllipse(in: CGRect(x: mc.x - mr, y: mc.y - mr, width: mr * 2, height: mr * 2)); ctx.clip()
    ctx.drawRadialGradient(disc, startCenter: CGPoint(x: mc.x - mr * 0.3, y: mc.y + mr * 0.3), startRadius: 0, endCenter: mc, endRadius: mr * 1.2, options: [])
    for _ in 0..<18 {
        let p = CGPoint(x: mc.x + (rng.next() - 0.5) * mr * 1.7, y: mc.y + (rng.next() - 0.5) * mr * 1.7), r = mr * (0.05 + rng.next() * 0.18)
        ctx.setFillColor(rgb(0x9aa2bc, 0.18 * night)); ctx.fillEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
    }
    ctx.restoreGState()

    // дальний берег: тёмная полоса деревьев, редкие огни
    let far = mix(top, 0x03040a, 0.7)
    ctx.setFillColor(rgb(far))
    for i in 0..<90 { let x = CGFloat(i) / 90 * W * 1.05, r = (20 + rng.next() * 50) * S; ctx.fillEllipse(in: CGRect(x: x - r, y: H * 0.22 + rng.next() * 30 * S - r, width: r * 2, height: r * 2)) }
    ctx.fill(CGRect(x: 0, y: 0, width: W, height: H * 0.22))
    for _ in 0..<30 { lamp(ctx, CGPoint(x: rng.next() * W, y: H * (0.12 + rng.next() * 0.08)), 2 * S, 0xffc27a, 0.4 * night) }
    soften(ctx, 3)

    // дальние ветки в расфокусе, ближние — резкие, свисают сверху
    let bark = mix(top, 0x020206, 0.8), shade = mix(mix(petal, 0x8a5a90, 0.45), top, 0.4)
    blossomTree(ctx, roots: [Twig(p: CGPoint(x: W * 1.05, y: H * 0.98), angle: 3.6, len: 420 * S, width: 18 * S, depth: 1)],
                bark: mix(bark, low, 0.3), petal: mix(petal, low, 0.35), shade: mix(shade, low, 0.35), scale: 0.9, rng: &rng)
    soften(ctx, 5)
    blossomTree(ctx, roots: [Twig(p: CGPoint(x: -40 * S, y: H * 1.02), angle: -0.35, len: 560 * S, width: 32 * S, depth: 0),
                             Twig(p: CGPoint(x: W * 0.35, y: H * 1.05), angle: -1.2, len: 300 * S, width: 14 * S, depth: 2)],
                bark: bark, petal: petal, shade: shade, scale: 1.2, rng: &rng)

    // гирлянда фонариков на провисающем шнуре
    let a = CGPoint(x: -20 * S, y: H * 0.74), b = CGPoint(x: W * 1.02, y: H * 0.8)
    wire(ctx, a, b, sag: H * 0.12, 0x120a0a, 0.9, 2)
    for i in 1..<9 {
        let t = CGFloat(i) / 9, p = CGPoint(x: lerp(a.x, b.x, t), y: lerp(a.y, b.y, t) - H * 0.12 * 4 * t * (1 - t))
        ctx.setStrokeColor(rgb(0x120a0a)); ctx.setLineWidth(1.5 * S); ctx.move(to: p); ctx.addLine(to: CGPoint(x: p.x, y: p.y - 26 * S)); ctx.strokePath()
        chochin(ctx, CGPoint(x: p.x, y: p.y - 26 * S - 34 * S), 34 * S, on: night)
    }

    // падающие лепестки: мелкие резкие и крупные размытые у зрителя
    for (count, size, blur) in [(260, 5.0, 0.0), (40, 14.0, 5.0)] as [(Int, CGFloat, CGFloat)] {
        ctx.draw(blurLayer(blur) { l in
            var r2 = Rng(seed: UInt64(count) * 7)
            for _ in 0..<count {
                let p = CGPoint(x: r2.next() * W, y: r2.next() * H), s = size * S * (0.6 + r2.next() * 0.8)
                l.saveGState(); l.translateBy(x: p.x, y: p.y); l.rotate(by: r2.next() * 6.28)
                l.setFillColor(rgb(mix(petal, 0xffffff, r2.next() * 0.3), 0.85)); l.fillEllipse(in: CGRect(x: -s, y: -s * 0.55, width: s * 2, height: s * 1.1))
                l.restoreGState()
            }
        }, in: extent)
    }
    return filmic(bloom(ctx.makeImage()!, near: 6, far: 45, strength: 0.7), grain: 0.04, vignette: 0.5)
}
