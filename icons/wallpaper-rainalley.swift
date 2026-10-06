// Обои «Переулок под дождём»: узкая токийская улочка в перспективе, неоновые вывески (без читаемого текста),
// мокрый асфальт с отражениями, торговый автомат, провода над головой и дождь. Днём неон тусклее,
// улица серая; ночью всё светится. Собирается через wall (с wallpaper-kit.swift).

func alleyKeys(_ hour: CGFloat) -> (sky: Int, wall: Int, neon: CGFloat) {
    let keys: [(CGFloat, Int, Int, CGFloat)] = [
        (0, 0x0a0b16, 0x0d0e16, 1.0), (5, 0x151830, 0x12131c, 0.85), (8, 0x6a707e, 0x3a3c44, 0.25),
        (14, 0x7a808c, 0x44464e, 0.2), (17, 0x4a4c66, 0x2a2b36, 0.5), (19, 0x1e1f3a, 0x16171f, 0.9), (24, 0x0a0b16, 0x0d0e16, 1.0)]
    for i in 0..<keys.count - 1 where hour >= keys[i].0 && hour <= keys[i + 1].0 {
        let t = (hour - keys[i].0) / (keys[i + 1].0 - keys[i].0)
        return (mix(keys[i].1, keys[i + 1].1, t), mix(keys[i].2, keys[i + 1].2, t), lerp(keys[i].3, keys[i + 1].3, t))
    }
    return (keys[0].1, keys[0].2, keys[0].3)
}

let neonColors = [0xff3d8b, 0x2ee6ff, 0xffb02e, 0xff4a3a, 0xa86bff, 0x3dff9e]

runWallpaper { hour in
    let ctx = canvas()
    let (skyC, wallC, neon) = alleyKeys(hour)
    var rng = Rng(seed: 0xA11E)
    // перспектива: в конце улицы — светлый проём
    let farL = W * 0.44, farR = W * 0.56, farB = H * 0.36, farT = H * 0.64
    func wallX(_ side: CGFloat, _ t: CGFloat) -> CGFloat { side < 0 ? lerp(-W * 0.02, farL, t) : lerp(W * 1.02, farR, t) }
    func wallBottom(_ t: CGFloat) -> CGFloat { lerp(0, farB, t) }
    func wallTop(_ t: CGFloat) -> CGFloat { lerp(H * 1.3, farT, t) }

    // небо и проём в конце улицы
    ctx.setFillColor(rgb(skyC)); ctx.fill(extent)
    let glow = mix(skyC, 0xffc8a0, 0.25 + neon * 0.15)
    radialGlow(ctx, CGPoint(x: W * 0.5, y: H * 0.45), W * 0.25, glow, 0.6)

    // стены: тёмные, к проёму светлее (туман)
    for side in [-1.0, 1.0] as [CGFloat] {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: wallX(side, 0), y: wallBottom(0))); p.addLine(to: CGPoint(x: wallX(side, 1), y: wallBottom(1)))
        p.addLine(to: CGPoint(x: wallX(side, 1), y: wallTop(1))); p.addLine(to: CGPoint(x: wallX(side, 0), y: wallTop(0))); p.closeSubpath()
        ctx.saveGState(); ctx.addPath(p); ctx.clip()
        let g = CGGradient(colorsSpace: cs, colors: [rgb(mix(wallC, 0x000000, 0.55)), rgb(mix(wallC, glow, 0.14))] as CFArray, locations: [0, 1])!
        ctx.drawLinearGradient(g, start: CGPoint(x: wallX(side, 0), y: 0), end: CGPoint(x: wallX(side, 1), y: 0), options: [])
        // окна и этажи в перспективе
        for t in stride(from: 0.05, to: 0.95, by: 0.06) as StrideTo<CGFloat> {
            let x = wallX(side, t), x2 = wallX(side, t + 0.035), b = wallBottom(t), top = wallTop(t)
            var y = b + (top - b) * 0.3
            while y < top {
                if rng.next() < 0.18 {
                    let lit = rng.next() < 0.45
                    ctx.setFillColor(rgb(lit ? 0xffcf9a : mix(wallC, 0x000000, 0.4), lit ? 0.2 + neon * 0.3 : 0.6))
                    ctx.fill(CGRect(x: min(x, x2), y: y, width: abs(x2 - x) * 0.6, height: (top - b) * 0.025))
                }
                y += (top - b) * 0.09
            }
        }
        ctx.restoreGState()
    }
    // асфальт
    let ground = CGMutablePath()
    ground.move(to: CGPoint(x: -W * 0.02, y: 0)); ground.addLine(to: CGPoint(x: W * 1.02, y: 0)); ground.addLine(to: CGPoint(x: farR, y: farB)); ground.addLine(to: CGPoint(x: farL, y: farB)); ground.closeSubpath()
    ctx.saveGState(); ctx.addPath(ground); ctx.clip()                       // мокрый асфальт отражает свет из проёма
    let wet = CGGradient(colorsSpace: cs, colors: [rgb(mix(wallC, 0x000000, 0.45)), rgb(mix(wallC, 0x000000, 0.6)), rgb(mix(wallC, glow, 0.3))] as CFArray, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(wet, start: .zero, end: CGPoint(x: 0, y: farB), options: [])
    ctx.restoreGState()
    soften(ctx, 1.5)

    // вывески: вертикальные коробки, торчат из стен; свет и отражение на мокром асфальте
    var reflections: [(CGFloat, CGFloat, CGFloat, Int)] = []      // x, верх отражения, ширина, цвет
    for (i, t) in ([0.08, 0.2, 0.33, 0.47, 0.6, 0.72, 0.82] as [CGFloat]).enumerated() {
        for side in [-1.0, 1.0] as [CGFloat] {
            if rng.next() < 0.25 { continue }
            let k = 1 - t * 0.85, c = neonColors[(i * 2 + (side < 0 ? 0 : 1) + Int(rng.next() * 3)) % neonColors.count]
            let x = wallX(side, t) - side * 60 * S * k, b = wallBottom(t), top = wallTop(t)
            let w = 46 * S * k, h = (top - b) * (0.22 + rng.next() * 0.12), y = b + (top - b) * (0.28 + rng.next() * 0.25)
            let on = neon * (rng.next() < 0.15 ? 0.3 : 1)                            // одна-две «мигают»
            radialGlow(ctx, CGPoint(x: x, y: y + h / 2), h * 0.9, c, 0.3 * on)
            ctx.setStrokeColor(rgb(0x050508)); ctx.setLineWidth(max(1, 4 * S * k))                       // кронштейн к стене
            for by in [y + h * 0.15, y + h * 0.85] { ctx.move(to: CGPoint(x: wallX(side, t), y: by)); ctx.addLine(to: CGPoint(x: x, y: by)); ctx.strokePath() }
            ctx.setFillColor(rgb(mix(0x0a0a10, c, 0.15 + on * 0.25))); ctx.fill(CGRect(x: x - w / 2, y: y, width: w, height: h))
            ctx.setStrokeColor(rgb(c, 0.4 + on * 0.6)); ctx.setLineWidth(max(1, 3 * S * k)); ctx.stroke(CGRect(x: x - w / 2, y: y, width: w, height: h))
            // знаки-иероглифы: абстрактные штрихи, не текст
            ctx.setFillColor(rgb(mix(c, 0xffffff, 0.4), 0.3 + on * 0.7))
            var gy = y + h - w * 0.9
            while gy > y + w * 0.2 {
                for _ in 0..<3 {
                    let horizontal = rng.next() < 0.5
                    ctx.fill(horizontal ? CGRect(x: x - w * 0.3, y: gy + rng.next() * w * 0.5, width: w * 0.6, height: max(1, w * 0.08))
                                        : CGRect(x: x - w * 0.3 + rng.next() * w * 0.5, y: gy, width: max(1, w * 0.08), height: w * 0.6))
                }
                gy -= w * 0.95
            }
            reflections.append((x, b * 0.9, w * 1.6, c))
        }
    }
    // торговый автомат слева, ближе к зрителю
    let vm = CGRect(x: W * 0.13, y: wallBottom(0.18), width: 150 * S, height: 300 * S)
    radialGlow(ctx, CGPoint(x: vm.midX, y: vm.midY), 380 * S, 0xbfe8ff, 0.3)
    ctx.setFillColor(rgb(0x9fc0d4, 0.7)); ctx.fill(vm)
    ctx.setFillColor(rgb(0x2b4f8a)); ctx.fill(CGRect(x: vm.minX + 12 * S, y: vm.minY + vm.height * 0.45, width: vm.width - 24 * S, height: vm.height * 0.45))
    for r in 0..<3 { for c in 0..<4 {
        ctx.setFillColor(rgb(neonColors[(r + c) % neonColors.count], 0.8))
        ctx.fill(CGRect(x: vm.minX + 20 * S + CGFloat(c) * 30 * S, y: vm.minY + vm.height * 0.5 + CGFloat(r) * 40 * S, width: 18 * S, height: 28 * S))
    } }
    reflections.append((vm.midX, vm.minY, vm.width, 0xbfe8ff))

    // отражения на мокром асфальте: вертикальные размытые полосы под источниками
    ctx.draw(blurLayer(9) { l in
        for (x, top, w, c) in reflections {
            let g = CGGradient(colorsSpace: cs, colors: [rgb(c, 0), rgb(c, 0.55 * max(neon, 0.3))] as CFArray, locations: [0, 1])!
            l.saveGState(); l.clip(to: CGRect(x: x - w / 2, y: max(0, top - H * 0.3), width: w, height: min(top, H * 0.3)))
            l.drawLinearGradient(g, start: CGPoint(x: 0, y: max(0, top - H * 0.3)), end: CGPoint(x: 0, y: top), options: [])
            l.restoreGState()
        }
    }, in: extent)

    // провода над улицей
    let wireC = 0x050508
    for i in 0..<7 {
        let t1 = rng.next() * 0.6, t2 = rng.next() * 0.6
        wire(ctx, CGPoint(x: wallX(-1, t1), y: lerp(wallTop(t1), wallBottom(t1), 0.25 + rng.next() * 0.15)),
             CGPoint(x: wallX(1, t2), y: lerp(wallTop(t2), wallBottom(t2), 0.25 + rng.next() * 0.15)), sag: H * (0.03 + rng.next() * 0.05), wireC, 0.9, CGFloat(1.5 + Double(i % 3)))
    }
    // туман в глубине и дождь
    radialGlow(ctx, CGPoint(x: W * 0.5, y: H * 0.48), W * 0.12, glow, 0.35)
    for (count, len, alpha, blur) in [(1600, 24.0, 0.2, 0.6), (220, 80.0, 0.25, 2.5)] as [(Int, CGFloat, CGFloat, CGFloat)] {
        ctx.draw(blurLayer(blur) { l in
            var r2 = Rng(seed: UInt64(count) + 3)
            l.setLineCap(.round); l.setLineWidth(1.3 * S)
            for _ in 0..<count {
                let x = r2.next() * W * 1.1, y = r2.next() * H, ln = len * S * (0.6 + r2.next() * 0.8)
                l.setStrokeColor(rgb(0xd8dcf0, alpha * (0.4 + r2.next() * 0.6)))
                l.move(to: CGPoint(x: x, y: y)); l.addLine(to: CGPoint(x: x - ln * 0.12, y: y - ln)); l.strokePath()
            }
        }, in: extent)
    }
    return filmic(bloom(ctx.makeImage()!, near: 8, far: 50, strength: 1.0), grain: 0.05, vignette: 0.55)
}
