// Обои «Спираль»: двойная спираль из светящихся точек и перемычек, по диагонали экрана.
// Спираль проворачивается за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let turn = hour / 24 * 2 * .pi
    let n = 90
    for i in 0..<n {
        let u = CGFloat(i) / CGFloat(n - 1)
        let cx = W * (0.36 + 0.58 * u), cy = H * (0.12 + 0.76 * u)      // ось по диагонали
        let ph = u * 6 * .pi + turn
        let amp = 170 * S
        let nxv: CGFloat = -0.65, nyv: CGFloat = 0.76                  // перпендикуляр к оси
        let p1 = CGPoint(x: cx + nxv * amp * sin(ph), y: cy + nyv * amp * sin(ph))
        let ph2 = ph + 2.2                                             // вторая нить сдвинута по фазе — видны обе
        let p2 = CGPoint(x: cx + nxv * amp * sin(ph2), y: cy + nyv * amp * sin(ph2))
        let depth1 = (cos(ph) + 1) / 2, depth2 = (cos(ph2) + 1) / 2       // что ближе — ярче и крупнее
        if i % 3 == 0 {
            ctx.setStrokeColor(rgb(mix(a, b, u), 0.18)); ctx.setLineWidth(max(1, 1.4 * S))
            ctx.move(to: p1); ctx.addLine(to: p2); ctx.strokePath()
        }
        for (p, d, c) in [(p1, depth1, a), (p2, depth2, b)] {
            let rad = (4 + 9 * d) * S
            ctx.setFillColor(rgb(mix(c, 0xffffff, 0.25 * d), 0.25 + 0.7 * d))
            ctx.fillEllipse(in: CGRect(x: p.x - rad, y: p.y - rad, width: rad * 2, height: rad * 2))
        }
    }
    stars(ctx, count: 120, alpha: 0.5)
    return bloom(ctx.makeImage()!, near: 5, far: 40, strength: 0.7)
}
