// Обои «Хромовые кабели»: пучок тонких трубок течёт волной через экран, как жгут проводов.
// Рендер — chromeScene в wallpaper-kit.swift. Собирается через wall.

// семь трубок с общим изгибом, каждая чуть сдвинута и своей толщины
let tubes: [Tube] = (0..<7).map { i -> Tube in
    let k = CGFloat(i), dy = (k - 3) * 0.045, bend = (k - 3) * 0.02
    return ([-0.10, 0.30 + dy, 0.35, 0.95 + dy + bend, 0.62, -0.05 + dy - bend, 1.10, 0.62 + dy],
            [0.016, 0.022, 0.014, 0.028, 0.018, 0.024, 0.015][i])
}
let masks = tubes.map { ribbonMask($0.0, $0.1) }

runWallpaper { hour in chromeScene(hour, tubes, masks) }
