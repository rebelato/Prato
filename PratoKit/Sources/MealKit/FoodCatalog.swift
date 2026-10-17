/// The foods the user can pick when correcting or adding an item.
public struct FoodCatalog: Sendable {

    public let foods: [Food]

    public init(foods: [Food]) {
        self.foods = foods
    }

    public func food(id: Food.ID) -> Food? {
        foods.first { $0.id == id }
    }
}

extension FoodCatalog {

    /// A small catalog for development and previews.
    ///
    /// Values per 100 g are approximate, from public composition tables. They will be
    /// replaced by the real nutrition base once the identification approach is chosen.
    public static let development = FoodCatalog(foods: [
        Food(id: "rice-white-cooked", namePT: "Arroz branco", nameEN: "White rice",
             per100g: Macros(kcal: 128, protein: 2.5, carbs: 28.1, fat: 0.2)),
        Food(id: "chicken-breast-grilled", namePT: "Frango grelhado", nameEN: "Grilled chicken",
             per100g: Macros(kcal: 159, protein: 32.0, carbs: 0, fat: 2.5)),
        Food(id: "leaf-salad", namePT: "Salada de folhas", nameEN: "Leaf salad",
             per100g: Macros(kcal: 11, protein: 1.3, carbs: 1.7, fat: 0.2)),
        Food(id: "beans-carioca-cooked", namePT: "Feijão carioca", nameEN: "Pinto beans",
             per100g: Macros(kcal: 76, protein: 4.8, carbs: 13.6, fat: 0.5)),
        Food(id: "beef-grilled", namePT: "Carne bovina grelhada", nameEN: "Grilled beef",
             per100g: Macros(kcal: 219, protein: 35.9, carbs: 0, fat: 7.3)),
        Food(id: "egg-boiled", namePT: "Ovo cozido", nameEN: "Boiled egg",
             per100g: Macros(kcal: 146, protein: 13.3, carbs: 0.6, fat: 9.5)),
        Food(id: "potato-boiled", namePT: "Batata cozida", nameEN: "Boiled potato",
             per100g: Macros(kcal: 52, protein: 1.2, carbs: 11.9, fat: 0)),
        Food(id: "pasta-cooked", namePT: "Macarrão cozido", nameEN: "Cooked pasta",
             per100g: Macros(kcal: 157, protein: 5.8, carbs: 30.9, fat: 0.9)),
        Food(id: "tomato", namePT: "Tomate", nameEN: "Tomato",
             per100g: Macros(kcal: 15, protein: 1.1, carbs: 3.1, fat: 0.2)),
        Food(id: "banana", namePT: "Banana", nameEN: "Banana",
             per100g: Macros(kcal: 98, protein: 1.3, carbs: 26.0, fat: 0.1)),
        Food(id: "french-bread", namePT: "Pão francês", nameEN: "French bread",
             per100g: Macros(kcal: 300, protein: 8.0, carbs: 58.6, fat: 3.1)),
        Food(id: "minas-cheese", namePT: "Queijo minas frescal", nameEN: "Fresh white cheese",
             per100g: Macros(kcal: 264, protein: 17.4, carbs: 3.2, fat: 20.2))
    ])
}
