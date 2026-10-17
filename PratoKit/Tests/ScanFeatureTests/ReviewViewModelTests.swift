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
        onEvent: @escaping @MainActor (ReviewEvent) -> Void = { _ in }
    ) -> ReviewViewModel {
        ReviewViewModel(
            suggestions: suggestions,
            photo: nil,
            catalog: .development,
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

    @Test func addingAppendsAFood() throws {
        let viewModel = makeViewModel()

        viewModel.addFoodTapped()
        viewModel.apply(try #require(viewModel.editor))

        #expect(viewModel.portions.count == 4)
        #expect(viewModel.portions.last?.grams == 100)
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

    @Test func cannotSaveAnEmptyMeal() {
        var events: [ReviewEvent] = []
        let viewModel = makeViewModel(suggestions: []) { events.append($0) }

        viewModel.saveTapped()

        #expect(!viewModel.canSave)
        #expect(events.isEmpty)
    }

    @Test func savingSendsTheDraft() throws {
        var events: [ReviewEvent] = []
        let viewModel = makeViewModel { events.append($0) }
        viewModel.mealKind = .dinner

        viewModel.saveTapped()

        guard case .saveRequested(let draft) = try #require(events.first) else {
            Issue.record("Expected saveRequested")
            return
        }
        #expect(draft.kind == .dinner)
        #expect(draft.portions == viewModel.portions)
        #expect(draft.date == lunchTime)
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
