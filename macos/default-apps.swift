// ============================================================
//   Файлы для кода открываются в Zed (двойной клик в Finder, open файл).
//     swift default-apps.swift check   — что сейчас и что поменяется
//     swift default-apps.swift apply   — назначить Zed
//   Без duti. macOS 26 молча менять не даёт (старый LSSetDefaultRoleHandler игнорируется):
//   на каждое расширение показывается окно «Использовать Zed?» — нажать «Использовать».
//   Поэтому запускать, сидя за Mac. Не подтвердил за минуту — расширение пропускается.
//   Вызывается из macos.sh (группа apps).
// ============================================================
import AppKit
import UniformTypeIdentifiers

let editor = "dev.zed.Zed"
let extensions = ["go", "mod", "sum", "md", "json", "jsonc", "yaml", "yml", "toml", "env", "sh", "zsh", "bash",
                  "sql", "proto", "txt", "log", "ini", "conf", "csv", "py", "js", "ts", "lua", "swift", "glsl"]

guard let zed = NSWorkspace.shared.urlForApplication(withBundleIdentifier: editor) else {
    print("  Zed не установлен — пропускаю"); exit(0)
}
let apply = CommandLine.arguments.dropFirst().first == "apply"
var changed = 0

for ext in extensions {
    guard let type = UTType(filenameExtension: ext) else { continue }
    let current = NSWorkspace.shared.urlForApplication(toOpen: type)
    let name = current.map { FileManager.default.displayName(atPath: $0.path).replacingOccurrences(of: ".app", with: "") } ?? "—"
    if current?.standardizedFileURL == zed.standardizedFileURL { continue }
    changed += 1
    print(String(format: "  ~ .%-8@ %@ → Zed", ext as NSString, name as NSString))
    if apply {
        let done = DispatchSemaphore(value: 0)
        NSWorkspace.shared.setDefaultApplication(at: zed, toOpen: type) { error in
            if let error { print("    ↳ .\(ext): \(error.localizedDescription)") }
            done.signal()
        }
        if done.wait(timeout: .now() + 60) == .timedOut { print("    ↳ .\(ext): не подтверждено на экране — пропускаю") }
    }
}
