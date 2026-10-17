/// How a food was prepared. Changes its values a lot (raw vs. fried), so matching respects it.
public enum Preparation: String, CaseIterable, Hashable, Sendable {
    case raw = "cru"
    case cooked = "cozido"
    case grilled = "grelhado"
    case fried = "frito"
    case roasted = "assado"
    case sauteed = "refogado"
}

extension Preparation {

    /// Words that name each preparation, normalized (lowercase, no accents), in both genders.
    public var words: [String] {
        switch self {
        case .raw: ["cru", "crua", "crus", "cruas", "raw"]
        case .cooked: ["cozido", "cozida", "cozidos", "cozidas", "boiled", "cooked"]
        case .grilled: ["grelhado", "grelhada", "grelhados", "grelhadas", "grilled"]
        case .fried: ["frito", "frita", "fritos", "fritas", "fried"]
        case .roasted: ["assado", "assada", "assados", "assadas", "roasted", "baked"]
        case .sauteed: ["refogado", "refogada", "refogados", "refogadas", "sauteed"]
        }
    }
}

/// What the recognition can search a catalog food by.
public struct FoodSearchInfo: Hashable, Sendable {
    /// Normalized names and synonyms, in Portuguese and English ("arroz", "arroz branco", "rice").
    public var terms: [String]
    /// The food's preparation, when it defines the food ("batata cozida" vs. "batata frita").
    public var preparation: Preparation?

    public init(terms: [String], preparation: Preparation? = nil) {
        self.terms = terms
        self.preparation = preparation
    }
}

/// The foods the user can pick when correcting or adding an item.
public struct FoodCatalog: Sendable {

    public let foods: [Food]
    /// Search data per food id. Foods without an entry can still be picked by hand.
    public let searchInfo: [Food.ID: FoodSearchInfo]

    public init(foods: [Food], searchInfo: [Food.ID: FoodSearchInfo] = [:]) {
        self.foods = foods
        self.searchInfo = searchInfo
    }

    public func food(id: Food.ID) -> Food? {
        foods.first { $0.id == id }
    }
}

extension FoodCatalog {

    /// Where the demonstration values come from. Stored with every item saved from this catalog.
    public static let demonstrationSource = "demonstração (valores aproximados, não oficiais)"

    /// A small catalog of common Brazilian foods for development and the MVP demo.
    ///
    /// **Demonstration data.** Values per 100 g are approximate and must not be presented as
    /// official nutrition data. Replace with a sourced base (e.g. TACO, after checking its terms
    /// of use) before release.
    public static let development = FoodCatalog(
        foods: [
            demo("rice-white-cooked", "Arroz branco", "White rice", kcal: 128, protein: 2.5, carbs: 28.1, fat: 0.2),
            demo("chicken-breast-grilled", "Frango grelhado", "Grilled chicken", kcal: 159, protein: 32.0, carbs: 0, fat: 2.5),
            demo("leaf-salad", "Salada de folhas", "Leaf salad", kcal: 11, protein: 1.3, carbs: 1.7, fat: 0.2),
            demo("beans-carioca-cooked", "Feijão carioca", "Pinto beans", kcal: 76, protein: 4.8, carbs: 13.6, fat: 0.5),
            demo("beef-grilled", "Carne bovina grelhada", "Grilled beef", kcal: 219, protein: 35.9, carbs: 0, fat: 7.3),
            demo("egg-boiled", "Ovo cozido", "Boiled egg", kcal: 146, protein: 13.3, carbs: 0.6, fat: 9.5),
            demo("potato-boiled", "Batata cozida", "Boiled potato", kcal: 52, protein: 1.2, carbs: 11.9, fat: 0),
            demo("pasta-cooked", "Macarrão cozido", "Cooked pasta", kcal: 157, protein: 5.8, carbs: 30.9, fat: 0.9),
            demo("tomato", "Tomate", "Tomato", kcal: 15, protein: 1.1, carbs: 3.1, fat: 0.2),
            demo("banana", "Banana", "Banana", kcal: 98, protein: 1.3, carbs: 26.0, fat: 0.1),
            demo("french-bread", "Pão francês", "French bread", kcal: 300, protein: 8.0, carbs: 58.6, fat: 3.1),
            demo("minas-cheese", "Queijo minas frescal", "Fresh white cheese", kcal: 264, protein: 17.4, carbs: 3.2, fat: 20.2)
        ],
        searchInfo: [
            "rice-white-cooked": FoodSearchInfo(terms: ["arroz", "arroz branco", "white rice", "rice"], preparation: .cooked),
            "chicken-breast-grilled": FoodSearchInfo(terms: ["frango", "peito de frango", "file de frango", "chicken", "chicken breast"], preparation: .grilled),
            "leaf-salad": FoodSearchInfo(terms: ["salada", "salada de folhas", "alface", "folhas", "rucula", "salad", "lettuce", "greens"], preparation: .raw),
            "beans-carioca-cooked": FoodSearchInfo(terms: ["feijao", "feijao carioca", "beans", "pinto beans"], preparation: .cooked),
            "beef-grilled": FoodSearchInfo(terms: ["carne", "carne bovina", "bife", "beef", "steak"], preparation: .grilled),
            "egg-boiled": FoodSearchInfo(terms: ["ovo", "ovo cozido", "egg", "boiled egg"], preparation: .cooked),
            "potato-boiled": FoodSearchInfo(terms: ["batata", "batata cozida", "potato"], preparation: .cooked),
            "pasta-cooked": FoodSearchInfo(terms: ["macarrao", "massa", "espaguete", "pasta", "spaghetti"], preparation: .cooked),
            "tomato": FoodSearchInfo(terms: ["tomate", "tomato"], preparation: .raw),
            "banana": FoodSearchInfo(terms: ["banana"], preparation: .raw),
            "french-bread": FoodSearchInfo(terms: ["pao", "pao frances", "bread", "french bread"]),
            "minas-cheese": FoodSearchInfo(terms: ["queijo", "queijo minas", "queijo branco", "cheese", "white cheese"])
        ]
    )

    private static func demo(
        _ id: String, _ namePT: String, _ nameEN: String,
        kcal: Double, protein: Double, carbs: Double, fat: Double
    ) -> Food {
        Food(id: id, namePT: namePT, nameEN: nameEN,
             per100g: Macros(kcal: kcal, protein: protein, carbs: carbs, fat: fat),
             source: demonstrationSource)
    }
}
