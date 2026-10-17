import Foundation
import MealKit
import Testing
@testable import HistoryFeature

/// Today is Friday, 16 October 2026, 15:00 in São Paulo; weeks start on Monday,
/// so the current week is 12–18 October.
@MainActor
struct HistoryViewModelTests {

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        calendar.firstWeekday = 2
        return calendar
    }()

    private func date(month: Int = 10, day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
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
        meals: [Meal] = [],
        onEvent: @escaping @MainActor (HistoryEvent) -> Void = { _ in }
    ) -> HistoryViewModel {
        HistoryViewModel(
            store: InMemoryMealStore(meals: meals),
            now: { self.date(day: 16, hour: 15) },
            calendar: calendar,
            onEvent: onEvent
        )
    }

    @Test func startsOnThisWeekWithTodaySelected() {
        let viewModel = makeViewModel()

        #expect(viewModel.week.start == date(day: 12))
        #expect(viewModel.weekLastDay == date(day: 18))
        #expect(viewModel.selectedDay == date(day: 16))
        #expect(!viewModel.canShowNextWeek)
    }

    @Test func stripMarksFutureDaysAndDaysWithMeals() async {
        let viewModel = makeViewModel(meals: [
            meal(.lunch, day: 12, hour: 12),
            meal(.breakfast, day: 16, hour: 8),
            meal(.lunch, day: 16, hour: 12)
        ])

        await viewModel.load()
        let days = viewModel.days

        #expect(days.map(\.date) == (12...18).map { date(day: $0) })
        #expect(days.map(\.mealCount) == [1, 0, 0, 0, 2, 0, 0])
        #expect(days.map(\.isFuture) == [false, false, false, false, false, true, true])
    }

    @Test func futureDaysCannotBeSelected() {
        let viewModel = makeViewModel()
        let saturday = viewModel.days[5]

        viewModel.select(saturday)

        #expect(viewModel.selectedDay == date(day: 16))
    }

    @Test func selectingADayShowsItsMeals() async {
        let monday = meal(.lunch, day: 12, hour: 12)
        let viewModel = makeViewModel(meals: [monday, meal(.lunch, day: 16, hour: 12)])
        await viewModel.load()

        viewModel.select(viewModel.days[0])

        #expect(viewModel.selectedDayMeals == [monday])
    }

    @Test func totalsAndAverageCountOnlyLoggedDays() async {
        let viewModel = makeViewModel(meals: [
            meal(.lunch, day: 12, hour: 12, grams: 100),
            meal(.breakfast, day: 16, hour: 8, grams: 100),
            meal(.lunch, day: 16, hour: 12, grams: 100),
            meal(.dinner, day: 11, hour: 20, grams: 500)
        ])

        await viewModel.load()

        let perMeal = FoodPortion(food: FoodCatalog.development.foods[0], grams: 100).totals.kcal
        #expect(viewModel.weekMeals.count == 3)
        #expect(viewModel.weekTotals.kcal == perMeal * 3)
        #expect(viewModel.loggedDayCount == 2)
        #expect(viewModel.averageKcalPerLoggedDay == Int((Double(perMeal * 3) / 2).rounded()))
    }

    @Test func emptyWeekHasNoAverage() async {
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.hasLoaded)
        #expect(viewModel.weekMeals.isEmpty)
        #expect(viewModel.averageKcalPerLoggedDay == nil)
    }

    @Test func previousWeekSelectsItsLastDayAndLoadsItsMeals() async {
        let lastSunday = meal(.dinner, day: 11, hour: 20)
        let viewModel = makeViewModel(meals: [lastSunday, meal(.lunch, day: 16, hour: 12)])

        await viewModel.previousWeekTapped()

        #expect(viewModel.week.start == date(day: 5))
        #expect(viewModel.selectedDay == date(day: 11))
        #expect(viewModel.weekMeals == [lastSunday])
        #expect(viewModel.canShowNextWeek)
        #expect(viewModel.days.allSatisfy { !$0.isFuture })
    }

    @Test func nextWeekReturnsToTodayButNotBeyond() async {
        let viewModel = makeViewModel()
        await viewModel.previousWeekTapped()

        await viewModel.nextWeekTapped()
        #expect(viewModel.week.start == date(day: 12))
        #expect(viewModel.selectedDay == date(day: 16))

        await viewModel.nextWeekTapped()
        #expect(viewModel.week.start == date(day: 12))
    }

    @Test func scanButtonSendsEvent() {
        var events: [HistoryEvent] = []
        let viewModel = makeViewModel { events.append($0) }

        viewModel.scanTapped()

        #expect(events == [.scanRequested])
    }
}
