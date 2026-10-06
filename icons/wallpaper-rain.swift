// Обои «Дождь»: ночной город через мокрое стекло — размытые огни (боке), капли и потёки.
// Цвет огней меняется за сутки. Собирается через wall (с wallpaper-kit.swift).

runWallpaper { hour in
    let (a, b) = tint(hour)

    // огни города: диски, гуще внизу, потом сильное размытие
    let lights = canvas()
    var r = Rng(seed: 0x4A1)
    for _ in 0..<55 {
        let x = r.next() * W, y = pow(r.next(), 1.6) * H * 0.75
        let rad = (18 + pow(r.next(), 2) * 80) * S
        let pick = r.next()
        let c = pick < 0.35 ? a : (pick < 0.7 ? b : (pick < 0.88 ? pink : orange))
        lights.setFillColor(rgb(c, 0.18 + r.next() * 0.35))
        lights.fillEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
    }
    let bokeh = blurred(lights.makeImage()!, 14 * S)
        .applyingFilter("CIColorMatrix", parameters: ["inputRVector": CIVector(x: 0.6, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: 0.6, z: 0, w: 0), "inputBVector": CIVector(x: 0, y: 0, z: 0.6, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)])
    let ctx = canvas()
    ctx.draw(ci.createCGImage(bokeh, from: extent)!, in: extent)

    // потёки дождя
    ctx.setLineCap(.round)
    for _ in 0..<420 {
        let x = r.next() * W, y = r.next() * H, len = (20 + r.next() * 70) * S
        ctx.setStrokeColor(rgb(0xffffff, 0.03 + r.next() * 0.08)); ctx.setLineWidth(max(0.8, (0.6 + r.next()) * S))
        ctx.move(to: CGPoint(x: x, y: y)); ctx.addLine(to: CGPoint(x: x - len * 0.12, y: y - len)); ctx.strokePath()
    }
    // капли на стекле: тёмное тело + блик сверху слева
    for _ in 0..<320 {
        let x = r.next() * W, y = r.next() * H, rad = (1.5 + pow(r.next(), 3) * 7) * S
        ctx.setFillColor(rgb(0x000000, 0.35))
        ctx.fillEllipse(in: CGRect(x: x - rad, y: y - rad * 1.15, width: rad * 2, height: rad * 2.3))
        ctx.setFillColor(rgb(0xffffff, 0.12 + r.next() * 0.2))
        ctx.fillEllipse(in: CGRect(x: x - rad * 0.55, y: y + rad * 0.2, width: rad * 0.6, height: rad * 0.6))
    }
    return ctx.makeImage()!
}
