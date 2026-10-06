// Обои «Баухаус»: геометрический постер — круги, полукруги, полосы плоскими цветами.
// Композиция справа, слева пусто под иконки; полукруг поворачивается за сутки.
// Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let dark = { (c: Int) in mix(c, 0x050507, 0.25) }                // чуть притушенные цвета
    let turn = hour / 24 * 2 * .pi

    // тонкая сетка-направляющие
    ctx.setStrokeColor(rgb(0xffffff, 0.04)); ctx.setLineWidth(max(1, S))
    for i in 0..<6 { let x = W * (0.45 + CGFloat(i) * 0.1); ctx.move(to: CGPoint(x: x, y: 0)); ctx.addLine(to: CGPoint(x: x, y: H)) }
    ctx.strokePath()

    // большой круг
    let c1 = CGPoint(x: W * 0.70, y: H * 0.56), r1 = W * 0.17
    ctx.setFillColor(rgb(dark(a))); ctx.fillEllipse(in: CGRect(x: c1.x - r1, y: c1.y - r1, width: r1 * 2, height: r1 * 2))

    // полукруг, поворачивается
    let c2 = CGPoint(x: W * 0.80, y: H * 0.30), r2 = W * 0.10
    ctx.saveGState(); ctx.translateBy(x: c2.x, y: c2.y); ctx.rotate(by: turn * 0.5)
    ctx.move(to: .zero); ctx.addArc(center: .zero, radius: r2, startAngle: 0, endAngle: .pi, clockwise: false); ctx.closePath()
    ctx.setFillColor(rgb(dark(b))); ctx.fillPath(); ctx.restoreGState()

    // полоса и маленький круг
    ctx.saveGState(); ctx.translateBy(x: W * 0.62, y: H * 0.24); ctx.rotate(by: -0.35)
    ctx.setFillColor(rgb(dark(violet))); ctx.fill(CGRect(x: -W * 0.12, y: -11 * S, width: W * 0.24, height: 22 * S))
    ctx.restoreGState()
    let c3 = CGPoint(x: W * 0.58, y: H * 0.74), r3 = W * 0.035
    ctx.setFillColor(rgb(dark(pink))); ctx.fillEllipse(in: CGRect(x: c3.x - r3, y: c3.y - r3, width: r3 * 2, height: r3 * 2))

    // контур-кольцо поверх большого круга
    ctx.setStrokeColor(rgb(0xf0f0f0, 0.75)); ctx.setLineWidth(3 * S)
    let r4 = r1 * 0.62
    ctx.strokeEllipse(in: CGRect(x: c1.x - r4 + 60 * S, y: c1.y - r4 - 40 * S, width: r4 * 2, height: r4 * 2))

    // точки-ритм
    ctx.setFillColor(rgb(0xf0f0f0, 0.6))
    for i in 0..<7 { let x = W * 0.52 + CGFloat(i) * 26 * S; ctx.fillEllipse(in: CGRect(x: x, y: H * 0.42, width: 8 * S, height: 8 * S)) }
    return ctx.makeImage()!
}
