import Foundation

/// Which meal of the day a record belongs to.
public enum MealKind: String, CaseIterable, Hashable, Sendable {
    case breakfast
    case lunch
    case snack
    case dinner

    /// The meal people usually eat at `date`'s hour: breakfast 5–10h, lunch 10–15h,
    /// snack 15–18h, dinner otherwise.
    public static func suggested(for date: Date, calendar: Calendar = .current) -> MealKind {
        switch calendar.component(.hour, from: date) {
        case 5..<10: .breakfast
        case 10..<15: .lunch
        case 15..<18: .snack
        default: .dinner
        }
    }
}

/// A meal reviewed by the user and ready to be saved.
public struct MealDraft: Hashable, Sendable {
    public var kind: MealKind
    public var portions: [FoodPortion]
    /// JPEG of the plate, when the meal was logged from a photo.
    public var photo: Data?
    public var date: Date

    public init(kind: MealKind, portions: [FoodPortion], photo: Data?, date: Date) {
        self.kind = kind
        self.portions = portions
        self.photo = photo
        self.date = date
    }

    public var totals: NutritionTotals { portions.totals }
}
