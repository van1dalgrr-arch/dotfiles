// Обои «Дюны»: слои гладких цветных волн, у каждой блик по гребню и тень у подножия — как
// абстрактные обои macOS. Под Liquid Glass — мягкие цветные полосы. Цвета — цвет суток из
// wallpaper-kit: ближние слои темнее, дальние светлее (воздушная перспектива). Собирается через wall.

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let day = daylight(hour)
    let turn = hour / 24 * 2 * .pi

    // небо: от цвета суток сверху к почти чёрному у горизонта
    let sky = CGGradient(colorsSpace: cs, colors: [rgb(mix(b, 0x000000, 0.35 - 0.15 * day)), rgb(mix(a, 0x050507, 0.8))] as CFArray,
                         locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: H * 0.35), options: [.drawsAfterEndLocation])
    radialGlow(ctx, CGPoint(x: W * 0.72, y: H * 0.78), W * 0.45, mix(b, 0xffffff, 0.25), 0.22 + 0.18 * day)

    // 7 слоёв: дальний (светлый, высокий) → ближний (тёмный, низкий)
    let layers = 7
    for i in 0..<layers {
        let k = CGFloat(i) / CGFloat(layers - 1)                 // 0 — дальний, 1 — ближний
        let crest = H * (0.70 - 0.62 * k)                         // высота гребня
        let amp = H * (0.05 + 0.05 * k)
        let ph = CGFloat(i) * 1.7 + turn * (0.15 + 0.1 * k)
        // гребень — сумма двух синусоид, ~80 точек гладкими кривыми (без длинных ломаных)
        let n = 80
        let pts: [CGPoint] = (0...n).map { j in
            let x = W * CGFloat(j) / CGFloat(n), u = x / W
            return CGPoint(x: x, y: crest + amp * sin(u * .pi * (1.1 + 0.3 * k) + ph)
                                          + amp * 0.35 * sin(u * .pi * (2.7 + 0.5 * k) + ph * 1.4))
        }
        let ridge = CGMutablePath()
        ridge.move(to: pts[0])
        for j in 1..<n {
            ridge.addQuadCurve(to: CGPoint(x: (pts[j].x + pts[j + 1].x) / 2, y: (pts[j].y + pts[j + 1].y) / 2), control: pts[j])
        }
        ridge.addLine(to: pts[n])
        let body = ridge.mutableCopy()!
        body.addLine(to: CGPoint(x: W, y: 0)); body.addLine(to: CGPoint(x: 0, y: 0)); body.closeSubpath()

        // цвет слоя: по кругу палитры суток (синий → фиолетовый → розовый), дальние светлее,
        // ближние глубже и темнее — воздушная перспектива
        let hues = [b, mix(b, violet, 0.6), violet, mix(violet, pink, 0.55), pink, mix(a, violet, 0.5), a]
        let c = mix(hues[i % hues.count], 0x050507, 0.30 + 0.55 * k)
        let top = mix(c, 0xffffff, 0.12 * (1 - k) + 0.04)
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 18 * S), blur: 60 * S, color: rgb(0x000000, 0.55))
        ctx.addPath(body); ctx.setFillColor(rgb(c)); ctx.fillPath()
        ctx.restoreGState()
        // объём: светлее у гребня, к подножию — в тень
        ctx.saveGState(); ctx.addPath(body); ctx.clip()
        let g = CGGradient(colorsSpace: cs, colors: [rgb(top), rgb(c), rgb(mix(c, 0x000000, 0.45))] as CFArray, locations: [0, 0.35, 1])!
        // начало — выше самого высокого гребня (две синусоиды дают до 1.35 amp), иначе над ним «полка»
        ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: crest + amp * 1.4), end: CGPoint(x: 0, y: crest - H * 0.25),
                               options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        ctx.restoreGState()
        // блик по гребню
        ctx.addPath(ridge); ctx.setStrokeColor(rgb(mix(top, 0xffffff, 0.5), 0.18 * (1 - 0.6 * k))); ctx.setLineWidth(2.2 * S)
        ctx.strokePath()
    }
    return filmic(ctx.makeImage()!, grain: 0.035, vignette: 0.5)
}
