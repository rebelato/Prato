import Foundation

/// Texts of shared components, read from this module's `Localizable.xcstrings`.
enum DesignL10n {
    static var mealEstimate: String {
        String(localized: "macros.mealEstimate", defaultValue: "Estimativa da refeição", bundle: .module, comment: "Label at the top of a meal's calorie card")
    }
    static var kcal: String {
        String(localized: "macros.kcal", defaultValue: "kcal", bundle: .module, comment: "Unit after the calorie number")
    }
    static var protein: String {
        String(localized: "macros.protein", defaultValue: "Proteínas", bundle: .module, comment: "Protein macro label")
    }
    static var carbs: String {
        String(localized: "macros.carbs", defaultValue: "Carboidratos", bundle: .module, comment: "Carbohydrate macro label")
    }
    static var fat: String {
        String(localized: "macros.fat", defaultValue: "Gorduras", bundle: .module, comment: "Fat macro label")
    }
}
