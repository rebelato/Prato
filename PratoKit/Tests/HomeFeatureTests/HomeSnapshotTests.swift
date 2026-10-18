import Foundation
import MealKit
import SnapshotTestSupport
import Testing
@testable import HomeFeature

/// Hoje on Friday, 16 October 2026, 15:00. Dates use the current calendar, so times render the
/// same in any time zone.
@MainActor
struct HomeSnapshotTests {

    private func date(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 16, hour: hour, minute: minute))!
    }

    private func loadedView(meals: [Meal]) async -> HomeView {
        let viewModel = HomeViewModel(store: InMemoryMealStore(meals: meals), now: { self.date(hour: 15) }) { _ in }
        await viewModel.load()
        return HomeView(viewModel: viewModel)
    }

    @Test func emptyDay() async {
        assertPratoSnapshot(of: await loadedView(meals: []), named: "home-empty", height: 1300)
    }

    @Test func dayWithMeals() async {
        let foods = FoodCatalog.development.foods
        let view = await loadedView(meals: [
            Meal(kind: .breakfast, date: date(hour: 8, minute: 10), portions: [FoodPortion(food: foods[0], grams: 80)], photo: nil),
            Meal(kind: .lunch, date: date(hour: 12, minute: 30), portions: [
                FoodPortion(food: foods[0], grams: 150), FoodPortion(food: foods[1], grams: 120)
            ], photo: nil)
        ])
        assertPratoSnapshot(of: view, named: "home-meals", height: 1300)
    }
}
