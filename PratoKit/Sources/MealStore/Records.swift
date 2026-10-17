import Foundation
import MealKit
import SwiftData

/// A saved meal as SwiftData keeps it.
@Model
final class MealRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    /// `MealKind.rawValue`. Stored as text so predicates and future cases stay simple.
    var kindRaw: String
    @Attribute(.externalStorage) var photo: Data?
    @Relationship(deleteRule: .cascade, inverse: \FoodItemRecord.meal)
    var items: [FoodItemRecord] = []

    init(id: UUID, date: Date, kindRaw: String, photo: Data?) {
        self.id = id
        self.date = date
        self.kindRaw = kindRaw
        self.photo = photo
    }
}

/// One food of a saved meal, with a copy of the food's values at the time it was saved.
@Model
final class FoodItemRecord {
    /// Order on the plate; SwiftData does not keep the order of a to-many relationship.
    var position: Int
    var portionID: UUID
    var foodID: String
    var namePT: String
    var nameEN: String
    var grams: Int
    var kcalPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var meal: MealRecord?

    init(position: Int, portion: FoodPortion) {
        self.position = position
        self.portionID = portion.id
        self.foodID = portion.food.id
        self.namePT = portion.food.namePT
        self.nameEN = portion.food.nameEN
        self.grams = portion.grams
        self.kcalPer100g = portion.food.per100g.kcal
        self.proteinPer100g = portion.food.per100g.protein
        self.carbsPer100g = portion.food.per100g.carbs
        self.fatPer100g = portion.food.per100g.fat
    }
}

extension MealRecord {
    var meal: Meal {
        Meal(
            id: id,
            kind: MealKind(rawValue: kindRaw) ?? .snack,
            date: date,
            portions: items.sorted { $0.position < $1.position }.map(\.portion),
            photo: photo
        )
    }
}

extension FoodItemRecord {
    var portion: FoodPortion {
        FoodPortion(
            id: portionID,
            food: Food(
                id: foodID,
                namePT: namePT,
                nameEN: nameEN,
                per100g: Macros(kcal: kcalPer100g, protein: proteinPer100g, carbs: carbsPer100g, fat: fatPer100g)
            ),
            grams: grams
        )
    }
}
