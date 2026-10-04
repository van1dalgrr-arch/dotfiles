// Обои «Плата»: дорожки печатной платы с площадками, по ним бегут световые импульсы.
// За сутки импульсы сдвигаются вдоль дорожек. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let step = 44 * S
    var r = Rng(seed: 0xC1C7)
    ctx.setLineCap(.round); ctx.setLineJoin(.round)

    for n in 0..<64 {
        // дорожка: старт у левого или правого края, шаги вперёд и по диагонали
        let fromLeft = n % 2 == 0
        var p = CGPoint(x: fromLeft ? -step : W + step, y: (r.next() * 0.9 + 0.05) * H)
        p.y = (p.y / step).rounded() * step
        var pts = [p]
        let length = 8 + Int(r.next() * 22)
        var dy: CGFloat = 0
        for _ in 0..<length {
            if r.next() < 0.25 { dy = [-1, 0, 1][Int(r.next() * 3) % 3] }
            p = CGPoint(x: p.x + (fromLeft ? step : -step), y: p.y + dy * step)
            pts.append(p)
        }
        let path = CGMutablePath(); path.addLines(between: pts)
        let col = mix(a, b, r.next())
        ctx.addPath(path); ctx.setStrokeColor(rgb(col, 0.16)); ctx.setLineWidth(max(1, 2 * S)); ctx.strokePath()

        // площадка на конце
        let end = pts.last!
        ctx.setStrokeColor(rgb(col, 0.35)); ctx.setLineWidth(max(1, 1.6 * S))
        ctx.strokeEllipse(in: CGRect(x: end.x - 6 * S, y: end.y - 6 * S, width: 12 * S, height: 12 * S))

        // импульс: яркий кусочек дорожки, позиция зависит от часа
        if n % 3 == 0 {
            let pos = (hour / 24 + r.next()).truncatingRemainder(dividingBy: 1) * CGFloat(pts.count - 2)
            let i = Int(pos)
            let seg = CGMutablePath(); seg.addLines(between: [pts[i], pts[min(i + 1, pts.count - 1)], pts[min(i + 2, pts.count - 1)]])
            ctx.addPath(seg); ctx.setStrokeColor(rgb(mix(col, 0xffffff, 0.3), 0.9)); ctx.setLineWidth(max(1, 2.6 * S)); ctx.strokePath()
        } else { _ = r.next() }
    }
    // центр спокойнее — затемняем, чтобы иконки и окна не терялись
    let calm = CGGradient(colorsSpace: cs, colors: [rgb(0x050507, 0.85), rgb(0x050507, 0)] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(calm, startCenter: CGPoint(x: W / 2, y: H / 2), startRadius: 0,
                           endCenter: CGPoint(x: W / 2, y: H / 2), endRadius: W * 0.42, options: [])
    return bloom(ctx.makeImage()!, near: 4, far: 30, strength: 0.8)
}
