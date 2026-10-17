import Foundation

/// A meal that was saved to the diary.
public struct Meal: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var kind: MealKind
    public var date: Date
    public var portions: [FoodPortion]
    /// JPEG of the plate, when the meal was logged from a photo.
    public var photo: Data?

    public init(id: UUID = UUID(), kind: MealKind, date: Date, portions: [FoodPortion], photo: Data?) {
        self.id = id
        self.kind = kind
        self.date = date
        self.portions = portions
        self.photo = photo
    }

    public init(id: UUID = UUID(), draft: MealDraft) {
        self.init(id: id, kind: draft.kind, date: draft.date, portions: draft.portions, photo: draft.photo)
    }

    public var totals: NutritionTotals { portions.totals }
}

extension Sequence where Element == Meal {
    /// The sum of each meal's shown values.
    public var totals: NutritionTotals {
        reduce(.zero) { $0 + $1.totals }
    }
}

/// Where the diary is kept.
///
/// Each item stores a copy of its food's values, so a later change to the nutrition base
/// never alters a meal that was already saved.
public protocol MealStoring: Sendable {
    /// Saves the reviewed meal and returns it as stored.
    func save(_ draft: MealDraft) async throws -> Meal

    /// Meals whose date falls in `interval` (start included, end excluded), oldest first.
    func meals(in interval: DateInterval) async throws -> [Meal]
}

/// Keeps meals in memory. For previews and tests.
public actor InMemoryMealStore: MealStoring {

    private var stored: [Meal]

    public init(meals: [Meal] = []) {
        self.stored = meals
    }

    public func save(_ draft: MealDraft) async throws -> Meal {
        let meal = Meal(draft: draft)
        stored.append(meal)
        return meal
    }

    public func meals(in interval: DateInterval) async throws -> [Meal] {
        stored
            .filter { $0.date >= interval.start && $0.date < interval.end }
            .sorted { $0.date < $1.date }
    }
}

extension Calendar {
    /// The day that contains `date`, from midnight to the next midnight.
    public func dayInterval(containing date: Date) -> DateInterval {
        let start = startOfDay(for: date)
        let end = self.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        return DateInterval(start: start, end: end)
    }
}
