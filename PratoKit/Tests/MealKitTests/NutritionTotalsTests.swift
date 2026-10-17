import Foundation
import Testing
@testable import MealKit

struct NutritionTotalsTests {

    private let rice = FoodCatalog.development.food(id: "rice-white-cooked")!
    private let chicken = FoodCatalog.development.food(id: "chicken-breast-grilled")!
    private let salad = FoodCatalog.development.food(id: "leaf-salad")!

    @Test func portionRoundsEachNutrientOnce() {
        // 128 kcal per 100 g × 1.2 = 153.6
        let totals = FoodPortion(food: rice, grams: 120).totals

        #expect(totals.kcal == 154)
        #expect(totals.protein == 3)   // 3.0
        #expect(totals.carbs == 34)    // 33.72
        #expect(totals.fat == 0)       // 0.24
    }

    @Test func mealTotalIsTheSumOfShownItemValues() {
        let portions = [
            FoodPortion(food: rice, grams: 120),
            FoodPortion(food: chicken, grams: 150),
            FoodPortion(food: salad, grams: 60)
        ]

        let shownSum = portions.map(\.totals.kcal).reduce(0, +)

        #expect(portions.totals.kcal == shownSum)
        #expect(portions.totalGrams == 330)
    }

    @Test(arguments: 0..<50)
    func totalsAlwaysAddUp(seed: Int) {
        var generator = SeededGenerator(seed: UInt64(seed))
        let foods = FoodCatalog.development.foods
        let portions = (0..<Int.random(in: 1...6, using: &generator)).map { _ in
            FoodPortion(
                food: foods.randomElement(using: &generator)!,
                grams: Int.random(in: 1...600, using: &generator)
            )
        }

        let totals = portions.totals

        #expect(totals.kcal == portions.map(\.totals.kcal).reduce(0, +))
        #expect(totals.protein == portions.map(\.totals.protein).reduce(0, +))
        #expect(totals.carbs == portions.map(\.totals.carbs).reduce(0, +))
        #expect(totals.fat == portions.map(\.totals.fat).reduce(0, +))
    }

    @Test func emptyMealIsZero() {
        #expect([FoodPortion]().totals == .zero)
    }
}

/// Deterministic random numbers, so a failing case can be replayed.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &+ 0x9E37_79B9_7F4A_7C15
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
