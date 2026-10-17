import Foundation

/// Whole-number nutrients as the user sees them.
///
/// A meal's total is the sum of its items' shown values, never a recalculation from
/// the grams, so the numbers on screen always add up.
public struct NutritionTotals: Hashable, Sendable {
    public var kcal: Int
    public var protein: Int
    public var carbs: Int
    public var fat: Int

    public init(kcal: Int, protein: Int, carbs: Int, fat: Int) {
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }

    public static let zero = NutritionTotals(kcal: 0, protein: 0, carbs: 0, fat: 0)

    public static func + (lhs: Self, rhs: Self) -> Self {
        NutritionTotals(
            kcal: lhs.kcal + rhs.kcal,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat
        )
    }

    /// The shown values of `grams` of `food`, each rounded once.
    public init(food: Food, grams: Int) {
        let factor = Double(grams) / 100
        func rounded(_ value: Double) -> Int { Int((value * factor).rounded()) }
        self.init(
            kcal: rounded(food.per100g.kcal),
            protein: rounded(food.per100g.protein),
            carbs: rounded(food.per100g.carbs),
            fat: rounded(food.per100g.fat)
        )
    }
}

/// One food on the plate, with its weight as eaten.
public struct FoodPortion: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var food: Food
    /// Grams as eaten (cooked, ready to eat).
    public var grams: Int

    public init(id: UUID = UUID(), food: Food, grams: Int) {
        self.id = id
        self.food = food
        self.grams = grams
    }

    public var totals: NutritionTotals {
        NutritionTotals(food: food, grams: grams)
    }
}

extension Sequence where Element == FoodPortion {

    /// The sum of each portion's shown values.
    public var totals: NutritionTotals {
        reduce(.zero) { $0 + $1.totals }
    }

    public var totalGrams: Int {
        reduce(0) { $0 + $1.grams }
    }
}
