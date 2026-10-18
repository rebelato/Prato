import Foundation
import MealKit
import SnapshotTestSupport
import SwiftUI
import Testing
@testable import ScanFeature

/// The scan flow's screens that don't depend on the camera or on an animation.
/// Dates use the current calendar, so times render the same in any time zone.
@MainActor
struct ScanSnapshotTests {

    private let lunchTime = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 16, hour: 12, minute: 30))!

    @Test func review() {
        let viewModel = ReviewViewModel(
            suggestions: MockMealAnalyzer().result,
            unmatched: [
                UnmatchedFood(name: "Feijão preto", preparation: "cozido", estimatedGrams: 90, alternatives: [], suggestedFoodID: "beans-carioca-cooked")
            ],
            photo: nil,
            catalog: .development,
            store: InMemoryMealStore(),
            date: lunchTime
        ) { _ in }
        assertPratoSnapshot(of: NavigationStack { ReviewView(viewModel: viewModel) }, named: "review", height: 1100)
    }

    @Test func portionEditor() {
        let sheet = PortionEditorSheet(
            editor: PortionEditor(mode: .edit(UUID()), food: FoodCatalog.development.foods[1], grams: 150),
            catalog: .development,
            onApply: { _ in },
            onRemove: {},
            onCancel: {}
        )
        assertPratoSnapshot(of: sheet, named: "portion-editor")
    }

    @Test func saved() {
        let catalog = FoodCatalog.development
        let portions = MockMealAnalyzer().result.compactMap { suggestion in
            catalog.food(id: suggestion.foodID).map { FoodPortion(food: $0, grams: suggestion.grams) }
        }
        let meal = Meal(kind: .lunch, date: lunchTime, portions: portions, photo: nil)
        assertPratoSnapshot(of: NavigationStack { SavedView(meal: meal) { _ in } }, named: "saved")
    }
}
