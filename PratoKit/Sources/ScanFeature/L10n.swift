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
        static var cloudNotice: String {
            String(localized: "confirm.cloudNotice", defaultValue: "Ao analisar, a foto é enviada ao Gemini, do Google, só para identificar os alimentos. O Prato não guarda a foto na nuvem.", bundle: .module, comment: "Tells the user the photo leaves the device when analyzed")
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
        static var noFoodTitle: String {
            String(localized: "analyzing.noFood.title", defaultValue: "Não encontramos comida nesta foto.", bundle: .module, comment: "The analysis found no food in the photo")
        }
        static var noFoodMessage: String {
            String(localized: "analyzing.noFood.message", defaultValue: "Tire outra foto com o prato inteiro visível ou registre os alimentos você mesmo.", bundle: .module, comment: "What to do when no food was found")
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
        static var demonstrationValues: String {
            String(localized: "review.demonstrationValues", defaultValue: "Os valores nutricionais desta versão são de demonstração.", bundle: .module, comment: "The nutrition values come from demonstration data, not an official table")
        }
        static var toConfirmTitle: String {
            String(localized: "review.toConfirm.title", defaultValue: "Confirme estes alimentos", bundle: .module, comment: "Section with foods the analysis couldn't match")
        }
        static var toConfirmSubtitle: String {
            String(localized: "review.toConfirm.subtitle", defaultValue: "Não encontramos uma correspondência segura. Toque para escolher o alimento.", bundle: .module, comment: "How to resolve the foods to confirm")
        }
        static var notInCatalog: String {
            String(localized: "review.toConfirm.notInCatalog", defaultValue: "Não está no catálogo. Toque para escolher.", bundle: .module, comment: "A recognized food with no catalog match")
        }
        static func looksLike(_ food: String) -> String {
            String(localized: "review.toConfirm.looksLike", defaultValue: "Parece: \(food). Toque para confirmar.", bundle: .module, comment: "A close catalog food the user should confirm; the argument is its name")
        }
        static func couldBe(_ foods: String) -> String {
            String(localized: "review.toConfirm.couldBe", defaultValue: "Pode ser: \(foods). Toque para escolher.", bundle: .module, comment: "Alternatives from the analysis; the argument is a list of names")
        }
        static func dismissUnmatched(_ name: String) -> String {
            String(localized: "review.toConfirm.dismiss", defaultValue: "Descartar \(name)", bundle: .module, comment: "Accessibility label of the button that drops a food to confirm")
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
        static var saveFailed: String {
            String(localized: "review.saveFailed", defaultValue: "Não foi possível salvar a refeição. Tente de novo.", bundle: .module, comment: "Saving the meal failed")
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
        static func recognizedAs(_ name: String) -> String {
            String(localized: "editor.recognizedAs", defaultValue: "Reconhecido na foto como “\(name)”.", bundle: .module, comment: "Which recognized food the user is picking a catalog food for; the argument is its name")
        }
        static var chooseFood: String {
            String(localized: "editor.chooseFood", defaultValue: "Escolher alimento", bundle: .module, comment: "Food field before a food is chosen; opens the food list")
        }
        static func couldBe(_ foods: String) -> String {
            String(localized: "editor.couldBe", defaultValue: "Também pode ser: \(foods).", bundle: .module, comment: "Alternatives the analysis gave for the recognized food; the argument is a list of names")
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

    enum Picker {
        static var title: String {
            String(localized: "picker.title", defaultValue: "Escolher alimento", bundle: .module, comment: "Title of the searchable food list")
        }
        static var searchPrompt: String {
            String(localized: "picker.searchPrompt", defaultValue: "Buscar alimento", bundle: .module, comment: "Placeholder of the food search field")
        }
        static var similar: String {
            String(localized: "picker.similar", defaultValue: "Parecidos com o reconhecido", bundle: .module, comment: "Section of foods similar to the one recognized in the photo")
        }
        static var all: String {
            String(localized: "picker.all", defaultValue: "Todos os alimentos", bundle: .module, comment: "Section with the whole food catalog")
        }
        static var emptyTitle: String {
            String(localized: "picker.emptyTitle", defaultValue: "Nenhum alimento encontrado", bundle: .module, comment: "Shown when the search finds no food")
        }
        static var emptyHint: String {
            String(localized: "picker.emptyHint", defaultValue: "A base de alimentos ainda é pequena. Tente outro nome ou escolha o mais parecido.", bundle: .module, comment: "Explains why a search found nothing")
        }
        static func per100g(_ kcal: String) -> String {
            String(localized: "picker.per100g", defaultValue: "\(kcal) a cada 100 g", bundle: .module, comment: "Calories per 100 g of a food in the list; the argument is like '128 kcal'")
        }
    }

    enum Saved {
        static var eyebrow: String {
            String(localized: "saved.eyebrow", defaultValue: "Refeição registrada", bundle: .module, comment: "Small label above the confirmation title")
        }
        static func title(_ kind: MealKind) -> String {
            switch kind {
            case .breakfast:
                String(localized: "saved.title.breakfast", defaultValue: "Café da manhã salvo.", bundle: .module, comment: "Confirmation title after saving a breakfast")
            case .lunch:
                String(localized: "saved.title.lunch", defaultValue: "Almoço salvo.", bundle: .module, comment: "Confirmation title after saving a lunch")
            case .snack:
                String(localized: "saved.title.snack", defaultValue: "Lanche salvo.", bundle: .module, comment: "Confirmation title after saving a snack")
            case .dinner:
                String(localized: "saved.title.dinner", defaultValue: "Jantar salvo.", bundle: .module, comment: "Confirmation title after saving a dinner")
            }
        }
        static func loggedAt(_ time: String) -> String {
            String(localized: "saved.loggedAt", defaultValue: "Registrado às \(time).", bundle: .module, comment: "When the meal was logged; the argument is a time such as 12:30")
        }
        static var done: String {
            String(localized: "saved.done", defaultValue: "Voltar para hoje", bundle: .module, comment: "Closes the flow and shows today's diary")
        }
    }
}
