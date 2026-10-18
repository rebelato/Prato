import Foundation
import MealKit
import Testing
@testable import ScanFeature

@MainActor
struct ReviewViewModelTests {

    private let lunchTime: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 16, hour: 12, minute: 30))!
    }()

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        return calendar
    }

    private func makeViewModel(
        suggestions: [FoodSuggestion] = MockMealAnalyzer().result,
        unmatched: [UnmatchedFood] = [],
        store: any MealStoring = InMemoryMealStore(),
        onEvent: @escaping @MainActor (ReviewEvent) -> Void = { _ in }
    ) -> ReviewViewModel {
        ReviewViewModel(
            suggestions: suggestions,
            unmatched: unmatched,
            photo: nil,
            catalog: .development,
            store: store,
            date: lunchTime,
            calendar: calendar,
            onEvent: onEvent
        )
    }

    @Test func startsWithSuggestionsAndTheMealOfTheHour() {
        let viewModel = makeViewModel()

        #expect(viewModel.portions.map(\.grams) == [120, 150, 60])
        #expect(viewModel.mealKind == .lunch)
        #expect(viewModel.totalGrams == 330)
    }

    @Test func unknownSuggestionsAreDropped() {
        let viewModel = makeViewModel(suggestions: [
            FoodSuggestion(foodID: "rice-white-cooked", grams: 100),
            FoodSuggestion(foodID: "not-in-catalog", grams: 80)
        ])

        #expect(viewModel.portions.count == 1)
    }

    @Test func totalEqualsTheSumOfRows() {
        let viewModel = makeViewModel()

        #expect(viewModel.totals.kcal == viewModel.portions.map(\.totals.kcal).reduce(0, +))
    }

    @Test func editingChangesFoodAndWeight() throws {
        let viewModel = makeViewModel()
        let chicken = viewModel.portions[1]
        let beef = try #require(FoodCatalog.development.food(id: "beef-grilled"))

        viewModel.portionTapped(chicken)
        var editor = try #require(viewModel.editor)
        editor.food = beef
        editor.adjustGrams(by: 50)
        viewModel.apply(editor)

        #expect(viewModel.editor == nil)
        #expect(viewModel.portions[1].id == chicken.id)
        #expect(viewModel.portions[1].food == beef)
        #expect(viewModel.portions[1].grams == 200)
    }

    @Test func addingStartsWithNoFoodChosen() throws {
        let viewModel = makeViewModel()

        viewModel.addFoodTapped()

        let editor = try #require(viewModel.editor)
        #expect(editor.food == nil)
        #expect(!editor.canApply)
        #expect(editor.totals == nil)
    }

    @Test func addingAppendsTheChosenFood() throws {
        let viewModel = makeViewModel()
        let egg = try #require(FoodCatalog.development.food(id: "egg-fried"))

        viewModel.addFoodTapped()
        var editor = try #require(viewModel.editor)
        editor.food = egg
        viewModel.apply(editor)

        #expect(viewModel.portions.count == 4)
        #expect(viewModel.portions.last?.food == egg)
        #expect(viewModel.portions.last?.grams == 100)
    }

    @Test func applyingWithoutAFoodDoesNothing() throws {
        let viewModel = makeViewModel()
        viewModel.addFoodTapped()

        viewModel.apply(try #require(viewModel.editor))

        #expect(viewModel.portions.count == 3)
        #expect(viewModel.editor != nil)
    }

    @Test func zeroGramsIsNotApplied() throws {
        let viewModel = makeViewModel()
        viewModel.portionTapped(viewModel.portions[0])
        var editor = try #require(viewModel.editor)
        editor.grams = 0

        viewModel.apply(editor)

        #expect(viewModel.portions[0].grams == 120)
        #expect(viewModel.editor != nil)
    }

    @Test func removingDeletesThePortion() {
        let viewModel = makeViewModel()
        let rice = viewModel.portions[0]

        viewModel.remove(rice.id)

        #expect(!viewModel.portions.contains { $0.id == rice.id })
    }

    @Test func cannotSaveAnEmptyMeal() async {
        var events: [ReviewEvent] = []
        let viewModel = makeViewModel(suggestions: []) { events.append($0) }

        await viewModel.saveTapped()

        #expect(!viewModel.canSave)
        #expect(events.isEmpty)
    }

    @Test func savingSendsTheStoredMeal() async throws {
        var events: [ReviewEvent] = []
        let viewModel = makeViewModel { events.append($0) }
        viewModel.mealKind = .dinner

        await viewModel.saveTapped()

        guard case .saved(let meal) = try #require(events.first) else {
            Issue.record("Expected saved")
            return
        }
        #expect(meal.kind == .dinner)
        #expect(meal.portions == viewModel.portions)
        #expect(meal.date == lunchTime)
        #expect(!viewModel.canSave)
        #expect(!viewModel.isSaving)
    }

    @Test func failedSaveShowsAnErrorAndCanRetry() async {
        var events: [ReviewEvent] = []
        let viewModel = makeViewModel(store: FailingStore()) { events.append($0) }

        await viewModel.saveTapped()

        #expect(viewModel.showsSaveError)
        #expect(viewModel.canSave)
        #expect(events.isEmpty)
    }
}

@MainActor
struct UnmatchedFoodTests {

    private let farofa = UnmatchedFood(name: "Farofa", preparation: nil, estimatedGrams: 40, alternatives: [])
    private let strips = UnmatchedFood(name: "Iscas de carne bovina", preparation: "refogado", estimatedGrams: 120,
                                       alternatives: ["Carne de panela", "Picadinho"])
    private let blackBeans = UnmatchedFood(name: "Feijão preto", preparation: "cozido", estimatedGrams: 90,
                                           alternatives: [], suggestedFoodID: "beans-carioca-cooked")

    private func makeViewModel() -> ReviewViewModel {
        ReviewViewModel(suggestions: [], unmatched: [farofa, blackBeans, strips], photo: nil, catalog: .development,
                        store: InMemoryMealStore(), date: .now) { _ in }
    }

    @Test func confirmingStartsFromTheSuggestionAndEstimate() throws {
        let viewModel = makeViewModel()

        viewModel.unmatchedTapped(blackBeans)

        let editor = try #require(viewModel.editor)
        #expect(editor.food?.id == "beans-carioca-cooked")
        #expect(editor.grams == 90)
        #expect(editor.recognizedName == "Feijão preto")
    }

    @Test func withoutASuggestionNoFoodIsPreselected() throws {
        let viewModel = makeViewModel()

        viewModel.unmatchedTapped(strips)

        let editor = try #require(viewModel.editor)
        #expect(editor.food == nil)
        #expect(editor.grams == 120)
        #expect(editor.alternatives == ["Carne de panela", "Picadinho"])
        #expect(editor.searchHints == ["Iscas de carne bovina", "Carne de panela", "Picadinho"])
    }

    @Test func applyingAddsThePortionAndResolvesTheItem() throws {
        let viewModel = makeViewModel()
        viewModel.unmatchedTapped(farofa)
        var editor = try #require(viewModel.editor)
        editor.food = try #require(FoodCatalog.development.food(id: "farofa"))

        viewModel.apply(editor)

        #expect(viewModel.portions.count == 1)
        #expect(viewModel.portions[0].grams == 40)
        #expect(viewModel.unmatched == [blackBeans, strips])
        #expect(viewModel.canSave)
    }

    @Test func cancellingKeepsTheItemToConfirm() {
        let viewModel = makeViewModel()
        viewModel.unmatchedTapped(farofa)

        viewModel.cancelEditing()

        #expect(viewModel.unmatched.count == 3)
        #expect(viewModel.portions.isEmpty)
    }

    @Test func dismissingDropsTheItem() {
        let viewModel = makeViewModel()

        viewModel.dismissUnmatched(farofa.id)

        #expect(viewModel.unmatched == [blackBeans, strips])
    }

    @Test func onlyUnmatchedFoodsCannotBeSaved() {
        #expect(!makeViewModel().canSave)
    }

    @Test func demonstrationValuesAreFlagged() {
        let viewModel = ReviewViewModel(suggestions: MockMealAnalyzer().result, photo: nil, catalog: .development,
                                        store: InMemoryMealStore(), date: .now) { _ in }

        #expect(viewModel.usesDemonstrationValues)
    }
}

struct PortionEditorTests {

    private let rice = FoodCatalog.development.foods[0]

    @Test func gramsStayBetweenZeroAndTheLimit() {
        var editor = PortionEditor(mode: .add, food: rice, grams: 30)

        editor.adjustGrams(by: -50)
        #expect(editor.grams == 0)
        #expect(!editor.canApply)

        editor.grams = 5000
        #expect(editor.grams == PortionEditor.maxGrams)
    }
}
