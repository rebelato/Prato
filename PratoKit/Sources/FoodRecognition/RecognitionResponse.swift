import Foundation
import MealKit

/// The JSON the model answers with, as decoded. Field names match the response schema.
///
/// Structured output makes the shape likely, not guaranteed: everything here is checked by
/// ``RecognitionValidator`` before it reaches the app.
public struct RecognitionResponse: Decodable, Sendable, Equatable {

    public struct Item: Decodable, Sendable, Equatable {
        public var name: String
        public var searchTerm: String?
        public var preparation: String?
        public var estimatedGrams: Int?
        public var alternatives: [String]?
        public var uncertainty: String?

        public init(
            name: String,
            searchTerm: String? = nil,
            preparation: String? = nil,
            estimatedGrams: Int? = nil,
            alternatives: [String]? = nil,
            uncertainty: String? = nil
        ) {
            self.name = name
            self.searchTerm = searchTerm
            self.preparation = preparation
            self.estimatedGrams = estimatedGrams
            self.alternatives = alternatives
            self.uncertainty = uncertainty
        }
    }

    public var containsFood: Bool
    public var items: [Item]

    public init(containsFood: Bool, items: [Item]) {
        self.containsFood = containsFood
        self.items = items
    }

    /// Field names shared with the response schema, so the two can't drift apart.
    public enum Field {
        public static let containsFood = "containsFood"
        public static let items = "items"
        public static let name = "name"
        public static let searchTerm = "searchTerm"
        public static let preparation = "preparation"
        public static let estimatedGrams = "estimatedGrams"
        public static let alternatives = "alternatives"
        public static let uncertainty = "uncertainty"
    }

    /// Decodes the model's text. Tolerates a Markdown code fence around the JSON.
    /// - Throws: `MealAnalysisError.unusableResponse` when the text isn't the expected JSON.
    public static func decode(_ text: String) throws -> RecognitionResponse {
        var json = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if json.hasPrefix("```") {
            json = json
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard let data = json.data(using: .utf8),
              let response = try? JSONDecoder().decode(RecognitionResponse.self, from: data)
        else {
            throw MealAnalysisError.unusableResponse
        }
        return response
    }
}
