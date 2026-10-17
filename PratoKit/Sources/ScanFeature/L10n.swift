import Foundation
import MealKit

/// Texts of the scan flow, read from this module's `Localizable.xcstrings`.
enum L10n {

    enum Common {
        static var close: String {
            String(localized: "common.close", defaultValue: "Fechar", bundle: .module, comment: "Closes the scan flow")
        }
        static var ok: String {
            String(localized: "common.ok", defaultValue: "OK", bundle: .module, comment: "Dismisses an alert")
        }
        static var done: String {
            String(localized: "common.done", defaultValue: "OK", bundle: .module, comment: "Hides the number keyboard")
        }
    }

    enum Capture {
        static var title: String {
            String(localized: "capture.title", defaultValue: "Enquadre seu prato", bundle: .module, comment: "Title of the camera screen")
        }
        static var subtitle: String {
            String(localized: "capture.subtitle", defaultValue: "Fotografe de cima, com boa luz e todos os alimentos visíveis.", bundle: .module, comment: "Tips for a good photo")
        }
        static var guide: String {
            String(localized: "capture.guide", defaultValue: "Mantenha o prato dentro do círculo", bundle: .module, comment: "Label over the camera preview")
        }
        static var gallery: String {
            String(localized: "capture.gallery", defaultValue: "Galeria", bundle: .module, comment: "Opens the photo library")
        }
        static var withoutPhoto: String {
            String(localized: "capture.withoutPhoto", defaultValue: "Sem foto", bundle: .module, comment: "Logs a meal without a photo")
        }
        static var shutter: String {
            String(localized: "capture.shutter", defaultValue: "Tirar foto", bundle: .module, comment: "Accessibility label of the shutter button")
        }
        static var unavailable: String {
            String(localized: "capture.unavailable", defaultValue: "Câmera indisponível neste aparelho. O botão usa uma foto de exemplo.", bundle: .module, comment: "Shown on devices without a camera, such as the Simulator")
        }
        static var deniedTitle: String {
            String(localized: "capture.denied.title", defaultValue: "Sem acesso à câmera", bundle: .module, comment: "Camera permission was denied")
        }
        static var deniedMessage: String {
            String(localized: "capture.denied.message", defaultValue: "Permita o acesso nos Ajustes ou escolha uma foto da galeria.", bundle: .module, comment: "How to continue without camera access")
        }
        static var openSettings: String {
            String(localized: "capture.denied.openSettings", defaultValue: "Abrir Ajustes", bundle: .module, comment: "Opens the app's page in Settings")
        }
        static var loadFailed: String {
            String(localized: "capture.loadFailed", defaultValue: "Não foi possível abrir essa foto.", bundle: .module, comment: "A photo from the library could not be read")
        }
    }

    enum Confirm {
        static var title: String {
            String(localized: "confirm.title", defaultValue: "Ficou tudo visível?", bundle: .module, comment: "Title of the photo check screen")
        }
        static var subtitle: String {
            String(localized: "confirm.subtitle", defaultValue: "Uma foto nítida ajuda a sugerir os alimentos do seu prato.", bundle: .module, comment: "Why the photo should be sharp")
        }
        static var analyze: String {
            String(localized: "confirm.analyze", defaultValue: "Analisar prato", bundle: .module, comment: "Starts the analysis of the photo")
        }
        static var retake: String {
            String(localized: "confirm.retake", defaultValue: "Tirar outra foto", bundle: .module, comment: "Goes back to the camera")
        }
    }

    enum Analyzing {
        static var title: String {
            String(localized: "analyzing.title", defaultValue: "Conhecendo seu prato…", bundle: .module, comment: "Title while the photo is analyzed")
        }
        static var status: String {
            String(localized: "analyzing.status", defaultValue: "Sugerindo alimentos e porções.", bundle: .module, comment: "What the analysis is doing")
        }
        static var hint: String {
            String(localized: "analyzing.hint", defaultValue: "Você poderá corrigir tudo a seguir.", bundle: .module, comment: "Reassures that suggestions can be edited")
        }
        static var failedTitle: String {
            String(localized: "analyzing.failed.title", defaultValue: "Não foi possível analisar a foto.", bundle: .module, comment: "The analysis failed")
        }
        static var failedMessage: String {
            String(localized: "analyzing.failed.message", defaultValue: "Tente de novo ou registre os alimentos você mesmo.", bundle: .module, comment: "Options after a failed analysis")
        }
        static var retry: String {
            String(localized: "analyzing.retry", defaultValue: "Tentar de novo", bundle: .module, comment: "Runs the analysis again")
        }
        static var manual: String {
            String(localized: "analyzing.manual", defaultValue: "Registrar sem análise", bundle: .module, comment: "Goes to the review with no suggested foods")
        }
    }

    enum Review {
        static var title: String {
            String(localized: "review.title", defaultValue: "Vamos conferir?", bundle: .module, comment: "Title of the review screen")
        }
        static var subtitle: String {
            String(localized: "review.subtitle", defaultValue: "Toque em um alimento para corrigir o nome ou ajustar o peso.", bundle: .module, comment: "How to edit the suggested foods")
        }
        static var mealKind: String {
            String(localized: "review.mealKind", defaultValue: "Refeição", bundle: .module, comment: "Label of the meal type picker")
        }
        static var disclaimer: String {
            String(localized: "review.disclaimer", defaultValue: "Valores estimados. Uma foto não mostra o peso exato nem óleo, molhos ou preparo.", bundle: .module, comment: "Why the values are estimates")
        }
        static var empty: String {
            String(localized: "review.empty", defaultValue: "Nenhum alimento na lista ainda. Adicione o que está no prato.", bundle: .module, comment: "The meal has no foods yet")
        }
        static var addFood: String {
            String(localized: "review.addFood", defaultValue: "Adicionar alimento", bundle: .module, comment: "Adds a food by hand")
        }
        static var save: String {
            String(localized: "review.save", defaultValue: "Salvar refeição", bundle: .module, comment: "Saves the reviewed meal")
        }
        static var itemHint: String {
            String(localized: "review.item.hint", defaultValue: "Toque para ajustar.", bundle: .module, comment: "Accessibility hint on a food row")
        }
        static func itemKcal(_ kcal: Int) -> String {
            String(localized: "review.item.kcal", defaultValue: "\(kcal) kcal · porção estimada", bundle: .module, comment: "Calories of one food; the argument is the number")
        }
    }

    enum Editor {
        static var adjustTitle: String {
            String(localized: "editor.adjustTitle", defaultValue: "Ajustar alimento", bundle: .module, comment: "Title of the sheet that edits a food")
        }
        static var addTitle: String {
            String(localized: "editor.addTitle", defaultValue: "Adicionar alimento", bundle: .module, comment: "Title of the sheet that adds a food")
        }
        static var cancel: String {
            String(localized: "editor.cancel", defaultValue: "Cancelar", bundle: .module, comment: "Closes the sheet without changes")
        }
        static var food: String {
            String(localized: "editor.food", defaultValue: "Alimento", bundle: .module, comment: "Label of the food picker")
        }
        static var weight: String {
            String(localized: "editor.weight", defaultValue: "Peso da porção em gramas", bundle: .module, comment: "Label of the weight field")
        }
        static var hint: String {
            String(localized: "editor.hint", defaultValue: "Use o peso pronto para consumo.", bundle: .module, comment: "Weigh food cooked, as eaten")
        }
        static var apply: String {
            String(localized: "editor.apply", defaultValue: "Aplicar ajuste", bundle: .module, comment: "Saves the edited food")
        }
        static var add: String {
            String(localized: "editor.add", defaultValue: "Adicionar", bundle: .module, comment: "Adds the new food to the meal")
        }
        static var remove: String {
            String(localized: "editor.remove", defaultValue: "Remover alimento", bundle: .module, comment: "Removes the food from the meal")
        }
        static func estimate(_ kcal: Int) -> String {
            String(localized: "editor.estimate", defaultValue: "Estimativa: \(kcal) kcal", bundle: .module, comment: "Live calorie estimate of the portion; the argument is the number")
        }
        static func step(_ grams: Int) -> String {
            grams > 0
                ? String(localized: "editor.step.add", defaultValue: "Mais \(grams) gramas", bundle: .module, comment: "Accessibility label of a button that adds grams")
                : String(localized: "editor.step.remove", defaultValue: "Menos \(-grams) gramas", bundle: .module, comment: "Accessibility label of a button that removes grams")
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
