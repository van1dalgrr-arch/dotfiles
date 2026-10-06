// Обои «Туманный город»: панельные высотки тонут в синем тумане, провода, забор, редкие тёплые окна.
// Днём туман светлый и серый, в сумерках — синий, ночью окна зажигаются. Собирается через wall (с wallpaper-kit.swift).

// цвет тумана и доля горящих окон по часу
func mistKeys(_ hour: CGFloat) -> (fog: Int, deep: Int, lit: CGFloat) {
    let keys: [(CGFloat, Int, Int, CGFloat)] = [
        (0, 0x18202d, 0x0c1118, 0.30), (5, 0x222c3d, 0x111824, 0.22), (7, 0x3d4d68, 0x253247, 0.12),
        (10, 0x7b8798, 0x5a6577, 0.02), (14, 0x8a95a5, 0x667183, 0.01), (17, 0x5d6b82, 0x3d4a60, 0.06),
        (19, 0x3a4a66, 0x223047, 0.16), (21, 0x26304a, 0x141b2a, 0.26), (24, 0x18202d, 0x0c1118, 0.30)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), lerp(keys[i].3, keys[i + 1].3, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3)
}

runWallpaper { hour in
    let ctx = canvas()
    let (fog, deep, lit) = mistKeys(hour)
    let ground = H * 0.27
    var rng = Rng(seed: 0xF06C17)

    // небо — сплошной туман, книзу чуть светлее
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(mix(fog, 0xffffff, 0.06)), rgb(deep)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: ground), end: CGPoint(x: 0, y: H), options: [])

    // дальний план: силуэты едва видны
    for (x, w, h) in [(0.30, 0.07, 0.42), (0.40, 0.05, 0.36), (0.47, 0.09, 0.47), (0.60, 0.06, 0.40), (0.73, 0.05, 0.33)] as [(CGFloat, CGFloat, CGFloat)] {
        tower(ctx, W * x, W * w, H * h, base: ground, k: 0.55, facade: 0x3a4250, fog: fog, fogMix: 0.82, lit: lit * 0.3, rng: &rng)
    }
    haze(ctx, fog, bottom: 0.55, top: 0.2, from: ground, to: H * 0.8)
    haze(ctx, fog, bottom: 0.0, top: 0.6, from: H * 0.45, to: H * 0.8)
    soften(ctx, 7)

    // средний план
    for (x, w, h, f) in [(0.17, 0.09, 0.30, 0x4a4f5c), (0.27, 0.06, 0.25, 0x5a4a44), (0.45, 0.07, 0.36, 0x4c5260),
                          (0.53, 0.05, 0.30, 0x553f3a), (0.66, 0.07, 0.27, 0x4a505c)] as [(CGFloat, CGFloat, CGFloat, Int)] {
        tower(ctx, W * x, W * w, H * h, base: ground, k: 0.8, facade: f, fog: fog, fogMix: 0.55, lit: lit * 0.7, rng: &rng)
    }
    haze(ctx, fog, bottom: 0.45, top: 0.0, from: ground, to: H * 0.65)
    haze(ctx, fog, bottom: 0.0, top: 0.55, from: H * 0.4, to: H * 0.7)
    soften(ctx, 2.5)

    // ближние высотки по краям — как в кадре с улицы
    tower(ctx, -W * 0.01, W * 0.17, H * 0.58, base: ground, k: 1.25, facade: 0x4b5160, fog: fog, fogMix: 0.5, lit: lit, rng: &rng)
    tower(ctx, W * 0.76, W * 0.25, H * 0.66, base: ground, k: 1.3, facade: 0x4e5462, fog: fog, fogMix: 0.46, lit: lit, rng: &rng)
    haze(ctx, fog, bottom: 0.35, top: 0.0, from: ground, to: H * 0.5)
    haze(ctx, fog, bottom: 0.0, top: 0.5, from: H * 0.55, to: H)
    soften(ctx, 1.8)

    // улица: глухой забор из профлиста и фонари за ним
    let fenceH = 95 * S
    ctx.setFillColor(rgb(mix(0x1f242c, fog, 0.3))); ctx.fill(CGRect(x: 0, y: ground - 8 * S, width: W, height: fenceH))
    var x: CGFloat = 0
    while x < W {
        let v = rng.next()
        ctx.setFillColor(rgb(mix(0x3a404b, fog, 0.3), 0.35 + v * 0.35)); ctx.fill(CGRect(x: x, y: ground - 8 * S, width: 4 * S, height: fenceH))
        x += 12 * S
    }
    for lx in [0.03, 0.12, 0.22, 0.33, 0.41] as [CGFloat] {
        lamp(ctx, CGPoint(x: W * lx, y: ground + 100 * S), 3.6 * S, warm, 0.55 + lit)
    }
    // асфальт
    let road = CGGradient(colorsSpace: cs, colors: [rgb(mix(deep, 0x000000, 0.35)), rgb(mix(deep, fog, 0.4))] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(road, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: ground - 8 * S), options: [])
    // мокрый асфальт: размытые отражения фонарей и разметка, уходящая в туман
    for lx in [0.03, 0.12, 0.22, 0.33, 0.41] as [CGFloat] {
        ctx.saveGState(); ctx.translateBy(x: W * lx, y: ground - 20 * S); ctx.scaleBy(x: 1, y: 4.5)
        radialGlow(ctx, .zero, 22 * S, warm, 0.10 + lit * 0.35)
        ctx.restoreGState()
    }
    ctx.setFillColor(rgb(mix(0x9aa3b0, fog, 0.5), 0.18))
    var mx: CGFloat = 0
    while mx < W { ctx.fill(CGRect(x: mx, y: ground * 0.55, width: 90 * S, height: 4 * S)); mx += 190 * S }

    // столб и провода через весь кадр — ближние резкие
    let dark = mix(0x0b0e13, fog, 0.12)
    ctx.setFillColor(rgb(dark, 0.9)); ctx.fill(CGRect(x: W * 0.115, y: ground - 10 * S, width: 7 * S, height: H * 0.37))
    ctx.fill(CGRect(x: W * 0.095, y: ground + H * 0.35, width: 60 * S, height: 4 * S))
    let top = CGPoint(x: W * 0.118, y: ground + H * 0.355)
    wire(ctx, CGPoint(x: -W * 0.05, y: H * 0.56), CGPoint(x: W * 0.80, y: H * 1.02), sag: H * 0.05, dark, 0.85, 2.4)
    wire(ctx, top, CGPoint(x: W * 1.05, y: H * 0.68), sag: H * 0.03, dark, 0.7, 1.6)
    wire(ctx, top, CGPoint(x: W * 1.05, y: H * 0.61), sag: H * 0.04, dark, 0.6, 1.4)
    wire(ctx, CGPoint(x: W * 0.9, y: H * 1.02), CGPoint(x: W * 1.05, y: H * 0.93), sag: H * 0.01, dark, 0.8, 2.0)

    // передний план: решётка ограждения с косыми перекладинами
    let rail = mix(0x07090c, fog, 0.08), railTop = H * 0.10
    ctx.setStrokeColor(rgb(rail, 0.95)); ctx.setLineWidth(5 * S)
    ctx.move(to: CGPoint(x: 0, y: railTop)); ctx.addLine(to: CGPoint(x: W, y: railTop)); ctx.strokePath()
    ctx.setLineWidth(3 * S)
    var px = W * 0.31
    while px < W {
        ctx.setFillColor(rgb(rail)); ctx.fill(CGRect(x: px - 4 * S, y: 0, width: 8 * S, height: railTop + 6 * S))
        let span = W * 0.11
        ctx.move(to: CGPoint(x: px, y: 0)); ctx.addLine(to: CGPoint(x: px + span / 2, y: railTop))
        ctx.addLine(to: CGPoint(x: px + span, y: 0)); ctx.strokePath()
        ctx.move(to: CGPoint(x: px, y: railTop)); ctx.addLine(to: CGPoint(x: px + span / 2, y: 0))
        ctx.addLine(to: CGPoint(x: px + span, y: railTop)); ctx.strokePath()
        px += span
    }
    // общий туман у земли поверх всего
    haze(ctx, fog, bottom: 0.18, top: 0.0, from: 0, to: H * 0.4)
    return filmic(bloom(ctx.makeImage()!, near: 6, far: 30, strength: 0.8), grain: 0.05, vignette: 0.45)
}
