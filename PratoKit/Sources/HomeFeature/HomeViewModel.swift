import Foundation
import MealKit
import Observation

/// State and actions of Hoje.
///
/// It never navigates: taps become ``HomeEvent``s sent through `onEvent`,
/// and the coordinator decides what to show.
@MainActor
@Observable
public final class HomeViewModel {

    /// Today's meals, oldest first.
    public private(set) var todayMeals: [Meal] = []
    /// False until the first load finishes, so the empty state doesn't flash on launch.
    public private(set) var hasLoaded = false

    private let store: any MealStoring
    private let now: () -> Date
    private let calendar: Calendar
    private let onEvent: @MainActor (HomeEvent) -> Void

    public init(
        store: any MealStoring,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current,
        onEvent: @escaping @MainActor (HomeEvent) -> Void
    ) {
        self.store = store
        self.now = now
        self.calendar = calendar
        self.onEvent = onEvent
    }

    public var todayTotals: NutritionTotals { todayMeals.totals }

    /// Reads today's meals from the diary. Called when Hoje appears and after a meal is saved.
    /// A failed read keeps what was already on screen.
    public func load() async {
        let today = calendar.dayInterval(containing: now())
        if let meals = try? await store.meals(in: today) {
            todayMeals = meals
        }
        hasLoaded = true
    }

    public func scanTapped() {
        onEvent(.scanRequested(.camera))
    }

    public func galleryTapped() {
        onEvent(.scanRequested(.gallery))
    }
}
