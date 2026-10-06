// Обои «Полутон»: шар, нарисованный точками разного размера — как в печати и поп-арте.
// Свет на шаре за сутки обходит по кругу. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let c = CGPoint(x: W * 0.66, y: H * 0.50), R = H * 0.36
    let ang = hour / 24 * 2 * .pi + 2.2
    let light = (x: cos(ang) * 0.6, y: sin(ang) * 0.6, z: 0.55)
    let step = 22 * S

    var y = step / 2
    while y < H {
        var x = step / 2 + ((Int(y / step) % 2 == 0) ? 0 : step / 2)   // шахматный сдвиг рядов
        while x < W {
            let dx = (x - c.x) / R, dy = (y - c.y) / R
            let d2 = dx * dx + dy * dy
            var v: CGFloat = 0
            if d2 < 1 {                                     // освещённость сферы (Ламберт)
                let dz = sqrt(1 - d2)
                v = max(0, dx * light.x + dy * light.y + dz * light.z)
                v = 0.06 + 0.94 * pow(v, 1.3)               // чуть-чуть точек и на теневой стороне
            }
            if v > 0.02 {
                let rad = step * 0.46 * sqrt(v)
                let t = min(1, max(0, (dx + 1) / 2))
                ctx.setFillColor(rgb(mix(a, b, t), 0.9))
                ctx.fillEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
            }
            x += step
        }
        y += step
    }
    return bloom(ctx.makeImage()!, near: 3, far: 26, strength: 0.4)
}
