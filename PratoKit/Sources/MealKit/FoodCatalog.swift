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
            demo("minas-cheese", "Queijo minas frescal", "Fresh white cheese", kcal: 264, protein: 17.4, carbs: 3.2, fat: 20.2),
            demo("rice-brown-cooked", "Arroz integral", "Brown rice", kcal: 124, protein: 2.6, carbs: 25.8, fat: 1.0),
            demo("beans-black-cooked", "Feijão preto", "Black beans", kcal: 77, protein: 4.5, carbs: 14.0, fat: 0.5),
            demo("beef-strips-sauteed", "Iscas de carne refogadas", "Sautéed beef strips", kcal: 200, protein: 29.0, carbs: 1.0, fat: 8.5),
            demo("beef-pot-roast", "Carne de panela", "Pot roast beef", kcal: 215, protein: 27.3, carbs: 0, fat: 10.9),
            demo("ground-beef-sauteed", "Carne moída refogada", "Sautéed ground beef", kcal: 212, protein: 26.7, carbs: 0, fat: 10.9),
            demo("chicken-shredded", "Frango desfiado", "Shredded chicken", kcal: 163, protein: 31.5, carbs: 0, fat: 3.2),
            demo("sausage-grilled", "Linguiça grelhada", "Grilled sausage", kcal: 296, protein: 23.2, carbs: 0, fat: 21.9),
            demo("egg-fried", "Ovo frito", "Fried egg", kcal: 240, protein: 15.6, carbs: 1.2, fat: 18.6),
            demo("potato-fried", "Batata frita", "French fries", kcal: 267, protein: 5.0, carbs: 35.6, fat: 13.1),
            demo("cassava-boiled", "Mandioca cozida", "Boiled cassava", kcal: 125, protein: 0.6, carbs: 30.1, fat: 0.3),
            demo("farofa", "Farofa", "Toasted cassava flour", kcal: 406, protein: 2.1, carbs: 80.3, fat: 9.1),
            demo("collard-greens-sauteed", "Couve refogada", "Sautéed collard greens", kcal: 90, protein: 1.7, carbs: 8.7, fat: 6.6),
            demo("cheese-bread", "Pão de queijo", "Cheese bread", kcal: 363, protein: 5.1, carbs: 34.2, fat: 24.6)
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
            "minas-cheese": FoodSearchInfo(terms: ["queijo", "queijo minas", "queijo branco", "cheese", "white cheese"]),
            "rice-brown-cooked": FoodSearchInfo(terms: ["arroz integral", "brown rice"], preparation: .cooked),
            "beans-black-cooked": FoodSearchInfo(terms: ["feijao preto", "black beans"], preparation: .cooked),
            "beef-strips-sauteed": FoodSearchInfo(terms: ["iscas", "iscas de carne", "tiras de carne", "carne em tiras", "carne acebolada", "beef strips"], preparation: .sauteed),
            "beef-pot-roast": FoodSearchInfo(terms: ["carne de panela", "carne cozida", "carne ensopada", "picadinho", "pot roast", "beef stew"], preparation: .cooked),
            "ground-beef-sauteed": FoodSearchInfo(terms: ["carne moida", "ground beef"], preparation: .sauteed),
            "chicken-shredded": FoodSearchInfo(terms: ["frango desfiado", "shredded chicken"], preparation: .cooked),
            "sausage-grilled": FoodSearchInfo(terms: ["linguica", "sausage"], preparation: .grilled),
            "egg-fried": FoodSearchInfo(terms: ["ovo frito", "fried egg"], preparation: .fried),
            "potato-fried": FoodSearchInfo(terms: ["batata frita", "fritas", "french fries", "fries"], preparation: .fried),
            "cassava-boiled": FoodSearchInfo(terms: ["mandioca", "aipim", "macaxeira", "cassava", "yuca"], preparation: .cooked),
            "farofa": FoodSearchInfo(terms: ["farofa", "cassava flour"]),
            "collard-greens-sauteed": FoodSearchInfo(terms: ["couve", "couve refogada", "collard greens", "kale"], preparation: .sauteed),
            "cheese-bread": FoodSearchInfo(terms: ["pao de queijo", "cheese bread"], preparation: .roasted)
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
