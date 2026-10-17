import Foundation
import MealKit
import Observation

/// State and actions of "Vamos conferir?": the suggested foods, their weights and the meal type.
@MainActor
@Observable
public final class ReviewViewModel {

    public var mealKind: MealKind
    public private(set) var portions: [FoodPortion]
    /// The item open in the edit sheet, if any.
    public var editor: PortionEditor?
    public private(set) var isSaving = false
    public var showsSaveError = false

    public let catalog: FoodCatalog
    public let photo: Data?

    private let date: Date
    private let store: any MealStoring
    private var savedMeal: Meal?
    private let onEvent: @MainActor (ReviewEvent) -> Void

    /// - Parameters:
    ///   - suggestions: Foods from the analysis. Ids missing from the catalog are dropped.
    ///   - date: When the meal is being logged; picks the default meal type.
    init(
        suggestions: [FoodSuggestion],
        photo: Data?,
        catalog: FoodCatalog,
        store: any MealStoring,
        date: Date,
        calendar: Calendar = .current,
        onEvent: @escaping @MainActor (ReviewEvent) -> Void
    ) {
        self.portions = suggestions.compactMap { suggestion in
            catalog.food(id: suggestion.foodID).map { FoodPortion(food: $0, grams: suggestion.grams) }
        }
        self.mealKind = .suggested(for: date, calendar: calendar)
        self.catalog = catalog
        self.photo = photo
        self.date = date
        self.store = store
        self.onEvent = onEvent
    }

    public var totals: NutritionTotals { portions.totals }
    public var totalGrams: Int { portions.totalGrams }
    public var canSave: Bool { !portions.isEmpty && !isSaving && savedMeal == nil }

    public func portionTapped(_ portion: FoodPortion) {
        editor = PortionEditor(mode: .edit(portion.id), food: portion.food, grams: portion.grams)
    }

    public func addFoodTapped() {
        guard let first = catalog.foods.first else { return }
        editor = PortionEditor(mode: .add, food: first, grams: 100)
    }

    public func apply(_ editor: PortionEditor) {
        guard editor.canApply else { return }
        switch editor.mode {
        case .add:
            portions.append(FoodPortion(food: editor.food, grams: editor.grams))
        case .edit(let id):
            if let index = portions.firstIndex(where: { $0.id == id }) {
                portions[index].food = editor.food
                portions[index].grams = editor.grams
            }
        }
        self.editor = nil
    }

    public func remove(_ id: FoodPortion.ID) {
        portions.removeAll { $0.id == id }
        editor = nil
    }

    public func cancelEditing() {
        editor = nil
    }

    /// Saves the meal to the diary. On failure the user stays here and sees an alert.
    public func saveTapped() async {
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }

        let draft = MealDraft(kind: mealKind, portions: portions, photo: photo, date: date)
        do {
            let meal = try await store.save(draft)
            savedMeal = meal
            onEvent(.saved(meal))
        } catch {
            showsSaveError = true
        }
    }
}
