// Обои «Изо»: изометрические кубы-кварталы, верх граней светится, свет за сутки меняет цвет.
// Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let s = 70 * S                                   // размер куба
    let dx = s * cos(.pi / 6), dy = s * 0.5
    var r = Rng(seed: 0x150)
    let origin = CGPoint(x: W * 0.64, y: H * 0.70)
    // рисуем от дальних к ближним, чтобы ближние перекрывали
    for sum in 0..<22 { for i in 0...sum {
        let j = sum - i
        let h = Int(pow(r.next(), 2.5) * 6)          // высота башни
        let edge = exp(-pow((CGFloat(i - j)) / 7, 2))  // выше в середине «города»
        guard r.next() < 0.85 * edge + 0.1 else { continue }
        let base = CGPoint(x: origin.x + CGFloat(i - j) * dx, y: origin.y - CGFloat(i + j) * dy)
        let tall = CGFloat(max(1, Int(CGFloat(h) * edge))) * s * 0.8
        let top = CGPoint(x: base.x, y: base.y + tall)
        func poly(_ p: [CGPoint], _ c: CGColor) { let path = CGMutablePath(); path.addLines(between: p); path.closeSubpath(); ctx.addPath(path); ctx.setFillColor(c); ctx.fillPath() }
        let fade = max(0, 1 - CGFloat(sum) / 26)
        poly([CGPoint(x: base.x - dx, y: base.y), base, CGPoint(x: base.x, y: base.y - dy * 2 + dy), top, CGPoint(x: top.x - dx, y: top.y)].map { $0 },
             rgb(mix(0x050507, a, 0.18 * fade)))       // левая грань
        poly([base, CGPoint(x: base.x + dx, y: base.y), CGPoint(x: top.x + dx, y: top.y), top], rgb(mix(0x050507, b, 0.28 * fade)))   // правая
        poly([top, CGPoint(x: top.x + dx, y: top.y + dy), CGPoint(x: top.x, y: top.y + 2 * dy), CGPoint(x: top.x - dx, y: top.y + dy)],
             rgb(mix(0x050507, mix(a, b, 0.5), 0.75 * fade)))   // крыша светится
    } }
    return bloom(ctx.makeImage()!, near: 4, far: 30, strength: 0.5)
}
