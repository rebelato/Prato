import Foundation

/// A food the analysis believes is on the plate, with an estimated weight.
public struct FoodSuggestion: Hashable, Sendable {
    public var foodID: Food.ID
    public var grams: Int

    public init(foodID: Food.ID, grams: Int) {
        self.foodID = foodID
        self.grams = grams
    }
}

/// Suggests the foods and portions in a photo of a plate.
///
/// The screens depend only on this protocol, so the way foods are identified
/// (on device, a backend, a vision model) can change without touching them.
public protocol MealAnalyzing: Sendable {
    /// - Parameter photo: JPEG data of the plate.
    func analyze(photo: Data) async throws -> [FoodSuggestion]
}

/// Answers with rice, grilled chicken and salad after a short delay, whatever the photo.
public struct MockMealAnalyzer: MealAnalyzing {

    public var delay: Duration
    public var result: [FoodSuggestion]

    public init(
        delay: Duration = .seconds(1.5),
        result: [FoodSuggestion] = [
            FoodSuggestion(foodID: "rice-white-cooked", grams: 120),
            FoodSuggestion(foodID: "chicken-breast-grilled", grams: 150),
            FoodSuggestion(foodID: "leaf-salad", grams: 60)
        ]
    ) {
        self.delay = delay
        self.result = result
    }

    public func analyze(photo: Data) async throws -> [FoodSuggestion] {
        try await Task.sleep(for: delay)
        return result
    }
}
