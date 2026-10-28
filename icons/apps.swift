#!/usr/bin/env swift
// Готовые иконки приложений из icons/apps/*.png: swift apps.swift apply | reset.
// После обновления приложения иконка сбрасывается — снова apply. Root-приложениям (Telegram) нужен sudo.

import AppKit

let dir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().appendingPathComponent("apps").path

let apps: [(app: String, png: String)] = [
    ("/Applications/TablePro.app", "tablepro"),   // слон PostgreSQL
    ("/Applications/Telegram.app", "telegram"),   // родной голубой, без белой подложки
    ("/Applications/OrbStack.app", "orbstack"),   // Docker Desktop
    ("/Applications/Bruno.app",    "bruno"),      // Postman
]

let mode = CommandLine.arguments.dropFirst().first ?? ""
guard mode == "apply" || mode == "reset" else {
    print("usage: apps.swift apply | reset"); exit(1)
}
for (app, png) in apps {
    let name = (app as NSString).lastPathComponent
    guard FileManager.default.fileExists(atPath: app) else { print("нет: \(name)"); continue }
    let icon = mode == "apply" ? NSImage(contentsOfFile: "\(dir)/\(png).png") : nil
    if NSWorkspace.shared.setIcon(icon, forFile: app, options: []) {
        print(mode == "apply" ? "✓ \(name)" : "↺ \(name)")
    } else {
        print("✗ \(name) — не вышло: дай терминалу «Управление приложениями», для root-приложений ещё sudo")
    }
}
