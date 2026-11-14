import AppKit
import Darwin
import Foundation

@MainActor
enum LegacyPreferencesMigration {
    private static let legacyBundleID = "com.aviwadhwa.SpotifyLyricsInMenubar"
    private static let newBundleID = "com.navel7.LyricRise"
    private static let decisionKey = "legacyPreferencesMigrationDecisionMade"
    private static let fileName = "\(legacyBundleID).plist"
    private static var setupWindow: NSWindow?

    static func prepareForLaunch() async {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: decisionKey) else { return }

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        let setupWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 220),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        setupWindow.title = "LyricRise"
        setupWindow.center()
        self.setupWindow = setupWindow
        setupWindow.makeKeyAndOrderFront(nil)
        defer {
            // Keep the sheet's parent alive while AppKit finishes dismissing it.
            setupWindow.orderOut(nil)
            NSApp.setActivationPolicy(.accessory)
        }

        while true {
            let choice = NSAlert()
            choice.messageText = String(localized: "Import settings from Lyric Fever?")
            choice.informativeText = String(localized: "To keep your settings, select the old preferences file: com.aviwadhwa.SpotifyLyricsInMenubar.plist. You can also start with new settings.")
            choice.addButton(withTitle: String(localized: "Import Settings"))
            choice.addButton(withTitle: String(localized: "Start Fresh"))

            let choiceResponse: NSApplication.ModalResponse = await withCheckedContinuation { (continuation: CheckedContinuation<NSApplication.ModalResponse, Never>) in
                choice.beginSheetModal(for: setupWindow, completionHandler: { response in
                    continuation.resume(returning: response)
                })
            }
            if choiceResponse == .alertSecondButtonReturn {
                defaults.set(true, forKey: decisionKey)
                break
            }

            let panel = NSOpenPanel()
            panel.title = String(localized: "Select Lyric Fever Settings")
            panel.message = String(localized: "Select com.aviwadhwa.SpotifyLyricsInMenubar.plist")
            panel.prompt = String(localized: "Import")
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowsMultipleSelection = false
            panel.showsHiddenFiles = true

            if let home = getpwuid(getuid()).map({ String(cString: $0.pointee.pw_dir) }) {
                panel.directoryURL = URL(fileURLWithPath: home)
                    .appending(path: "Library/Containers/\(legacyBundleID)/Data/Library/Preferences", directoryHint: .isDirectory)
            }

            let panelResponse: NSApplication.ModalResponse = await withCheckedContinuation { (continuation: CheckedContinuation<NSApplication.ModalResponse, Never>) in
                panel.beginSheetModal(for: setupWindow, completionHandler: { response in
                    continuation.resume(returning: response)
                })
            }
            guard panelResponse == .OK, let url = panel.url else { continue }

            do {
                guard url.lastPathComponent == fileName else {
                    throw MigrationError.wrongFile
                }
                let data = try Data(contentsOf: url)
                guard let preferences = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
                    throw MigrationError.invalidFile
                }

                let existing = defaults.persistentDomain(forName: newBundleID) ?? [:]
                for (key, value) in preferences where existing[key] == nil && key != decisionKey {
                    defaults.set(value, forKey: key)
                }
                defaults.set(true, forKey: decisionKey)
                break
            } catch {
                let failure = NSAlert()
                failure.alertStyle = .warning
                failure.messageText = String(localized: "Could not import settings")
                failure.informativeText = error.localizedDescription
                failure.addButton(withTitle: String(localized: "Try Again"))
                failure.addButton(withTitle: String(localized: "Start Fresh"))
                let failureResponse: NSApplication.ModalResponse = await withCheckedContinuation { (continuation: CheckedContinuation<NSApplication.ModalResponse, Never>) in
                    failure.beginSheetModal(for: setupWindow, completionHandler: { response in
                        continuation.resume(returning: response)
                    })
                }
                if failureResponse == .alertSecondButtonReturn {
                    defaults.set(true, forKey: decisionKey)
                    break
                }
            }
        }

    }

    private enum MigrationError: LocalizedError {
        case wrongFile
        case invalidFile

        var errorDescription: String? {
            switch self {
            case .wrongFile:
                String(localized: "Choose com.aviwadhwa.SpotifyLyricsInMenubar.plist.")
            case .invalidFile:
                String(localized: "The selected file is not a valid settings file.")
            }
        }
    }
}
