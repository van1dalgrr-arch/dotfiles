// Обои «Шёлк»: струящиеся ленты из сотен тонких светящихся нитей на тёмном — складки ткани.
// Под Liquid Glass (Ghostty, macos-glass-regular) ленты расплываются в цветное свечение — для этого
// формы крупные и плавные: мелкие детали под стеклом превратились бы в кашу.
// Цвета — цвет суток из wallpaper-kit, ленты медленно перетекают за сутки. Собирается через wall.

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let day = daylight(hour)
    let turn = hour / 24 * 2 * .pi

    // фон: почти чёрный с лёгким цветным светом снизу — чтобы стекло не было серым
    radialGlow(ctx, CGPoint(x: W * 0.3, y: -H * 0.1), W * 0.9, mix(a, 0x000000, 0.55), 0.55)
    radialGlow(ctx, CGPoint(x: W * 0.9, y: H * 1.05), W * 0.7, mix(b, 0x000000, 0.6), 0.45)

    // лента: семейство синусоид со сдвигом — нити сходятся и расходятся, получается складка
    func ribbon(y0: CGFloat, amp: CGFloat, freq: CGFloat, phase: CGFloat, twist: CGFloat,
                spread: CGFloat, c1: Int, c2: Int, alpha: CGFloat, threads: Int = 160) {
        ctx.setBlendMode(.plusLighter)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        for k in 0..<threads {
            let t = CGFloat(k) / CGFloat(threads - 1)
            // ~100 точек, соединённых гладкими кривыми через середины: ломаная из сотен отрезков
            // CoreGraphics режет на куски по ~128, и стык рисуется дважды — вертикальная черта
            let n = 100
            let pts: [CGPoint] = (0...n).map { i in
                let x = -W * 0.05 + W * 1.1 * CGFloat(i) / CGFloat(n), u = x / W
                // ширина ленты «дышит» вдоль x — ткань перекручивается; плавно, без |sin|:
                // на изломе все нити разом меняли направление и стыки светились
                let s = 0.5 + 0.5 * sin(u * .pi * twist + phase * 0.7)
                let width = spread * (0.25 + 0.75 * s * s * (3 - 2 * s))
                return CGPoint(x: x, y: H * (y0 + amp * sin(u * .pi * freq + phase) + (t - 0.5) * width
                                            + 0.025 * sin(u * .pi * freq * 2.3 + phase * 1.6 + t * 2)))
            }
            let p = CGMutablePath()
            p.move(to: pts[0])
            for i in 1..<n {
                let mid = CGPoint(x: (pts[i].x + pts[i + 1].x) / 2, y: (pts[i].y + pts[i + 1].y) / 2)
                p.addQuadCurve(to: mid, control: pts[i])
            }
            p.addLine(to: pts[n])
            // край ленты ярче середины — блик на сгибе
            let edge = pow(abs(t - 0.5) * 2, 3)
            ctx.addPath(p)
            ctx.setStrokeColor(rgb(mix(c1, c2, t), alpha * (0.45 + 0.9 * edge)))
            ctx.setLineWidth((1.1 + 1.4 * edge) * S)
            ctx.strokePath()
        }
        ctx.setBlendMode(.normal)
    }

    let drift = 0.6 * sin(turn)
    ribbon(y0: 0.60, amp: 0.15, freq: 1.3, phase: 0.4 + drift, twist: 1.6, spread: 0.30,
           c1: a, c2: b, alpha: 0.15, threads: 200)
    ribbon(y0: 0.34, amp: 0.12, freq: 1.7, phase: 2.2 - drift * 0.8, twist: 2.2, spread: 0.24,
           c1: mix(b, pink, 0.55), c2: violet, alpha: 0.13, threads: 180)
    ribbon(y0: 0.82, amp: 0.07, freq: 2.1, phase: 4.0 + drift * 1.2, twist: 1.1, spread: 0.14,
           c1: indigo, c2: mix(a, 0xffffff, 0.25), alpha: 0.09, threads: 120)

    // свечение нитей и плёночное зерно — без них процедурная картинка выглядит пластиковой
    let glowing = bloom(ctx.makeImage()!, near: 6, far: 60, strength: 0.75 + 0.25 * day)
    return filmic(glowing, grain: 0.03, vignette: 0.6)
}
