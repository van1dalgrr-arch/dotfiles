// Обои «Код»: приглушённый Go-код (обработчик на Gin) с подсветкой синтаксиса справа,
// светящаяся строка-курсор медленно ползёт вниз за сутки. Собирается через wall (с wallpaper-kit.swift).

let goCode = """
package handler

import (
    "net/http"

    "github.com/gin-gonic/gin"
)

// Create сохраняет запись лога и возвращает её id
func (h *LogHandler) Create(c *gin.Context) {
    var req CreateLogRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    id, err := h.service.Create(c.Request.Context(), req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal"})
        return
    }
    c.JSON(http.StatusCreated, gin.H{"id": id})
}

// GetByID отдаёт запись по id
func (h *LogHandler) GetByID(c *gin.Context) {
    id := c.Param("id")
    entry, err := h.service.Get(c.Request.Context(), id)
    if errors.Is(err, ErrNotFound) {
        c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
        return
    }
    c.JSON(http.StatusOK, entry)
}
"""

let keywords: Set<String> = ["package", "import", "func", "var", "if", "return", "err", "nil", "range", "for", "type", "struct", "go", "defer"]

runWallpaper { hour in
    let ctx = canvas()
    let (a, b) = tint(hour)
    let font = NSFont(name: "JetBrainsMono Nerd Font", size: 19 * S)!
    let lineH = 34 * S, x0 = W * 0.50, y0 = H * 0.86
    let lines = goCode.components(separatedBy: "\n")
    let cursorLine = Int(hour / 24 * CGFloat(lines.count))

    // светящаяся строка-курсор
    let cy = y0 - CGFloat(cursorLine) * lineH
    let bar = CGGradient(colorsSpace: cs, colors: [rgb(a, 0), rgb(a, 0.14), rgb(a, 0)] as CFArray, locations: [0, 0.3, 1])!
    ctx.saveGState(); ctx.clip(to: CGRect(x: x0 - 40 * S, y: cy - 10 * S, width: W, height: lineH))
    ctx.drawLinearGradient(bar, start: CGPoint(x: x0 - 40 * S, y: 0), end: CGPoint(x: W, y: 0), options: [])
    ctx.restoreGState()

    for (i, line) in lines.enumerated() {
        let y = y0 - CGFloat(i) * lineH
        let near = i == cursorLine
        let dim: CGFloat = near ? 0.95 : 0.40
        let attr = NSMutableAttributedString()
        func add(_ s: String, _ c: Int, _ alpha: CGFloat = 1) {
            attr.append(NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: NSColor(cgColor: rgb(c, alpha * dim))!]))
        }
        if line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
            add(line, 0x8a8f9c, 0.8)
        } else {
            // простая подсветка: строки, ключевые слова, вызовы функций
            let scanner = Array(line)
            var i = 0
            while i < scanner.count {
                let ch = scanner[i]
                if ch == "\"" {
                    var j = i + 1; while j < scanner.count && scanner[j] != "\"" { j += 1 }
                    add(String(scanner[i...min(j, scanner.count - 1)]), 0xeab308); i = j + 1
                } else if ch.isLetter || ch == "_" {
                    var j = i; while j < scanner.count && (scanner[j].isLetter || scanner[j].isNumber || scanner[j] == "_") { j += 1 }
                    let word = String(scanner[i..<j])
                    let isCall = j < scanner.count && scanner[j] == "("
                    add(word, keywords.contains(word) ? violet : (isCall ? blue : (word.first!.isUppercase ? pink : 0xd6d9e8)))
                    i = j
                } else {
                    add(String(ch), 0x7c82a0); i += 1
                }
            }
        }
        let ctl = CTLineCreateWithAttributedString(attr)
        ctx.textPosition = CGPoint(x: x0, y: y)
        CTLineDraw(ctl, ctx)
    }
    // код растворяется вниз
    let fadeL = CGGradient(colorsSpace: cs, colors: [rgb(0x050507, 1), rgb(0x050507, 0)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(fadeL, start: CGPoint(x: 0, y: H * 0.05), end: CGPoint(x: 0, y: H * 0.40), options: [])
    _ = b
    return bloom(ctx.makeImage()!, near: 3, far: 26, strength: 0.5)
}
