import Foundation

/// One topping ingredient for a single ~12″ pizza.
struct ToppingItem: Hashable {
    let name: String
    let gramsPerPizza: Double
    /// Most toppings scale with pizza size; a few (herbs) are roughly fixed.
    let scalesWithSize: Bool

    init(_ name: String, _ gramsPerPizza: Double, scales: Bool = true) {
        self.name = name
        self.gramsPerPizza = gramsPerPizza
        self.scalesWithSize = scales
    }
}

enum RecipeCategory { case savoury, dessert }

/// A traditional topping recipe for a given style.
struct PizzaRecipe: Identifiable, Hashable {
    let id: String
    let name: String
    let toppings: [ToppingItem]
    /// How to lay it up (used in the timeline and planner).
    let assembly: String
    var category: RecipeCategory = .savoury
}

/// One selected pizza with its toppings in the order they go on.
struct PizzaToppingPlan: Identifiable {
    let id: String
    let title: String          // e.g. "2× Margherita"
    let layers: [ShoppingLine] // ordered, per single pizza
}

/// One line of an aggregated shopping list.
struct ShoppingLine: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let grams: Double
    /// Optional packaging hint, e.g. "≈ 2 × 1 kg bags".
    let hint: String?
    /// How many of the selected pizzas use this topping (counting duplicates).
    var pizzaCount: Int = 0
}

enum RecipeCatalog {

    /// Sweet options available for every style.
    private static let desserts: [PizzaRecipe] = [
        .init(id: "nutella-banana", name: "Nutella & Banana",
              toppings: [.init("Nutella", 80), .init("Banana", 60), .init("Maple syrup", 15)],
              assembly: "Bake the base plain, then spread Nutella, add sliced banana and drizzle with maple syrup.",
              category: .dessert),
        .init(id: "cinnamon-sugar", name: "Cinnamon Sugar",
              toppings: [.init("Butter", 30), .init("Cinnamon sugar", 25)],
              assembly: "Brush the just-baked base with melted butter and dust generously with cinnamon sugar.",
              category: .dessert),
    ]

    /// Traditional recipes available for each style id. Desserts only suit the
    /// usual round/pan pizzas — not the savoury-only Sicilian or focaccia.
    static func recipes(for styleID: String) -> [PizzaRecipe] {
        let savouryOnly: Set<String> = ["sfincione", "focaccia"]
        return savoury(for: styleID) + (savouryOnly.contains(styleID) ? [] : desserts)
    }

    private static func savoury(for styleID: String) -> [PizzaRecipe] {
        switch styleID {
        case "neapolitan", "neapolitan-contemporary":
            return [
                .init(id: "margherita", name: "Margherita",
                      toppings: [.init("San Marzano tomato", 80), .init("Fior di latte mozzarella", 100),
                                 .init("Fresh basil", 3, scales: false), .init("Extra-virgin olive oil", 5)],
                      assembly: "Sauce, then torn mozzarella, a drizzle of oil. Add basil after baking."),
                .init(id: "marinara", name: "Marinara",
                      toppings: [.init("San Marzano tomato", 90), .init("Garlic", 5),
                                 .init("Dried oregano", 1, scales: false), .init("Extra-virgin olive oil", 6)],
                      assembly: "Sauce, sliced garlic and oregano, a good drizzle of oil. No cheese."),
                .init(id: "bufala", name: "Bufala",
                      toppings: [.init("San Marzano tomato", 80), .init("Buffalo mozzarella", 110),
                                 .init("Fresh basil", 3, scales: false), .init("Extra-virgin olive oil", 5)],
                      assembly: "Sauce first; add buffalo mozzarella partway through baking so it doesn't weep."),
                .init(id: "diavola", name: "Diavola",
                      toppings: [.init("San Marzano tomato", 80), .init("Fior di latte mozzarella", 100),
                                 .init("Spicy salami", 45)],
                      assembly: "Sauce, then mozzarella, then the salami."),
                .init(id: "diavola-acciughe", name: "Diavola with anchovies",
                      toppings: [.init("San Marzano tomato", 80), .init("Fior di latte mozzarella", 100),
                                 .init("Spicy salami", 45), .init("Anchovy", 15)],
                      assembly: "Sauce, mozzarella, salami and anchovies — salty heat."),
                .init(id: "capricciosa", name: "Capricciosa",
                      toppings: [.init("San Marzano tomato", 80), .init("Fior di latte mozzarella", 100),
                                 .init("Ham", 40), .init("Mushrooms", 40), .init("Artichokes", 40),
                                 .init("Black olives", 20)],
                      assembly: "Sauce, mozzarella, then ham, mushrooms, artichokes and olives in quarters."),
                .init(id: "romagnola", name: "Romagnola",
                      toppings: [.init("San Marzano tomato", 80), .init("Fior di latte mozzarella", 90),
                                 .init("Prosciutto crudo", 40), .init("Rocket", 20, scales: false),
                                 .init("Parmesan shavings", 20)],
                      assembly: "Bake with sauce & mozzarella; after baking add prosciutto, rocket and parmesan."),
                .init(id: "neapolitan-prosciutto", name: "Prosciutto & Rocket",
                      toppings: [.init("San Marzano tomato", 80), .init("Fior di latte mozzarella", 100),
                                 .init("Prosciutto", 40), .init("Rocket", 20, scales: false),
                                 .init("Parmesan shavings", 15)],
                      assembly: "Bake with sauce & mozzarella; after baking pile on prosciutto, rocket and parmesan."),
                .init(id: "hawaiian-omg", name: "Hawaiian 🍍 (OMG pineapple)",
                      toppings: [.init("San Marzano tomato", 80), .init("Fior di latte mozzarella", 100),
                                 .init("Ham", 60), .init("Pineapple (lots!)", 90)],
                      assembly: "Sauce, mozzarella, ham — then pile on the pineapple. No regrets. 🍍"),
            ]
        case "newyork":
            return [
                .init(id: "ny-cheese", name: "Cheese",
                      toppings: [.init("Tomato sauce", 90), .init("Low-moisture mozzarella", 120)],
                      assembly: "Sauce, then a generous layer of grated mozzarella."),
                .init(id: "ny-pepperoni", name: "Pepperoni",
                      toppings: [.init("Tomato sauce", 90), .init("Low-moisture mozzarella", 120), .init("Pepperoni", 50)],
                      assembly: "Sauce, then mozzarella, then pepperoni on top."),
                .init(id: "ny-prosciutto", name: "Prosciutto",
                      toppings: [.init("Tomato sauce", 90), .init("Low-moisture mozzarella", 110),
                                 .init("Prosciutto", 45), .init("Rocket", 20, scales: false)],
                      assembly: "Bake with sauce & mozzarella; after baking pile on prosciutto and rocket."),
                .init(id: "ny-hawaiian", name: "Hawaiian",
                      toppings: [.init("Tomato sauce", 90), .init("Low-moisture mozzarella", 110),
                                 .init("Ham", 60), .init("Pineapple", 50)],
                      assembly: "Sauce, mozzarella, then ham and pineapple."),
            ]
        case "roman":
            return [
                .init(id: "rom-margherita", name: "Margherita",
                      toppings: [.init("Tomato", 70), .init("Fior di latte mozzarella", 90), .init("Fresh basil", 3, scales: false)],
                      assembly: "Thin sauce, light mozzarella; basil after baking."),
                .init(id: "rom-capricciosa", name: "Capricciosa",
                      toppings: [.init("Tomato", 70), .init("Mozzarella", 90), .init("Ham", 40),
                                 .init("Mushrooms", 40), .init("Artichokes", 40), .init("Black olives", 20)],
                      assembly: "Sauce, mozzarella, then the toppings in quarters."),
                .init(id: "rom-quattro", name: "Quattro Formaggi",
                      toppings: [.init("Mozzarella", 60), .init("Gorgonzola", 40), .init("Fontina", 40), .init("Parmesan", 20)],
                      assembly: "No tomato — scatter the four cheeses evenly."),
                .init(id: "rom-prosciutto", name: "Prosciutto & Rocket",
                      toppings: [.init("Tomato", 70), .init("Fior di latte mozzarella", 85),
                                 .init("Prosciutto", 35), .init("Rocket", 15, scales: false)],
                      assembly: "Thin sauce & light mozzarella; after baking add prosciutto and rocket."),
            ]
        case "detroit":
            return [
                .init(id: "det-pepperoni", name: "Pepperoni",
                      toppings: [.init("Brick / low-moisture mozzarella", 150), .init("Pepperoni", 60), .init("Tomato sauce", 100)],
                      assembly: "Cheese right to the edges first, pepperoni, then sauce in stripes ON TOP."),
                .init(id: "det-cheese", name: "Cheese",
                      toppings: [.init("Brick / low-moisture mozzarella", 150), .init("Tomato sauce", 100)],
                      assembly: "Cheese to the edges first, then sauce in stripes on top."),
                .init(id: "det-hawaiian", name: "Hawaiian",
                      toppings: [.init("Brick / low-moisture mozzarella", 150), .init("Ham", 70),
                                 .init("Pineapple", 60), .init("Tomato sauce", 100)],
                      assembly: "Cheese to the edges, ham and pineapple, then sauce on top."),
            ]
        case "sfincione":
            return [
                .init(id: "sfincione", name: "Classic Sfincione",
                      toppings: [.init("Tomato", 100), .init("Onion", 70), .init("Anchovy", 15),
                                 .init("Caciocavallo", 80), .init("Toasted breadcrumbs", 20),
                                 .init("Dried oregano", 1, scales: false), .init("Extra-virgin olive oil", 10)],
                      assembly: "Onion-tomato-anchovy sauce, then caciocavallo, finish with breadcrumbs, oregano and oil."),
            ]
        case "focaccia":
            return [
                .init(id: "foc-classic", name: "Rosemary & Salt",
                      toppings: [.init("Extra-virgin olive oil", 25), .init("Fresh rosemary", 4, scales: false),
                                 .init("Flaky sea salt", 3, scales: false)],
                      assembly: "Dimple, drizzle the oil brine, scatter rosemary and flaky salt before baking."),
                .init(id: "foc-tomato", name: "Cherry Tomato",
                      toppings: [.init("Extra-virgin olive oil", 25), .init("Cherry tomatoes", 120),
                                 .init("Fresh rosemary", 4, scales: false), .init("Flaky sea salt", 3, scales: false)],
                      assembly: "Press halved cherry tomatoes into the dimples, then oil, rosemary and salt."),
                .init(id: "foc-olive", name: "Olive & Oregano",
                      toppings: [.init("Extra-virgin olive oil", 25), .init("Mixed olives", 80),
                                 .init("Dried oregano", 2, scales: false), .init("Flaky sea salt", 3, scales: false)],
                      assembly: "Press olives into the dimples, drizzle oil, scatter oregano and salt."),
            ]
        default: // everyday
            return [
                .init(id: "ev-margherita", name: "Margherita",
                      toppings: [.init("Tomato sauce", 80), .init("Mozzarella", 100), .init("Fresh basil", 3, scales: false)],
                      assembly: "Sauce, then mozzarella; basil after baking."),
                .init(id: "ev-pepperoni", name: "Pepperoni",
                      toppings: [.init("Tomato sauce", 80), .init("Mozzarella", 100), .init("Pepperoni", 45)],
                      assembly: "Sauce, mozzarella, then pepperoni."),
                .init(id: "ev-hawaiian", name: "Hawaiian",
                      toppings: [.init("Tomato sauce", 80), .init("Mozzarella", 100), .init("Ham", 60), .init("Pineapple", 50)],
                      assembly: "Sauce, mozzarella, then ham and pineapple."),
                .init(id: "ev-veggie", name: "Veggie",
                      toppings: [.init("Tomato sauce", 80), .init("Mozzarella", 90), .init("Peppers", 40),
                                 .init("Mushrooms", 40), .init("Red onion", 30)],
                      assembly: "Sauce, mozzarella, then the vegetables."),
                .init(id: "ev-prosciutto", name: "Prosciutto & Rocket",
                      toppings: [.init("Tomato sauce", 80), .init("Mozzarella", 90),
                                 .init("Prosciutto", 40), .init("Rocket", 20, scales: false), .init("Parmesan", 15)],
                      assembly: "Bake with sauce & mozzarella; after baking add prosciutto, rocket and parmesan."),
            ]
        }
    }

    // MARK: Layering order

    /// Rank for the order an ingredient goes on the pizza (lower = first).
    static func layerRank(_ name: String, cheeseFirst: Bool) -> Int {
        let n = name.lowercased()
        func has(_ words: [String]) -> Bool { words.contains { n.contains($0) } }
        let cheese = has(["mozzarella", "cheese", "caciocavallo", "gorgonzola", "fontina", "parmesan", "brick"])
        if has(["nutella", "banana", "maple", "butter", "cinnamon"]) { return 6 } // sweet, after bake
        if has(["sauce", "tomato", "passata"]) { return 1 }
        if cheese { return cheeseFirst ? 0 : 2 }
        if has(["pepperoni", "salami", "ham", "prosciutto", "anchovy"]) { return 3 }
        if has(["pineapple", "mushroom", "onion", "pepper", "artichoke", "olive", "garlic"]) { return 4 }
        // herbs / oil / breadcrumbs / rocket / finishing
        return 5
    }

    /// Aggregates the selected toppings into a shopping list, ordered by the
    /// sequence they go onto the pizza, and scaled by pizza size.
    static func toppingShoppingList(styleID: String, selection: [String: Int], sizeFactor: Double) -> [ShoppingLine] {
        let cheeseFirst = (styleID == "detroit")
        let chosen = selectedRecipes(styleID: styleID, selection: selection)

        var totals: [String: Double] = [:]
        var pizzaCounts: [String: Int] = [:]
        for recipe in chosen {
            let count = selection[recipe.id] ?? 0
            for t in recipe.toppings {
                totals[t.name, default: 0] += t.gramsPerPizza * Double(count) * (t.scalesWithSize ? sizeFactor : 1)
                pizzaCounts[t.name, default: 0] += count
            }
        }
        return totals.keys
            .sorted { a, b in
                let ra = layerRank(a, cheeseFirst: cheeseFirst), rb = layerRank(b, cheeseFirst: cheeseFirst)
                return ra == rb ? a < b : ra < rb
            }
            .map { ShoppingLine(name: $0, grams: totals[$0] ?? 0, hint: nil,
                                pizzaCount: pizzaCounts[$0] ?? 0) }
    }

    /// The selected recipes in catalogue order.
    static func selectedRecipes(styleID: String, selection: [String: Int]) -> [PizzaRecipe] {
        recipes(for: styleID).filter { (selection[$0.id] ?? 0) > 0 }
    }

    /// True for the pineapple-bearing pizzas (Hawaiian etc.).
    static func isPineapple(_ recipe: PizzaRecipe) -> Bool {
        recipe.toppings.contains { $0.name.lowercased().contains("pineapple") }
    }

    /// Common pizza toppings offered as quick checkboxes in the planner.
    static let commonExtras = [
        "Pepperoni", "Mushrooms", "Fresh basil", "Red onion",
        "Black olives", "Capsicum", "Cherry tomatoes", "Prosciutto",
        "Anchovies", "Fresh chilli", "Garlic", "Extra mozzarella",
    ]
}
