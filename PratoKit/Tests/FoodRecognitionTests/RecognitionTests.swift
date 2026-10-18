import MealKit
import Testing
@testable import FoodRecognition

struct RecognitionDecodingTests {

    @Test func decodesTheSchemaShape() throws {
        let json = """
        {"containsFood": true, "items": [
          {"name": "Arroz branco", "searchTerm": "arroz branco", "preparation": "cozido", "estimatedGrams": 120},
          {"name": "Feijão preto", "searchTerm": "feijao", "alternatives": ["feijão carioca"], "uncertainty": "caldo cobre os grãos"}
        ]}
        """

        let response = try RecognitionResponse.decode(json)

        #expect(response.containsFood)
        #expect(response.items.count == 2)
        #expect(response.items[0].estimatedGrams == 120)
        #expect(response.items[1].preparation == nil)
        #expect(response.items[1].alternatives == ["feijão carioca"])
    }

    @Test func toleratesACodeFence() throws {
        let text = "```json\n{\"containsFood\": false, \"items\": []}\n```"

        #expect(try RecognitionResponse.decode(text).containsFood == false)
    }

    @Test(arguments: [
        "",
        "Não consigo ver a imagem.",
        "{\"items\": []}",
        "{\"containsFood\": true}",
        "{\"containsFood\": true, \"items\": [{\"searchTerm\": \"arroz\"}]}",
        "{\"containsFood\": true, \"items\": [{\"name\": \"arroz\", \"estimatedGrams\": \"cem\"}]}"
    ])
    func malformedAnswersAreUnusable(text: String) {
        #expect(throws: MealAnalysisError.unusableResponse) {
            try RecognitionResponse.decode(text)
        }
    }
}

struct RecognitionValidatorTests {

    private typealias Item = RecognitionResponse.Item

    @Test func noFoodIsReportedEvenWithItems() {
        let response = RecognitionResponse(containsFood: false, items: [Item(name: "arroz")])

        #expect(throws: MealAnalysisError.noFoodFound) {
            try RecognitionValidator.validate(response)
        }
    }

    @Test func foodWithNoValidItemIsUnusable() {
        let response = RecognitionResponse(containsFood: true, items: [Item(name: "   ", searchTerm: "")])

        #expect(throws: MealAnalysisError.unusableResponse) {
            try RecognitionValidator.validate(response)
        }
    }

    @Test func cleansNamesAndFallsBackToTheNameForSearch() throws {
        let response = RecognitionResponse(containsFood: true, items: [Item(name: "  Arroz   branco \n")])

        let food = try #require(try RecognitionValidator.validate(response).first)

        #expect(food.name == "Arroz branco")
        #expect(food.searchTerm == "Arroz branco")
    }

    @Test(arguments: [(0, nil), (-50, nil), (1, 1), (350, 350), (2000, 2000), (2001, nil)] as [(Int, Int?)])
    func weightOutsideTheRangeIsDropped(grams: Int, expected: Int?) throws {
        let response = RecognitionResponse(containsFood: true, items: [Item(name: "arroz", estimatedGrams: grams)])

        #expect(try RecognitionValidator.validate(response).first?.estimatedGrams == expected)
    }

    @Test func unknownPreparationIsIgnored() throws {
        let response = RecognitionResponse(containsFood: true, items: [
            Item(name: "arroz", preparation: "Cozido"),
            Item(name: "frango", preparation: "à milanesa")
        ])

        let foods = try RecognitionValidator.validate(response)

        #expect(foods.map(\.preparation) == [.cooked, nil])
    }

    @Test func alternativesAreCleanedDedupedAndCapped() throws {
        let response = RecognitionResponse(containsFood: true, items: [
            Item(name: "Purê de batata", alternatives: ["purê de batata", "", "Purê de mandioquinha", "pure de mandioquinha", "inhame", "cará", "aipim"])
        ])

        let food = try #require(try RecognitionValidator.validate(response).first)

        #expect(food.alternatives == ["Purê de mandioquinha", "inhame", "cará"])
    }

    @Test func repeatedFoodsAreKeptOnce() throws {
        let response = RecognitionResponse(containsFood: true, items: [
            Item(name: "Arroz", searchTerm: "arroz"),
            Item(name: "arroz branco", searchTerm: "Arroz"),
            Item(name: "Arroz frito", searchTerm: "arroz", preparation: "frito")
        ])

        #expect(try RecognitionValidator.validate(response).count == 2)
    }

    @Test func listIsCapped() throws {
        let items = (1...30).map { Item(name: "alimento \($0)") }

        let foods = try RecognitionValidator.validate(RecognitionResponse(containsFood: true, items: items))

        #expect(foods.count == RecognitionValidator.maxItems)
    }
}

struct CatalogMatcherTests {

    private let matcher = CatalogMatcher(catalog: .development)

    private func recognized(
        _ name: String,
        term: String? = nil,
        preparation: Preparation? = nil,
        grams: Int? = nil
    ) -> RecognizedFood {
        RecognizedFood(name: name, searchTerm: term ?? name, preparation: preparation, estimatedGrams: grams, alternatives: [])
    }

    private func food(_ id: String) -> Food {
        FoodCatalog.development.food(id: id)!
    }

    @Test func namesMatchIgnoringCaseAccentsAndPreparationWords() {
        #expect(matcher.match(recognized("Arroz Branco")) == .sure(food("rice-white-cooked")))
        #expect(matcher.match(recognized("Feijão")) == .sure(food("beans-carioca-cooked")))
        #expect(matcher.match(recognized("Frango grelhado", preparation: .grilled)) == .sure(food("chicken-breast-grilled")))
    }

    @Test func preparationPicksTheMatchingVariant() {
        #expect(matcher.match(recognized("Batata frita", term: "batata")) == .sure(food("potato-fried")))
        #expect(matcher.match(recognized("Batata", preparation: .fried)) == .sure(food("potato-fried")))
        #expect(matcher.match(recognized("Batata", preparation: .cooked)) == .sure(food("potato-boiled")))
        #expect(matcher.match(recognized("Ovo frito", term: "ovo")) == .sure(food("egg-fried")))
    }

    @Test func differentPreparationIsNeverMatched() {
        #expect(matcher.match(recognized("Batata", preparation: .roasted)) == .none)
        #expect(matcher.match(recognized("Ovo", preparation: .roasted)) == .none)
    }

    @Test func sameFoodInSeveralPreparationsNeedsThePreparation() {
        #expect(matcher.match(recognized("Batata")) == .none)
        #expect(matcher.match(recognized("Ovo")) == .none)
    }

    @Test func genericTermOnlyIsOfferedForConfirmation() {
        #expect(matcher.match(recognized("Feijão tropeiro", term: "feijao")) == .toConfirm(food("beans-carioca-cooked")))
    }

    @Test func termInsideTheNameIsOfferedForConfirmation() {
        let strips = food("beef-strips-sauteed")

        #expect(matcher.match(recognized("Iscas de carne bovina", term: "carne bovina", preparation: .sauteed)) == .toConfirm(strips))
        // Without a preparation, the longest term found in the name wins: "iscas de carne" over "carne bovina".
        #expect(matcher.match(recognized("Iscas de carne bovina", term: "iscas de carne bovina")) == .toConfirm(strips))
    }

    @Test func mixedDishesAreNotGuessed() {
        #expect(matcher.match(recognized("Arroz com feijão", term: "arroz com feijao")) == .none)
    }

    @Test func unknownFoodIsUnmatched() {
        #expect(matcher.match(recognized("Moqueca", term: "moqueca")) == .none)
    }

    @Test func analysisSplitsMatchedAndUnmatchedAndKeepsWeights() {
        let analysis = matcher.analysis(for: [
            recognized("Arroz branco", grams: 150),
            recognized("Frango", preparation: .grilled),
            recognized("Moqueca", grams: 200),
            recognized("Feijão tropeiro", term: "feijao")
        ])

        #expect(analysis.suggestions == [
            FoodSuggestion(foodID: "rice-white-cooked", grams: 150),
            FoodSuggestion(foodID: "chicken-breast-grilled", grams: CatalogMatcher.defaultGrams)
        ])
        #expect(analysis.unmatched.map(\.name) == ["Moqueca", "Feijão tropeiro"])
        #expect(analysis.unmatched[0].estimatedGrams == 200)
        #expect(analysis.unmatched[0].suggestedFoodID == nil)
        #expect(analysis.unmatched[1].suggestedFoodID == "beans-carioca-cooked")
    }
}
