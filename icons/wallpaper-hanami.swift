// Обои «Ханами»: ветки сакуры в сумерках, за ними мост, тёмные деревья и вода с фонарём.
// Ближние ветки резкие, дальние — в расфокусе. Небо меняется за сутки, ночью горит фонарь. Собирается через wall.

func hanamiKeys(_ hour: CGFloat) -> (top: Int, low: Int, petal: Int, lampOn: CGFloat) {
    let keys: [(CGFloat, Int, Int, Int, CGFloat)] = [
        (0, 0x0c1020, 0x1a2036, 0xa592bd, 1), (5, 0x1c2340, 0x3a3f66, 0xbaa5d2, 0.9), (7, 0x4a5888, 0x9a92bf, 0xe6cfec, 0.3),
        (11, 0x8ea2c8, 0xc8d0e4, 0xf6e1ef, 0), (15, 0x8a9cc4, 0xc4c8e0, 0xf4dfee, 0), (18, 0x56649a, 0x9c97c4, 0xe8d0ec, 0.2),
        (20, 0x313c6a, 0x5d5f8f, 0xd0bbe2, 0.8), (22, 0x161c34, 0x2a3050, 0xad98c6, 1), (24, 0x0c1020, 0x1a2036, 0xa592bd, 1)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), mix(keys[i].3, keys[i + 1].3, t), lerp(keys[i].4, keys[i + 1].4, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3, keys[0].4)
}

runWallpaper { hour in
    let ctx = canvas()
    let (top, low, petal, lampOn) = hanamiKeys(hour)
    var rng = Rng(seed: 0x5A4C)

    // небо
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(low), rgb(top)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H * 0.45), end: CGPoint(x: 0, y: H), options: [.drawsBeforeStartLocation])

    // дальние деревья — мягкая тёмная полоса с кронами
    let trees = mix(top, 0x0a0d16, 0.55)
    ctx.setFillColor(rgb(trees))
    for i in 0..<70 {
        let x = CGFloat(i) / 70 * W * 1.05, r = (40 + rng.next() * 70) * S
        ctx.fillEllipse(in: CGRect(x: x - r, y: H * 0.78 + rng.next() * 50 * S - r, width: r * 2, height: r * 2))
    }
    ctx.fill(CGRect(x: 0, y: H * 0.3, width: W, height: H * 0.48))
    // цветущие деревья на том берегу — розоватые пятна
    for _ in 0..<220 {
        let x = W * (0.4 + rng.next() * 0.6), y = H * (0.36 + rng.next() * 0.2), r = (10 + rng.next() * 26) * S
        ctx.setFillColor(rgb(mix(trees, petal, 0.25 + rng.next() * 0.25), 0.7)); ctx.fillEllipse(in: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4))
    }

    // мост: полотно, балки и ванты
    let concrete = mix(low, 0x2a2e3e, 0.45)
    ctx.setFillColor(rgb(concrete)); ctx.fill(CGRect(x: 0, y: H * 0.74, width: W, height: H * 0.075))
    ctx.setFillColor(rgb(mix(concrete, 0x000000, 0.35))); ctx.fill(CGRect(x: 0, y: H * 0.715, width: W, height: H * 0.025))
    ctx.setFillColor(rgb(mix(concrete, 0xffffff, 0.12))); ctx.fill(CGRect(x: 0, y: H * 0.812, width: W, height: 5 * S))
    var bx: CGFloat = 40 * S
    while bx < W { ctx.setFillColor(rgb(mix(concrete, 0x000000, 0.2))); ctx.fill(CGRect(x: bx, y: H * 0.74, width: 50 * S, height: 18 * S)); bx += 230 * S }
    ctx.setStrokeColor(rgb(mix(concrete, 0xffffff, 0.2), 0.7)); ctx.setLineWidth(3 * S)
    for i in 0..<9 {
        let x0 = W * (0.08 + CGFloat(i) * 0.05)
        ctx.move(to: CGPoint(x: x0, y: H * 0.815)); ctx.addLine(to: CGPoint(x: W * 0.36, y: H * 1.05)); ctx.strokePath()
    }
    ctx.setFillColor(rgb(mix(concrete, 0x000000, 0.25))); ctx.fill(CGRect(x: W * 0.62, y: H * 0.3, width: 26 * S, height: H * 0.42))   // опора

    // вода: тёмная, с отражением неба и фонарём
    let waterTop = H * 0.3
    let water = CGGradient(colorsSpace: cs, colors: [rgb(mix(top, 0x000000, 0.6)), rgb(mix(low, 0x000000, 0.45))] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(water, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: waterTop), options: [])
    ctx.setStrokeColor(rgb(low, 0.12)); ctx.setLineWidth(2 * S)
    for _ in 0..<60 {
        let y = rng.next() * waterTop, x = rng.next() * W, l = (40 + rng.next() * 160) * S
        ctx.move(to: CGPoint(x: x, y: y)); ctx.addLine(to: CGPoint(x: x + l, y: y)); ctx.strokePath()
    }
    let lampP = CGPoint(x: W * 0.87, y: H * 0.5)
    if lampOn > 0.01 {
        lamp(ctx, lampP, 5 * S, 0xffd9a0, lampOn)
        ctx.saveGState(); ctx.translateBy(x: lampP.x, y: H * 0.12); ctx.scaleBy(x: 0.6, y: 5)
        radialGlow(ctx, .zero, 40 * S, 0xffcf8a, 0.35 * lampOn); ctx.restoreGState()
    }
    haze(ctx, low, bottom: 0.0, top: 0.25, from: H * 0.3, to: H)
    soften(ctx, 9)

    // дальние ветки — в расфокусе
    let bark = mix(top, 0x05060a, 0.75), shade = mix(mix(petal, 0x7a5f9a, 0.4), top, 0.45)
    blossomTree(ctx, roots: [Twig(p: CGPoint(x: W * 0.5, y: -40 * S), angle: 1.25, len: 330 * S, width: 12 * S, depth: 1)],
                bark: mix(bark, low, 0.3), petal: mix(petal, low, 0.3), shade: mix(shade, low, 0.3), scale: 0.8, rng: &rng)
    soften(ctx, 4)

    // ближнее дерево слева — главный объект кадра
    blossomTree(ctx, roots: [Twig(p: CGPoint(x: -60 * S, y: H * 0.05), angle: 0.55, len: 520 * S, width: 30 * S, depth: 0),
                             Twig(p: CGPoint(x: -40 * S, y: H * 0.62), angle: 0.25, len: 420 * S, width: 20 * S, depth: 1),
                             Twig(p: CGPoint(x: -30 * S, y: H * 0.95), angle: -0.2, len: 330 * S, width: 16 * S, depth: 1)],
                bark: bark, petal: petal, shade: shade, scale: 1.25, rng: &rng)
    return filmic(bloom(ctx.makeImage()!, near: 5, far: 40, strength: 0.45), grain: 0.045, vignette: 0.5)
}
