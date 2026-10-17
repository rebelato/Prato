import Foundation
import Testing
@testable import MealKit

struct FoodCatalogSearchTests {

    private let catalog = FoodCatalog.development
    private let portuguese = Locale(identifier: "pt_BR")

    private func ids(_ foods: [Food]) -> [String] {
        foods.map(\.id)
    }

    @Test func emptySearchListsEveryFoodByName() {
        let all = catalog.search("", locale: portuguese)

        #expect(all.count == catalog.foods.count)
        #expect(all.first?.namePT == "Arroz branco")
    }

    @Test func searchMatchesWordPrefixesIgnoringAccents() {
        #expect(ids(catalog.search("carn pan", locale: portuguese)) == ["beef-pot-roast"])
        #expect(ids(catalog.search("FEIJAO", locale: portuguese)) == ["beans-carioca-cooked", "beans-black-cooked"])
        #expect(ids(catalog.search("aipim", locale: portuguese)) == ["cassava-boiled"])
    }

    @Test func searchFindsEnglishNamesToo() {
        #expect(ids(catalog.search("fries", locale: portuguese)) == ["potato-fried"])
    }

    @Test func searchWithNoMatchIsEmpty() {
        #expect(catalog.search("moqueca", locale: portuguese).isEmpty)
    }

    @Test func similarRanksTheLongestMatchFirst() {
        let similar = catalog.similar(to: ["Iscas de carne bovina", "Carne de panela"])

        #expect(similar.first?.id == "beef-strips-sauteed")
        #expect(similar.contains { $0.id == "beef-pot-roast" })
        #expect(similar.contains { $0.id == "beef-grilled" })
        #expect(!similar.contains { $0.id == "rice-white-cooked" })
    }

    @Test func similarToUnknownNamesIsEmpty() {
        #expect(catalog.similar(to: ["Moqueca"]).isEmpty)
        #expect(catalog.similar(to: []).isEmpty)
    }

    @Test func phraseMustAppearAsWholeWordsInOrder() {
        #expect(TextNormalizer.words(["iscas", "de", "carne", "bovina"], contain: ["carne", "bovina"]))
        #expect(!TextNormalizer.words(["carne", "de", "panela"], contain: ["carne", "bovina"]))
        #expect(!TextNormalizer.words(["carne"], contain: ["carne", "bovina"]))
        #expect(!TextNormalizer.words(["carnes"], contain: ["carne"]))
    }
}
