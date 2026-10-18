import Foundation
import Testing
@testable import MealKit

struct MealKindTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        return calendar
    }

    private func date(hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 16, hour: hour, minute: 30))!
    }

    @Test(arguments: [
        (4, MealKind.dinner),
        (5, .breakfast),
        (9, .breakfast),
        (10, .lunch),
        (14, .lunch),
        (15, .snack),
        (17, .snack),
        (18, .dinner),
        (23, .dinner)
    ])
    func suggestedKindFollowsTheHour(hour: Int, expected: MealKind) {
        #expect(MealKind.suggested(for: date(hour: hour), calendar: calendar) == expected)
    }

    @Test func freeMealIsLastAndNeverSuggested() {
        #expect(MealKind.allCases.last == .free)
        #expect((0..<24).allSatisfy { MealKind.suggested(for: date(hour: $0), calendar: calendar) != .free })
    }
}
