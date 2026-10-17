import Foundation
import MealKit
import Testing
@testable import HomeFeature

@MainActor
struct HomeViewModelTests {

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        return calendar
    }()

    private func date(day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))!
    }

    private func meal(_ kind: MealKind, day: Int, hour: Int, grams: Int = 100) -> Meal {
        Meal(
            kind: kind,
            date: date(day: day, hour: hour),
            portions: [FoodPortion(food: FoodCatalog.development.foods[0], grams: grams)],
            photo: nil
        )
    }

    private func makeViewModel(
        store: any MealStoring = InMemoryMealStore(),
        onEvent: @escaping @MainActor (HomeEvent) -> Void = { _ in }
    ) -> HomeViewModel {
        HomeViewModel(store: store, now: { self.date(day: 16, hour: 15) }, calendar: calendar, onEvent: onEvent)
    }

    @Test func scanButtonRequestsCameraScan() {
        var events: [HomeEvent] = []
        let viewModel = makeViewModel { events.append($0) }

        viewModel.scanTapped()

        #expect(events == [.scanRequested(.camera)])
    }

    @Test func galleryButtonRequestsGalleryScan() {
        var events: [HomeEvent] = []
        let viewModel = makeViewModel { events.append($0) }

        viewModel.galleryTapped()

        #expect(events == [.scanRequested(.gallery)])
    }

    @Test func loadsOnlyTodaysMealsOldestFirst() async {
        let breakfast = meal(.breakfast, day: 16, hour: 8)
        let lunch = meal(.lunch, day: 16, hour: 12)
        let store = InMemoryMealStore(meals: [lunch, meal(.dinner, day: 15, hour: 20), breakfast, meal(.breakfast, day: 17, hour: 8)])
        let viewModel = makeViewModel(store: store)

        #expect(!viewModel.hasLoaded)
        await viewModel.load()

        #expect(viewModel.hasLoaded)
        #expect(viewModel.todayMeals == [breakfast, lunch])
    }

    @Test func dayTotalIsTheSumOfMeals() async {
        let store = InMemoryMealStore(meals: [meal(.breakfast, day: 16, hour: 8, grams: 80), meal(.lunch, day: 16, hour: 12, grams: 150)])
        let viewModel = makeViewModel(store: store)

        await viewModel.load()

        #expect(viewModel.todayTotals.kcal == viewModel.todayMeals.map(\.totals.kcal).reduce(0, +))
    }

    @Test func newMealAppearsOnReload() async throws {
        let store = InMemoryMealStore()
        let viewModel = makeViewModel(store: store)
        await viewModel.load()
        #expect(viewModel.todayMeals.isEmpty)

        let saved = try await store.save(MealDraft(kind: .snack, portions: [], photo: nil, date: date(day: 16, hour: 16)))
        await viewModel.load()

        #expect(viewModel.todayMeals.map(\.id) == [saved.id])
    }
}
