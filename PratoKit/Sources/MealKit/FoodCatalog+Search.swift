import Foundation

extension FoodCatalog {

    /// Foods with every typed word at the start of a word of their names or search terms,
    /// sorted by name: "carn pan" finds "Carne de panela". An empty query returns every food.
    public func search(_ query: String, locale: Locale = .current) -> [Food] {
        let queryWords = TextNormalizer.words(in: query)
        let sorted = foods.sorted {
            $0.name(in: locale).localizedStandardCompare($1.name(in: locale)) == .orderedAscending
        }
        guard !queryWords.isEmpty else { return sorted }

        return sorted.filter { food in
            let words = Set(phrases(of: food).joined())
            return queryWords.allSatisfy { queryWord in
                words.contains { $0.hasPrefix(queryWord) }
            }
        }
    }

    /// Catalog foods that look like the given names, closest first.
    ///
    /// A food is close when one of its names or terms appears, as whole words in order, inside
    /// a name: "Iscas de carne bovina" contains "iscas de carne" and "carne bovina". Longer
    /// matches rank first. Meant for offering choices, never for choosing for the user.
    public func similar(to names: [String], limit: Int = 5) -> [Food] {
        let queries = names.map(TextNormalizer.words(in:)).filter { !$0.isEmpty }
        guard !queries.isEmpty else { return [] }

        let scored = foods.enumerated().compactMap { index, food -> (index: Int, food: Food, score: Int)? in
            let score = phrases(of: food)
                .filter { phrase in queries.contains { TextNormalizer.words($0, contain: phrase) } }
                .map(\.count)
                .max() ?? 0
            return score > 0 ? (index, food, score) : nil
        }
        return scored
            .sorted { $0.score != $1.score ? $0.score > $1.score : $0.index < $1.index }
            .prefix(limit)
            .map(\.food)
    }

    /// Names and search terms of a food, each split into normalized words.
    private func phrases(of food: Food) -> [[String]] {
        ([food.namePT, food.nameEN] + (searchInfo[food.id]?.terms ?? []))
            .map(TextNormalizer.words(in:))
            .filter { !$0.isEmpty }
    }
}

extension TextNormalizer {

    /// Whether `phrase` appears in `words` as whole words, together and in order.
    public static func words(_ words: [String], contain phrase: [String]) -> Bool {
        guard !phrase.isEmpty, phrase.count <= words.count else { return false }
        return (0...(words.count - phrase.count)).contains { start in
            Array(words[start..<(start + phrase.count)]) == phrase
        }
    }
}
