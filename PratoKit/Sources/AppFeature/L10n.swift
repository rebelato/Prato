import Foundation

/// Texts of the tab bar, read from this module's `Localizable.xcstrings`.
enum L10n {
    enum Tab {
        static var today: String {
            String(localized: "tab.today", defaultValue: "Hoje", bundle: .module, comment: "Tab bar item for today's diary")
        }
        static var scan: String {
            String(localized: "tab.scan", defaultValue: "Escanear", bundle: .module, comment: "Tab bar item that opens the camera")
        }
        static var history: String {
            String(localized: "tab.history", defaultValue: "Histórico", bundle: .module, comment: "Tab bar item for past meals")
        }
    }
}
