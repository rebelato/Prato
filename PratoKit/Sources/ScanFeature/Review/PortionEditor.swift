import Foundation
import MealKit

/// The food and weight being edited in the "Ajustar alimento" sheet.
public struct PortionEditor: Identifiable, Hashable, Sendable {

    public enum Mode: Hashable, Sendable {
        /// "Adicionar alimento": a new item.
        case add
        /// "Ajustar alimento": changes the portion with this id.
        case edit(FoodPortion.ID)
    }

    /// Largest weight accepted for one item.
    public static let maxGrams = 2000

    public let id: UUID
    public let mode: Mode
    public var food: Food
    public var grams: Int {
        didSet { grams = min(max(grams, 0), Self.maxGrams) }
    }
    /// When adding a food the analysis couldn't match: which one it resolves.
    public let resolves: UnmatchedFood.ID?
    /// The recognized name, shown so the user knows what they're picking a food for.
    public let recognizedName: String?

    public init(
        mode: Mode,
        food: Food,
        grams: Int,
        resolves: UnmatchedFood.ID? = nil,
        recognizedName: String? = nil
    ) {
        self.id = UUID()
        self.mode = mode
        self.food = food
        self.grams = min(max(grams, 0), Self.maxGrams)
        self.resolves = resolves
        self.recognizedName = recognizedName
    }

    /// What the item will add to the meal with the current values.
    public var totals: NutritionTotals {
        NutritionTotals(food: food, grams: grams)
    }

    public var canApply: Bool {
        grams > 0
    }

    public mutating func adjustGrams(by delta: Int) {
        grams += delta
    }
}
