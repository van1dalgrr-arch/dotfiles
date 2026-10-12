// Обои «Хромовая арка»: одна очень толстая трубка аркой крупным планом, поверх — тонкая по диагонали.
// Рендер — chromeScene в wallpaper-kit.swift. Собирается через wall.

let tubes: [Tube] = [
    ([-0.12, -0.02, 0.28, 0.88, 0.72, 0.88, 1.12, -0.02], 0.15),
    ([0.08, 1.10, 0.30, 0.55, 0.62, 0.25, 1.10, 0.18], 0.02),
]
let masks = tubes.map { ribbonMask($0.0, $0.1) }

runWallpaper { hour in chromeScene(hour, tubes, masks) }
