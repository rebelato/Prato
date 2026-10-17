import Foundation

/// Nutrients of a food or a portion, before any rounding.
public struct Macros: Hashable, Sendable {
    public var kcal: Double
    /// Grams of protein.
    public var protein: Double
    /// Grams of carbohydrate.
    public var carbs: Double
    /// Grams of fat.
    public var fat: Double

    public init(kcal: Double, protein: Double, carbs: Double, fat: Double) {
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}

/// A food from the nutrition base, with its values per 100 g as eaten.
public struct Food: Identifiable, Hashable, Sendable {
    public let id: String
    public let namePT: String
    public let nameEN: String
    public let per100g: Macros

    public init(id: String, namePT: String, nameEN: String, per100g: Macros) {
        self.id = id
        self.namePT = namePT
        self.nameEN = nameEN
        self.per100g = per100g
    }

    /// The food's name in the user's language: Portuguese for `pt`, English otherwise.
    public func name(in locale: Locale = .current) -> String {
        locale.language.languageCode?.identifier == "pt" ? namePT : nameEN
    }
}
