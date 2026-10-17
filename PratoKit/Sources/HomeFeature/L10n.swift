import Foundation
import MealKit

/// Texts of Hoje, read from this module's `Localizable.xcstrings`.
///
/// Keys are semantic (`home.title`), so rewording the Portuguese never breaks the English.
/// The default value is the pt-BR text, the development language.
enum L10n {
    enum Home {
        static var eyebrow: String {
            String(localized: "home.eyebrow", defaultValue: "Seu diário alimentar", bundle: .module, comment: "Small label above the title on Hoje")
        }
        static var title: String {
            String(localized: "home.title", defaultValue: "Uma foto.\nSeu prato, mais claro.", bundle: .module, comment: "Main title on Hoje, two lines")
        }
        static var subtitle: String {
            String(localized: "home.subtitle", defaultValue: "Entenda o que você come, uma refeição de cada vez.", bundle: .module, comment: "Text under the main title on Hoje")
        }
    }

    enum ScanCard {
        static var title: String {
            String(localized: "home.scanCard.title", defaultValue: "O que tem no prato?", bundle: .module, comment: "Title of the card that starts a scan")
        }
        static var subtitle: String {
            String(localized: "home.scanCard.subtitle", defaultValue: "Fotografe, confira e registre. Você ajusta as porções.", bundle: .module, comment: "How scanning works, on the scan card")
        }
        static var scanButton: String {
            String(localized: "home.scanCard.scanButton", defaultValue: "Escanear refeição", bundle: .module, comment: "Button that opens the camera")
        }
        static var galleryButton: String {
            String(localized: "home.galleryButton", defaultValue: "Escolher da galeria", bundle: .module, comment: "Button that picks a meal photo from the photo library")
        }
    }

    enum Today {
        static var title: String {
            String(localized: "home.today.title", defaultValue: "Hoje", bundle: .module, comment: "Section with today's meals")
        }
        static var emptyTitle: String {
            String(localized: "home.today.empty.title", defaultValue: "Nenhuma refeição registrada", bundle: .module, comment: "Today has no meals yet")
        }
        static var emptySubtitle: String {
            String(localized: "home.today.empty.subtitle", defaultValue: "Seu próximo prato começa por aqui.", bundle: .module, comment: "Encouragement under the empty state")
        }
        static func mealCount(_ count: Int) -> String {
            String(localized: "home.today.mealCount", defaultValue: "\(count) refeições", bundle: .module, comment: "How many meals were logged today; plural by the number")
        }
    }

    static func mealKind(_ kind: MealKind) -> String {
        switch kind {
        case .breakfast:
            String(localized: "mealKind.breakfast", defaultValue: "Café da manhã", bundle: .module, comment: "Meal type")
        case .lunch:
            String(localized: "mealKind.lunch", defaultValue: "Almoço", bundle: .module, comment: "Meal type")
        case .snack:
            String(localized: "mealKind.snack", defaultValue: "Lanche", bundle: .module, comment: "Meal type")
        case .dinner:
            String(localized: "mealKind.dinner", defaultValue: "Jantar", bundle: .module, comment: "Meal type")
        }
    }
}
