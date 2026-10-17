import MealKit

/// Ties recognized foods to catalog foods, or leaves them for the user to pick.
///
/// It prefers asking over guessing:
/// - a **match** needs the recognized name itself (minus preparation words) to be one of the
///   food's terms, and the preparation to agree;
/// - when only the generic search term matches ("feijão tropeiro" → "feijao"), or a term
///   appears inside the name ("iscas de carne bovina" → "iscas de carne"), the food stays
///   unmatched and the catalog food is offered as a suggestion for the user to confirm;
/// - a different preparation ("batata frita" vs. boiled potato) is never matched.
public struct CatalogMatcher: Sendable {

    /// Weight used when the model gave none. The review marks every weight as an estimate.
    public static let defaultGrams = 100

    private let catalog: FoodCatalog

    public init(catalog: FoodCatalog) {
        self.catalog = catalog
    }

    public func analysis(for foods: [RecognizedFood]) -> MealAnalysis {
        var suggestions: [FoodSuggestion] = []
        var unmatched: [UnmatchedFood] = []

        for recognized in foods {
            switch match(recognized) {
            case .sure(let food):
                suggestions.append(FoodSuggestion(foodID: food.id, grams: recognized.estimatedGrams ?? Self.defaultGrams))
            case .toConfirm(let food):
                unmatched.append(unmatchedFood(recognized, suggesting: food))
            case .none:
                unmatched.append(unmatchedFood(recognized, suggesting: nil))
            }
        }
        return MealAnalysis(suggestions: suggestions, unmatched: unmatched)
    }

    enum Match: Equatable {
        case sure(Food)
        case toConfirm(Food)
        case none
    }

    func match(_ recognized: RecognizedFood) -> Match {
        let name = TextNormalizer.normalize(recognized.name)
        let term = TextNormalizer.normalize(recognized.searchTerm)
        let preparation = recognized.preparation ?? Self.preparation(in: name) ?? Self.preparation(in: term)
        let nameCore = Self.removingPreparationWords(from: name)
        let termCore = Self.removingPreparationWords(from: term)

        // Terms are compared without their preparation words too: the preparation is checked
        // on its own, so "batata frita" is the term "batata" for a fried food.
        let candidates = catalog.foods.compactMap { food -> (food: Food, terms: Set<[String]>)? in
            guard let info = catalog.searchInfo[food.id] else { return nil }
            if let preparation, let foodPreparation = info.preparation, foodPreparation != preparation {
                return nil
            }
            let terms = info.terms
                .map { Self.removingPreparationWords(from: TextNormalizer.normalize($0)).words }
                .filter { !$0.isEmpty }
            return (food, Set(terms))
        }

        let byName = candidates.filter { $0.terms.contains(nameCore.words) }
        if byName.count == 1 {
            return .sure(byName[0].food)
        }
        if byName.count > 1 {
            return .none
        }

        let byTerm = candidates.filter { $0.terms.contains(termCore.words) }
        if byTerm.count == 1 {
            return .toConfirm(byTerm[0].food)
        }
        if byTerm.count > 1 {
            return .none
        }

        // A term inside the recognized name: "iscas de carne bovina" contains "iscas de carne".
        // The longest term wins; a tie means the photo could be either, so nothing is offered.
        let scored = candidates.map { candidate in
            let length = candidate.terms
                .filter { TextNormalizer.words(nameCore.words, contain: $0) || TextNormalizer.words(termCore.words, contain: $0) }
                .map(\.count)
                .max() ?? 0
            return (food: candidate.food, length: length)
        }
        let longest = scored.map(\.length).max() ?? 0
        let best = scored.filter { $0.length == longest }
        guard longest > 0, best.count == 1 else { return .none }
        return .toConfirm(best[0].food)
    }

    private func unmatchedFood(_ recognized: RecognizedFood, suggesting food: Food?) -> UnmatchedFood {
        UnmatchedFood(
            name: recognized.name,
            preparation: recognized.preparation?.rawValue,
            estimatedGrams: recognized.estimatedGrams,
            alternatives: recognized.alternatives,
            suggestedFoodID: food?.id
        )
    }

    private static func preparation(in text: String) -> Preparation? {
        let words = Set(text.split(separator: " ").map(String.init))
        return Preparation.allCases.first { !words.isDisjoint(with: $0.words) }
    }

    private static func removingPreparationWords(from text: String) -> String {
        let preparationWords = Set(Preparation.allCases.flatMap(\.words))
        return text
            .split(separator: " ")
            .map(String.init)
            .filter { !preparationWords.contains($0) }
            .joined(separator: " ")
    }
}

private extension String {
    /// The words of an already normalized string.
    var words: [String] {
        split(separator: " ").map(String.init)
    }
}
