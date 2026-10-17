import Foundation
import Testing
@testable import MealKit

struct FoodTests {

    private let rice = FoodCatalog.development.food(id: "rice-white-cooked")!

    @Test func nameFollowsTheLanguage() {
        #expect(rice.name(in: Locale(identifier: "pt_BR")) == "Arroz branco")
        #expect(rice.name(in: Locale(identifier: "pt_PT")) == "Arroz branco")
        #expect(rice.name(in: Locale(identifier: "en_US")) == "White rice")
        #expect(rice.name(in: Locale(identifier: "fr_FR")) == "White rice")
    }

    @Test func catalogIDsAreUnique() {
        let ids = FoodCatalog.development.foods.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func mockSuggestionsExistInTheCatalog() {
        for suggestion in MockMealAnalyzer().result {
            #expect(FoodCatalog.development.food(id: suggestion.foodID) != nil)
        }
    }
}
