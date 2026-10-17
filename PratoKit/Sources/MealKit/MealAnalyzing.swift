import Foundation

/// A food the analysis believes is on the plate, matched to the catalog, with a weight to start from.
public struct FoodSuggestion: Hashable, Sendable {
    public var foodID: Food.ID
    public var grams: Int

    public init(foodID: Food.ID, grams: Int) {
        self.foodID = foodID
        self.grams = grams
    }
}

/// A food the analysis saw but couldn't tie to the catalog with confidence.
///
/// It is never swapped for a different food silently: the review asks the user to pick one.
public struct UnmatchedFood: Identifiable, Hashable, Sendable {
    public let id: UUID
    /// The name as recognized ("farofa", "batata frita").
    public var name: String
    /// The likely preparation, when visible ("frito", "cozido").
    public var preparation: String?
    /// The model's weight estimate, if any. An estimate, not a measurement.
    public var estimatedGrams: Int?
    /// Other things it could be, when the photo is ambiguous.
    public var alternatives: [String]
    /// A catalog food that looks close but wasn't a sure match; offered first when the user picks.
    public var suggestedFoodID: Food.ID?

    public init(
        id: UUID = UUID(),
        name: String,
        preparation: String?,
        estimatedGrams: Int?,
        alternatives: [String],
        suggestedFoodID: Food.ID? = nil
    ) {
        self.id = id
        self.name = name
        self.preparation = preparation
        self.estimatedGrams = estimatedGrams
        self.alternatives = alternatives
        self.suggestedFoodID = suggestedFoodID
    }
}

/// What the analysis of one photo found.
public struct MealAnalysis: Hashable, Sendable {
    /// Foods matched to the catalog; they become items of the review.
    public var suggestions: [FoodSuggestion]
    /// Foods the user must confirm or pick by hand.
    public var unmatched: [UnmatchedFood]

    public init(suggestions: [FoodSuggestion], unmatched: [UnmatchedFood] = []) {
        self.suggestions = suggestions
        self.unmatched = unmatched
    }
}

/// Why an analysis produced nothing to review.
public enum MealAnalysisError: Error, Equatable, Sendable {
    /// The photo doesn't show food.
    case noFoodFound
    /// The answer was empty, malformed or had no usable item.
    case unusableResponse
}

/// Suggests the foods and portions in a photo of a plate.
///
/// The screens depend only on this protocol, so the way foods are identified
/// can change without touching them.
public protocol MealAnalyzing: Sendable {
    /// Whether `analyze(photo:)` sends the photo off the device. The photo check tells the user so.
    var sendsPhotoToCloud: Bool { get }

    /// - Parameter photo: JPEG data of the plate.
    /// - Throws: ``MealAnalysisError`` when nothing usable was found; other errors for network
    ///   or service failures.
    func analyze(photo: Data) async throws -> MealAnalysis
}

/// Answers with rice, grilled chicken and salad after a short delay, whatever the photo.
/// Nothing leaves the device.
public struct MockMealAnalyzer: MealAnalyzing {

    public var delay: Duration
    public var result: [FoodSuggestion]
    public var unmatched: [UnmatchedFood]

    public init(
        delay: Duration = .seconds(1.5),
        result: [FoodSuggestion] = [
            FoodSuggestion(foodID: "rice-white-cooked", grams: 120),
            FoodSuggestion(foodID: "chicken-breast-grilled", grams: 150),
            FoodSuggestion(foodID: "leaf-salad", grams: 60)
        ],
        unmatched: [UnmatchedFood] = []
    ) {
        self.delay = delay
        self.result = result
        self.unmatched = unmatched
    }

    public var sendsPhotoToCloud: Bool { false }

    public func analyze(photo: Data) async throws -> MealAnalysis {
        try await Task.sleep(for: delay)
        return MealAnalysis(suggestions: result, unmatched: unmatched)
    }
}
