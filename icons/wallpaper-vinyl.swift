// Обои «Винил»: пластинка с бороздками, цветной этикеткой и бликом.
// За сутки пластинка поворачивается. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let c = CGPoint(x: W * 0.68, y: H * 0.50), R = H * 0.42
    radialGlow(ctx, c, R * 1.6, a, 0.10)
    ctx.setFillColor(rgb(0x0a0a0d)); ctx.fillEllipse(in: CGRect(x: c.x - R, y: c.y - R, width: R * 2, height: R * 2))
    // бороздки
    var r = Rng(seed: 0x71A1)
    var rad = R * 0.98
    while rad > R * 0.36 {
        ctx.setStrokeColor(rgb(0xffffff, 0.025 + r.next() * 0.035)); ctx.setLineWidth(max(1, 1.1 * S))
        ctx.strokeEllipse(in: CGRect(x: c.x - rad, y: c.y - rad, width: rad * 2, height: rad * 2))
        rad -= (3 + r.next() * 4) * S
    }
    // блики: два сектора света, поворачиваются за сутки
    let turn = hour / 24 * 2 * .pi
    for k in 0..<2 {
        let s = turn + CGFloat(k) * .pi
        ctx.saveGState()
        let wedge = CGMutablePath(); wedge.move(to: c)
        wedge.addArc(center: c, radius: R, startAngle: s, endAngle: s + 0.35, clockwise: false); wedge.closeSubpath()
        ctx.addPath(wedge); ctx.clip()
        let g = CGGradient(colorsSpace: cs, colors: [rgb(b, 0), rgb(mix(b, 0xffffff, 0.4), 0.16), rgb(b, 0)] as CFArray, locations: [0.3, 0.7, 1])!
        ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: R, options: [])
        ctx.restoreGState()
    }
    // этикетка
    let lr = R * 0.33
    let label = CGGradient(colorsSpace: cs, colors: [rgb(a), rgb(b)] as CFArray, locations: [0, 1])!
    ctx.saveGState(); ctx.addEllipse(in: CGRect(x: c.x - lr, y: c.y - lr, width: lr * 2, height: lr * 2)); ctx.clip()
    ctx.drawLinearGradient(label, start: CGPoint(x: c.x - lr, y: c.y + lr), end: CGPoint(x: c.x + lr, y: c.y - lr), options: [])
    ctx.restoreGState()
    ctx.setStrokeColor(rgb(0x050507, 0.35)); ctx.setLineWidth(2 * S)
    ctx.strokeEllipse(in: CGRect(x: c.x - lr * 0.7, y: c.y - lr * 0.7, width: lr * 1.4, height: lr * 1.4))
    ctx.setFillColor(rgb(0x050507)); ctx.fillEllipse(in: CGRect(x: c.x - 9 * S, y: c.y - 9 * S, width: 18 * S, height: 18 * S))
    return bloom(ctx.makeImage()!, near: 4, far: 40, strength: 0.4)
}
