import Foundation

extension MealKind {

    /// The meal type as the user reads it ("Almoço", "Lunch").
    public var localizedName: String {
        switch self {
        case .breakfast:
            String(localized: "mealKind.breakfast", defaultValue: "Café da manhã", bundle: .module, comment: "Meal type")
        case .lunch:
            String(localized: "mealKind.lunch", defaultValue: "Almoço", bundle: .module, comment: "Meal type")
        case .snack:
            String(localized: "mealKind.snack", defaultValue: "Lanche", bundle: .module, comment: "Meal type")
        case .dinner:
            String(localized: "mealKind.dinner", defaultValue: "Jantar", bundle: .module, comment: "Meal type")
        }
    }
}

extension Calendar {
    /// The week that contains `date`, starting on this calendar's first weekday.
    public func weekInterval(containing date: Date) -> DateInterval {
        if let week = dateInterval(of: .weekOfYear, for: date) {
            return week
        }
        let start = startOfDay(for: date)
        return DateInterval(start: start, duration: 7 * 86_400)
    }
}
