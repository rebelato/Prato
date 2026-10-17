import Foundation

/// Texts of the tab bar and the temporary screens, read from this module's `Localizable.xcstrings`.
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

    enum ScanPlaceholder {
        static var title: String {
            String(localized: "scan.placeholder.title", defaultValue: "Escanear refeição", bundle: .module, comment: "Title of the temporary scan screen")
        }
        static var subtitle: String {
            String(localized: "scan.placeholder.subtitle", defaultValue: "A câmera chega em breve.", bundle: .module, comment: "The scan flow is not built yet")
        }
        static var close: String {
            String(localized: "scan.placeholder.close", defaultValue: "Fechar", bundle: .module, comment: "Closes the temporary scan screen")
        }
    }

    enum HistoryPlaceholder {
        static var title: String {
            String(localized: "history.placeholder.title", defaultValue: "Histórico", bundle: .module, comment: "Title of the temporary history screen")
        }
        static var subtitle: String {
            String(localized: "history.placeholder.subtitle", defaultValue: "Em breve: seus registros, dia a dia.", bundle: .module, comment: "The history screen is not built yet")
        }
    }
}
