import Foundation
import MealKit
import SwiftData

/// The diary on disk, in SwiftData.
///
/// Records never leave the actor: callers get `Meal` values, which are `Sendable`.
@ModelActor
public actor SwiftDataMealStore: MealStoring {

    public func save(_ draft: MealDraft) throws -> Meal {
        let record = MealRecord(id: UUID(), date: draft.date, kindRaw: draft.kind.rawValue, photo: draft.photo)
        modelContext.insert(record)
        for (position, portion) in draft.portions.enumerated() {
            let item = FoodItemRecord(position: position, portion: portion)
            modelContext.insert(item)
            // Both sides are in the context before linking; SwiftData fills in `item.meal`.
            record.items.append(item)
        }
        try modelContext.save()
        return record.meal
    }

    public func meals(in interval: DateInterval) throws -> [Meal] {
        let start = interval.start
        let end = interval.end
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate { $0.date >= start && $0.date < end },
            sortBy: [SortDescriptor(\.date)]
        )
        return try modelContext.fetch(descriptor).map(\.meal)
    }
}

extension SwiftDataMealStore {

    /// The models this store needs in its container.
    public static var schema: Schema {
        Schema([MealRecord.self, FoodItemRecord.self])
    }

    /// A store backed by the app's database, or by memory when `inMemory` is true (tests, previews).
    public static func make(inMemory: Bool = false) throws -> SwiftDataMealStore {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return SwiftDataMealStore(modelContainer: container)
    }
}
