// Обои «Неон»: неоновые фигуры на тёмной стене с отражением на полу — как вывеска в баре.
// Цвет трубок меняется за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let floorY = H * 0.24

    // стена: едва заметные горизонтальные швы
    ctx.setStrokeColor(rgb(0xffffff, 0.025)); ctx.setLineWidth(max(1, S))
    var y = floorY + 40 * S
    while y < H { ctx.move(to: CGPoint(x: 0, y: y)); ctx.addLine(to: CGPoint(x: W, y: y)); y += 46 * S }
    ctx.strokePath()

    // трубки: круг, треугольник, волна
    func tube(_ path: CGPath, _ c: Int) {
        ctx.addPath(path); ctx.setStrokeColor(rgb(c, 0.95)); ctx.setLineWidth(7 * S); ctx.setLineCap(.round); ctx.setLineJoin(.round); ctx.strokePath()
        ctx.addPath(path); ctx.setStrokeColor(rgb(mix(c, 0xffffff, 0.6), 0.9)); ctx.setLineWidth(2.2 * S); ctx.strokePath()   // светлая сердцевина
    }
    let cx = W * 0.62, cy = H * 0.58
    ctx.saveGState(); ctx.translateBy(x: cx, y: cy); ctx.scaleBy(x: 1.5, y: 1.5); ctx.translateBy(x: -cx, y: -cy)   // фигуры крупнее
    tube(CGPath(ellipseIn: CGRect(x: cx - 170 * S, y: cy - 170 * S, width: 340 * S, height: 340 * S), transform: nil), a)
    let tri = CGMutablePath()
    tri.move(to: CGPoint(x: cx + 120 * S, y: cy - 120 * S)); tri.addLine(to: CGPoint(x: cx + 330 * S, y: cy - 120 * S))
    tri.addLine(to: CGPoint(x: cx + 225 * S, y: cy + 60 * S)); tri.closeSubpath()
    tube(tri, pink)
    let wave = CGMutablePath()
    for k in 0...80 {
        let u = CGFloat(k) / 80
        let p = CGPoint(x: cx - 330 * S + u * 360 * S, y: cy - 230 * S + sin(u * .pi * 3) * 26 * S)
        k == 0 ? wave.move(to: p) : wave.addLine(to: p)
    }
    tube(wave, b)
    ctx.restoreGState()

    // пол и отражение: перевёрнутая копия стены, тусклая и размытая
    let wall = ctx.makeImage()!
    ctx.setFillColor(rgb(0x030304)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: floorY))
    let mirrored = CIImage(cgImage: wall)
        .transformed(by: CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -2 * floorY))
        .cropped(to: CGRect(x: 0, y: 0, width: W, height: floorY))
    let reflection = blurred(ci.createCGImage(mirrored, from: CGRect(x: 0, y: 0, width: W, height: floorY))!, 6 * S)
    if let ref = ci.createCGImage(reflection, from: CGRect(x: 0, y: 0, width: W, height: floorY)) {
        ctx.saveGState(); ctx.setAlpha(0.22); ctx.draw(ref, in: CGRect(x: 0, y: 0, width: W, height: floorY)); ctx.restoreGState()
    }
    let fade = CGGradient(colorsSpace: cs, colors: [rgb(0x030304, 1), rgb(0x030304, 0)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(fade, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: floorY), options: [])
    return bloom(ctx.makeImage()!, near: 10, far: 70, strength: 1.1)
}
