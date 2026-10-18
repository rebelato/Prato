import Foundation
import MealKit
import SnapshotTestSupport
import Testing
@testable import HistoryFeature

/// Histórico on Friday, 16 October 2026, 15:00. Dates use the current calendar, so days and times
/// render the same in any time zone.
@MainActor
struct HistorySnapshotTests {

    private func date(day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    private func loadedView(meals: [Meal]) async -> HistoryView {
        let viewModel = HistoryViewModel(store: InMemoryMealStore(meals: meals), now: { self.date(day: 16, hour: 15) }) { _ in }
        await viewModel.load()
        return HistoryView(viewModel: viewModel)
    }

    private func meal(_ kind: MealKind, day: Int, hour: Int, minute: Int = 0, grams: Int) -> Meal {
        let foods = FoodCatalog.development.foods
        return Meal(
            kind: kind,
            date: date(day: day, hour: hour, minute: minute),
            portions: [FoodPortion(food: foods[0], grams: grams), FoodPortion(food: foods[1], grams: grams / 2)],
            photo: nil
        )
    }

    @Test func emptyWeek() async {
        assertPratoSnapshot(of: await loadedView(meals: []), named: "history-empty-week")
    }

    @Test func weekWithMeals() async {
        let view = await loadedView(meals: [
            meal(.lunch, day: 13, hour: 12, grams: 150),
            meal(.breakfast, day: 15, hour: 8, grams: 80),
            meal(.breakfast, day: 16, hour: 8, minute: 15, grams: 90),
            meal(.lunch, day: 16, hour: 12, minute: 40, grams: 160)
        ])
        assertPratoSnapshot(of: view, named: "history-week-meals", height: 1100)
    }

    @Test func dayPicker() {
        let sheet = DayPickerSheet(selectedDay: date(day: 16), lastDay: date(day: 16), onPick: { _ in }, onCancel: {})
        assertPratoSnapshot(of: sheet, named: "history-day-picker")
    }
}
