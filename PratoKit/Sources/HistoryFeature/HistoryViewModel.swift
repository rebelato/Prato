import Foundation
import MealKit
import Observation

/// One day in the week strip.
public struct HistoryDay: Identifiable, Hashable, Sendable {
    /// Midnight at the start of the day.
    public let date: Date
    public let mealCount: Int
    /// Days after today can't be selected.
    public let isFuture: Bool

    public var id: Date { date }
}

/// State and actions of Histórico: one week at a time, with a selected day.
@MainActor
@Observable
public final class HistoryViewModel {

    /// The week on screen, from its first midnight to the next week's.
    public private(set) var week: DateInterval
    /// Midnight of the selected day.
    public private(set) var selectedDay: Date
    /// Every meal of `week`, oldest first.
    public private(set) var weekMeals: [Meal] = []
    /// False until the first load finishes, so the empty state doesn't flash.
    public private(set) var hasLoaded = false
    /// The calendar sheet that jumps to any past day.
    public var isDayPickerPresented = false

    private let store: any MealStoring
    private let now: () -> Date
    private let calendar: Calendar
    private let onEvent: @MainActor (HistoryEvent) -> Void

    public init(
        store: any MealStoring,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current,
        onEvent: @escaping @MainActor (HistoryEvent) -> Void
    ) {
        self.store = store
        self.now = now
        self.calendar = calendar
        self.onEvent = onEvent
        let today = now()
        self.week = calendar.weekInterval(containing: today)
        self.selectedDay = calendar.startOfDay(for: today)
    }

    private var today: Date { calendar.startOfDay(for: now()) }

    /// The last day the calendar offers.
    public var lastSelectableDay: Date { today }

    // MARK: Week strip

    public var days: [HistoryDay] {
        let today = self.today
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: week.start) else { return nil }
            return HistoryDay(
                date: date,
                mealCount: weekMeals.filter { calendar.isDate($0.date, inSameDayAs: date) }.count,
                isFuture: date > today
            )
        }
    }

    /// The last day of the week, for labels like "12–18 de outubro".
    public var weekLastDay: Date {
        calendar.date(byAdding: .day, value: 6, to: week.start) ?? week.start
    }

    /// The next week can be shown only if it has started.
    public var canShowNextWeek: Bool {
        week.end <= today
    }

    // MARK: Totals

    public var weekTotals: NutritionTotals { weekMeals.totals }

    /// Days of the week with at least one meal.
    public var loggedDayCount: Int {
        Set(weekMeals.map { calendar.startOfDay(for: $0.date) }).count
    }

    /// Calories per logged day, rounded; `nil` when nothing was logged.
    public var averageKcalPerLoggedDay: Int? {
        guard loggedDayCount > 0 else { return nil }
        return Int((Double(weekTotals.kcal) / Double(loggedDayCount)).rounded())
    }

    // MARK: Selected day

    public var selectedDayMeals: [Meal] {
        weekMeals.filter { calendar.isDate($0.date, inSameDayAs: selectedDay) }
    }

    // MARK: Actions

    /// Reads the week's meals. A result for a week the user already left is dropped,
    /// so tapping through weeks quickly never shows another week's meals.
    public func load() async {
        let requested = week
        let meals = try? await store.meals(in: requested)
        guard week == requested else { return }
        if let meals {
            weekMeals = meals
        }
        hasLoaded = true
    }

    public func select(_ day: HistoryDay) {
        guard !day.isFuture else { return }
        selectedDay = day.date
    }

    public func previousWeekTapped() async {
        await show(weekContaining: calendar.date(byAdding: .day, value: -7, to: week.start) ?? week.start)
    }

    public func nextWeekTapped() async {
        guard canShowNextWeek else { return }
        await show(weekContaining: week.end)
    }

    public func scanTapped() {
        onEvent(.scanRequested)
    }

    /// The week label in the middle of the navigator opens the calendar.
    public func weekTitleTapped() {
        isDayPickerPresented = true
    }

    /// A day chosen in the calendar: closes it and shows that day, in its week.
    /// Days after today fall back to today.
    public func dayPicked(_ date: Date) async {
        isDayPickerPresented = false
        let day = min(calendar.startOfDay(for: date), today)
        guard !week.contains(day) else {
            selectedDay = day
            return
        }
        await show(weekContaining: day, selecting: day)
    }

    /// Moves to the week of `date` and selects `day`; without one, today if it's in that week,
    /// else the week's last day.
    private func show(weekContaining date: Date, selecting day: Date? = nil) async {
        week = calendar.weekInterval(containing: date)
        let today = self.today
        selectedDay = day ?? (week.contains(today) ? today : weekLastDay)
        weekMeals = []
        await load()
    }
}
