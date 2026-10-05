// ============================================================
//   HTML → PNG встроенным в macOS WebKit (вместо headless Chrome — без лишних браузеров).
//     swift html2png.swift <страница.html> <выход.png> [ширина высота]
//   Шрифты — системные и установленные (JetBrainsMono Nerd Font и т.п.), картинка в 2×.
//   Используется zed/tools/preview.py и для картинок в docs/.
// ============================================================
import AppKit
import WebKit

let args = CommandLine.arguments
guard args.count >= 3 else { print("swift html2png.swift <in.html> <out.png> [w h]"); exit(2) }
let input = URL(fileURLWithPath: args[1]), output = URL(fileURLWithPath: args[2])
let width = args.count > 3 ? Double(args[3])! : 1600, height = args.count > 4 ? Double(args[4])! : 1000

final class Shooter: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // дать догрузиться картинкам и шрифтам
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let config = WKSnapshotConfiguration()
            config.rect = CGRect(x: 0, y: 0, width: width, height: height)
            webView.takeSnapshot(with: config) { image, error in
                guard let image, let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
                      let png = rep.representation(using: .png, properties: [:]) else {
                    print("не получилось: \(error?.localizedDescription ?? "?")"); exit(1)
                }
                try! png.write(to: output)
                exit(0)
            }
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { print(error); exit(1) }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)                 // без иконки в Dock и окон
let web = WKWebView(frame: NSRect(x: 0, y: 0, width: width, height: height))
let shooter = Shooter()
web.navigationDelegate = shooter
web.loadFileURL(input, allowingReadAccessTo: URL(fileURLWithPath: "/"))
DispatchQueue.main.asyncAfter(deadline: .now() + 30) { print("таймаут"); exit(1) }
app.run()
