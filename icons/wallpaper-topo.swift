// Обои «Топо»: топографическая карта — изолинии рельефа, цвет по высоте (синий → фиолетовый).
// Рельеф медленно «дышит» за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let t = hour / 24 * 2 * .pi
    // высота: сумма холмов, центр масс справа — слева спокойно под иконки
    let hills: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(0.70, 0.55, 0.22, 1), (0.85, 0.25, 0.14, 0.7), (0.55, 0.20, 0.12, 0.5), (0.92, 0.80, 0.12, 0.6), (0.40, 0.75, 0.16, 0.35)]
    func height(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        hills.reduce(0) { acc, h in
            let dx = x - h.0 - 0.01 * sin(t + h.3 * 5), dy = (y - h.1) * H / W
            return acc + h.3 * exp(-(dx * dx + dy * dy) / (h.2 * h.2))
        }
    }
    // изолинии методом отрезков по сетке (marching squares, упрощённо)
    let step: CGFloat = 6 * S
    let nx = Int(W / step), ny = Int(H / step)
    var grid = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: nx + 1), count: ny + 1)
    for j in 0...ny { for i in 0...nx { grid[j][i] = height(CGFloat(i) * step / W, CGFloat(j) * step / H) } }
    ctx.setLineCap(.round)
    for level in 1..<28 {
        let v = CGFloat(level) * 0.045
        let major = level % 5 == 0
        ctx.setStrokeColor(rgb(mix(b, a, min(1, v * 1.4)), major ? 0.75 : 0.32))
        ctx.setLineWidth(max(1, (major ? 1.8 : 1.0) * S))
        for j in 0..<ny { for i in 0..<nx {
            let c = [grid[j][i], grid[j][i+1], grid[j+1][i+1], grid[j+1][i]]
            let corners = [CGPoint(x: CGFloat(i)*step, y: CGFloat(j)*step), CGPoint(x: CGFloat(i+1)*step, y: CGFloat(j)*step),
                           CGPoint(x: CGFloat(i+1)*step, y: CGFloat(j+1)*step), CGPoint(x: CGFloat(i)*step, y: CGFloat(j+1)*step)]
            var pts: [CGPoint] = []
            for e in 0..<4 {
                let p = c[e], q = c[(e + 1) % 4]
                if (p < v) != (q < v) {
                    let k = (v - p) / (q - p)
                    let A = corners[e], B = corners[(e + 1) % 4]
                    pts.append(CGPoint(x: A.x + (B.x - A.x) * k, y: A.y + (B.y - A.y) * k))
                }
            }
            if pts.count >= 2 { ctx.move(to: pts[0]); ctx.addLine(to: pts[1]) }
            if pts.count == 4 { ctx.move(to: pts[2]); ctx.addLine(to: pts[3]) }
        } }
        ctx.strokePath()
    }
    return bloom(ctx.makeImage()!, near: 3, far: 24, strength: 0.4)
}
