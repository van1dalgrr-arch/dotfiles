// Обои «Призма»: белый луч входит в призму и раскладывается в спектр фиолетовых, синих
// и розовых оттенков. Веер спектра чуть поворачивается за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let c = CGPoint(x: W * 0.46, y: H * 0.54), side = 330 * S
    let h = side * sqrt(3) / 2
    let top = CGPoint(x: c.x, y: c.y + h * 2 / 3)
    let left = CGPoint(x: c.x - side / 2, y: c.y - h / 3), right = CGPoint(x: c.x + side / 2, y: c.y - h / 3)

    // входящий луч: к левой грани
    let entry = CGPoint(x: (top.x + left.x) / 2, y: (top.y + left.y) / 2)
    ctx.setStrokeColor(rgb(0xffffff, 0.85)); ctx.setLineWidth(3 * S)
    ctx.move(to: CGPoint(x: 0, y: entry.y - 110 * S)); ctx.addLine(to: entry); ctx.strokePath()

    // спектр: веер клиньев от правой грани к краю экрана
    let exit = CGPoint(x: (top.x + right.x) / 2, y: (top.y + right.y) / 2)
    let colors = [violet, indigo, a, blue, b, mix(b, pink, 0.5), pink]
    let swing = sin(hour / 24 * 2 * .pi) * 0.06
    let n = colors.count
    for i in 0..<n {
        let t0 = CGFloat(i) / CGFloat(n), t1 = CGFloat(i + 1) / CGFloat(n)
        let a0 = -0.30 + swing + t0 * 0.38, a1 = -0.30 + swing + t1 * 0.38
        let far = W
        let wedge = CGMutablePath()
        wedge.move(to: exit)
        wedge.addLine(to: CGPoint(x: exit.x + cos(a0) * far, y: exit.y + sin(a0) * far))
        wedge.addLine(to: CGPoint(x: exit.x + cos(a1) * far, y: exit.y + sin(a1) * far))
        wedge.closeSubpath()
        ctx.saveGState(); ctx.addPath(wedge); ctx.clip()
        let g = CGGradient(colorsSpace: cs, colors: [rgb(colors[i], 0.85), rgb(colors[i], 0.25)] as CFArray, locations: [0, 1])!
        ctx.drawLinearGradient(g, start: exit, end: CGPoint(x: W, y: exit.y), options: [])
        ctx.restoreGState()
    }

    // сама призма: тёмное стекло с тонким контуром
    let prism = CGMutablePath(); prism.addLines(between: [top, left, right]); prism.closeSubpath()
    ctx.addPath(prism); ctx.setFillColor(rgb(0x0b0b10, 0.92)); ctx.fillPath()
    ctx.addPath(prism); ctx.setStrokeColor(rgb(0xffffff, 0.55)); ctx.setLineWidth(2 * S); ctx.setLineJoin(.round); ctx.strokePath()
    // свет внутри призмы
    let inner = CGMutablePath(); inner.addLines(between: [entry, exit])
    ctx.addPath(inner); ctx.setStrokeColor(rgb(0xffffff, 0.25)); ctx.setLineWidth(10 * S); ctx.strokePath()
    return bloom(ctx.makeImage()!, near: 6, far: 50, strength: 0.7)
}
