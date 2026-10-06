// Обои «Кристалл»: низкополигональная мозаика — треугольники, освещённые как грани.
// Свет за сутки обходит по кругу. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let ang = hour / 24 * 2 * .pi
    let light = (x: cos(ang), y: sin(ang))
    let cols = 16, rows = 11
    var r = Rng(seed: 0xC2A5)
    // сетка вершин с дрожанием
    var pts = [[CGPoint]]()
    for j in 0...rows {
        var row = [CGPoint]()
        for i in 0...cols {
            let jx = (i == 0 || i == cols) ? 0 : (r.next() - 0.5) * 0.7
            let jy = (j == 0 || j == rows) ? 0 : (r.next() - 0.5) * 0.7
            row.append(CGPoint(x: (CGFloat(i) + jx) / CGFloat(cols) * W, y: (CGFloat(j) + jy) / CGFloat(rows) * H))
        }
        pts.append(row)
    }
    for j in 0..<rows { for i in 0..<cols {
        for tri in [[pts[j][i], pts[j][i+1], pts[j+1][i]], [pts[j][i+1], pts[j+1][i+1], pts[j+1][i]]] {
            // наклон грани: случайная нормаль, яркость — скалярное произведение со светом
            let nx = r.next() - 0.5, ny = r.next() - 0.5
            let shade = max(0, min(1, 0.45 + (nx * light.x + ny * light.y) * 1.3))
            let cx = (tri[0].x + tri[1].x + tri[2].x) / 3
            let glow = exp(-pow((cx / W - 0.68) / 0.35, 2))            // ярче справа, слева темно под иконки
            let c = mix(mix(a, b, cx / W), 0x050507, 1 - (0.15 + 0.55 * shade) * glow)
            let p = CGMutablePath(); p.addLines(between: tri); p.closeSubpath()
            ctx.addPath(p); ctx.setFillColor(rgb(c)); ctx.fillPath()
            ctx.addPath(p); ctx.setStrokeColor(rgb(0xffffff, 0.03 + 0.05 * glow)); ctx.setLineWidth(max(1, S)); ctx.strokePath()
        }
    } }
    return ctx.makeImage()!
}
