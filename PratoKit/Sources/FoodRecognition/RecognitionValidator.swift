import Foundation
import MealKit

/// A recognized food after validation: trimmed, bounded and with known values only.
public struct RecognizedFood: Hashable, Sendable {
    public var name: String
    /// Never empty; falls back to `name` when the model left it out.
    public var searchTerm: String
    public var preparation: Preparation?
    /// Within ``RecognitionValidator/gramsRange``, or `nil`.
    public var estimatedGrams: Int?
    public var alternatives: [String]
}

/// Turns a decoded response into foods the app can trust the shape of.
///
/// Structured output doesn't remove the need for this: fields can be empty, numbers out of
/// range, lists too long, or the answer can say there's food and list nothing.
public enum RecognitionValidator {

    /// Most items kept from one photo.
    public static let maxItems = 12
    /// Weights outside this range are dropped (the user enters one instead).
    public static let gramsRange = 1...2000
    /// Most alternatives kept per item.
    public static let maxAlternatives = 3

    /// - Throws: `MealAnalysisError.noFoodFound` when the photo has no food;
    ///   `.unusableResponse` when no valid item is left.
    public static func validate(_ response: RecognitionResponse) throws -> [RecognizedFood] {
        guard response.containsFood else {
            throw MealAnalysisError.noFoodFound
        }

        var seen = Set<String>()
        let foods = response.items.compactMap { item -> RecognizedFood? in
            let name = clean(item.name)
            let term = clean(item.searchTerm ?? "")
            let searchTerm = term.isEmpty ? name : term
            guard !searchTerm.isEmpty else { return nil }

            let preparation = item.preparation.flatMap { Preparation(rawValue: TextNormalizer.normalize($0)) }

            // The same food twice in one answer is a repeat, not a second portion.
            let key = TextNormalizer.normalize(searchTerm) + "|" + (preparation?.rawValue ?? "")
            guard seen.insert(key).inserted else { return nil }

            let grams = item.estimatedGrams.flatMap { gramsRange.contains($0) ? $0 : nil }

            var alternatives: [String] = []
            for alternative in item.alternatives ?? [] {
                let cleaned = clean(alternative)
                guard !cleaned.isEmpty,
                      TextNormalizer.normalize(cleaned) != TextNormalizer.normalize(name),
                      !alternatives.contains(where: { TextNormalizer.normalize($0) == TextNormalizer.normalize(cleaned) })
                else { continue }
                alternatives.append(cleaned)
                if alternatives.count == maxAlternatives { break }
            }

            return RecognizedFood(
                name: name.isEmpty ? searchTerm : name,
                searchTerm: searchTerm,
                preparation: preparation,
                estimatedGrams: grams,
                alternatives: alternatives
            )
        }

        guard !foods.isEmpty else {
            throw MealAnalysisError.unusableResponse
        }
        return Array(foods.prefix(maxItems))
    }

    /// Trims, collapses inner whitespace and caps the length of a model-provided string.
    private static func clean(_ text: String) -> String {
        let collapsed = text
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
        return String(collapsed.prefix(80))
    }
}

/// Lowercase, accent-free, single-spaced text for comparing food names.
public enum TextNormalizer {
    public static func normalize(_ text: String) -> String {
        text
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pt_BR"))
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
