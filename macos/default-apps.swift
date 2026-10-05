// Файлы кода открываются в Zed: swift default-apps.swift check|apply.
// macOS 26 молча менять не даёт — на каждое расширение спрашивает подтверждение на экране.
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
