// Активировать Ghostty, не поднимая все его окна: только ключевое (выпадающий терминал).
// AppleScript-команда activate поднимает все окна приложения — обычное окно Ghostty вставало поверх
// текущего приложения, и казалось, что «перекинуло в Ghostty». Собирает ghostty/quick-terminal.sh.
import AppKit

if let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.mitchellh.ghostty").first {
    app.activate(options: [])
}
