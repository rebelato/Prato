import Foundation
import MealKit
import Testing
@testable import MealStore

struct SwiftDataMealStoreTests {

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        return calendar
    }()

    private func date(day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))!
    }

    private func draft(_ kind: MealKind, at date: Date, foods: [(Food.ID, Int)] = [("rice-white-cooked", 120)]) -> MealDraft {
        let portions = foods.map { id, grams in
            FoodPortion(food: FoodCatalog.development.food(id: id)!, grams: grams)
        }
        return MealDraft(kind: kind, portions: portions, photo: Data([1, 2, 3]), date: date)
    }

    @Test func savedMealComesBackTheSame() async throws {
        let store = try SwiftDataMealStore.make(inMemory: true)
        let original = draft(.lunch, at: date(day: 16, hour: 12), foods: [
            ("rice-white-cooked", 120), ("chicken-breast-grilled", 150), ("leaf-salad", 60)
        ])

        let saved = try await store.save(original)
        let fetched = try await store.meals(in: calendar.dayInterval(containing: original.date))

        #expect(fetched == [saved])
        #expect(saved.kind == .lunch)
        #expect(saved.portions == original.portions)
        #expect(saved.photo == original.photo)
        #expect(saved.totals == original.totals)
    }

    @Test func freeMealKeepsItsKind() async throws {
        let store = try SwiftDataMealStore.make(inMemory: true)

        let saved = try await store.save(draft(.free, at: date(day: 16, hour: 21)))
        let fetched = try await store.meals(in: calendar.dayInterval(containing: saved.date))

        #expect(fetched.map(\.kind) == [.free])
    }

    @Test func itemsKeepTheirOrder() async throws {
        let store = try SwiftDataMealStore.make(inMemory: true)
        let ids = ["tomato", "egg-boiled", "rice-white-cooked", "banana", "beef-grilled"]

        let saved = try await store.save(draft(.dinner, at: date(day: 16, hour: 20), foods: ids.map { ($0, 50) }))
        let fetched = try #require(try await store.meals(in: calendar.dayInterval(containing: saved.date)).first)

        #expect(fetched.portions.map(\.food.id) == ids)
    }

    @Test func onlyMealsOfTheDayAreReturnedOldestFirst() async throws {
        let store = try SwiftDataMealStore.make(inMemory: true)
        _ = try await store.save(draft(.dinner, at: date(day: 15, hour: 23)))
        let dinner = try await store.save(draft(.dinner, at: date(day: 16, hour: 20)))
        let breakfast = try await store.save(draft(.breakfast, at: date(day: 16, hour: 8)))
        _ = try await store.save(draft(.breakfast, at: date(day: 17, hour: 0)))

        let today = try await store.meals(in: calendar.dayInterval(containing: date(day: 16, hour: 12)))

        #expect(today.map(\.id) == [breakfast.id, dinner.id])
    }

    @Test func savedValuesDoNotDependOnTheCatalog() async throws {
        let store = try SwiftDataMealStore.make(inMemory: true)
        let custom = Food(id: "rice-white-cooked", namePT: "Arroz antigo", nameEN: "Old rice",
                          per100g: Macros(kcal: 999, protein: 1, carbs: 1, fat: 1))
        let original = MealDraft(kind: .lunch, portions: [FoodPortion(food: custom, grams: 100)], photo: nil, date: date(day: 16, hour: 12))

        let saved = try await store.save(original)

        #expect(saved.portions.first?.food == custom)
        #expect(saved.totals.kcal == 999)
    }
}

struct DayIntervalTests {

    @Test func dayGoesFromMidnightToMidnight() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        let noon = calendar.date(from: DateComponents(year: 2026, month: 10, day: 16, hour: 12))!

        let day = calendar.dayInterval(containing: noon)

        #expect(day.start == calendar.date(from: DateComponents(year: 2026, month: 10, day: 16)))
        #expect(day.end == calendar.date(from: DateComponents(year: 2026, month: 10, day: 17)))
    }
}
