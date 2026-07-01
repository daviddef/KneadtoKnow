import SwiftUI

// MARK: - Kid palette

/// A bright, fixed palette for Kid Mode (its screens set their own light
/// background, so these read correctly regardless of the app theme).
enum Kid {
    static let cream     = Color(red: 1.00, green: 0.969, blue: 0.925)  // FFF7EC
    static let ink       = Color(red: 0.42, green: 0.26,  blue: 0.13)   // 6B4321
    static let inkSoft   = Color(red: 0.60, green: 0.45,  blue: 0.27)   // 9A7A55
    static let tomato    = Color(red: 1.00, green: 0.353, blue: 0.235)  // FF5A3C
    static let tomatoDk  = Color(red: 0.89, green: 0.262, blue: 0.122)  // E3431F
    static let green     = Color(red: 0.184, green: 0.706, blue: 0.341) // 2FB457
    static let sunny     = Color(red: 1.00, green: 0.824, blue: 0.247)  // FFD23F
    static let sunnySoft = Color(red: 1.00, green: 0.906, blue: 0.659)  // FFE7A8
    static let grape     = Color(red: 0.627, green: 0.424, blue: 1.00)  // A06CFF
    static let grapeSoft = Color(red: 0.906, green: 0.855, blue: 0.984) // E7DAFB
    static let sky       = Color(red: 0.737, green: 0.863, blue: 1.00)  // BCDCFF
    static let leaf      = Color(red: 0.847, green: 0.937, blue: 0.761) // D8EFC2
    static let leafDk    = Color(red: 0.231, green: 0.427, blue: 0.067) // 3B6D11
}

// MARK: - Models

/// One topping a kid can pile on, with a child-sized amount and a grown-up tip.
struct KidTopping: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let emoji: String
    let kidAmount: String
    let grownupTip: String
    var veggie: Bool = false
    var video: String? = nil   // bundled .mp4 base name for an animated "add it" step
}

/// The two kid dough options.
enum KidDough: String, Codable, CaseIterable {
    case rightNow, puffy
    var title: String { self == .rightNow ? "Right now!" : "Puffy & bouncy" }
    var emoji: String { self == .rightNow ? "⚡" : "🎈" }
    var time:  String { self == .rightNow ? "~30 mins" : "~1–2 hrs" }
    var blurb: String {
        self == .rightNow
        ? "Magic powder dough — no waiting around."
        : "Yeasty dough that grows big while you play!"
    }
    var flow: String {
        self == .rightNow ? "🥣 Mix › 👐 Knead › 🫓 Flatten" : "🥣 Mix › 👐 Knead › 🎈 Puff › 🫓 Flatten"
    }

    /// Dough ingredients with both kid units and a grown-up gram reading.
    var ingredients: [KidIngredient] {
        switch self {
        case .rightNow:
            return [
                .init(emoji: "🥣", name: "Flour",         kid: "2 cups",   metric: "250 g",  imperial: "9 oz"),
                .init(emoji: "✨", name: "Baking powder", kid: "1 spoon",  metric: "10 g",   imperial: "2 tsp",
                      alt: KidAltCard(emoji: "🌾", title: "Self-raising flour",
                                      sub: "alternative to flour & baking powder",
                                      kid: "2 cups", metric: "250 g", imperial: "9 oz")),
                .init(emoji: "💧", name: "Warm water",    kid: "¾ cup",    metric: "180 ml", imperial: "6 fl oz"),
                .init(emoji: "🥄", name: "Oil",           kid: "1 spoon",  metric: "15 ml",  imperial: "1 tbsp"),
                .init(emoji: "🧂", name: "Salt",          kid: "a pinch",  metric: "3 g",    imperial: "½ tsp"),
            ]
        case .puffy:
            return [
                .init(emoji: "🥣", name: "Flour",       kid: "2 cups",        metric: "250 g",  imperial: "9 oz"),
                .init(emoji: "🫧", name: "Yeast",       kid: "½ spoon",       metric: "3 g",    imperial: "1 tsp"),
                .init(emoji: "💧", name: "Warm water",  kid: "¾ cup",         metric: "180 ml", imperial: "6 fl oz"),
                .init(emoji: "🥄", name: "Oil",         kid: "1 spoon",       metric: "15 ml",  imperial: "1 tbsp"),
                .init(emoji: "🍯", name: "Honey",       kid: "1 small spoon", metric: "7 g",    imperial: "1 tsp"),
                .init(emoji: "🧂", name: "Salt",        kid: "a pinch",       metric: "3 g",    imperial: "½ tsp"),
            ]
        }
    }
}

struct KidIngredient: Identifiable, Hashable {
    var id: String { name }
    let emoji: String
    let name: String
    let kid: String
    let metric: String
    let imperial: String
    var alt: KidAltCard? = nil
    func precise(_ isMetric: Bool) -> String { isMetric ? metric : imperial }
}

/// A swap-in alternative shown as its own card under an ingredient.
struct KidAltCard: Hashable {
    let emoji: String
    let title: String
    let sub: String
    let kid: String
    let metric: String
    let imperial: String
    func precise(_ isMetric: Bool) -> String { isMetric ? metric : imperial }
}

/// A kid pizza: an ordered build of sauce, cheese and extra toppings.
struct KidPizza: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var emoji: String
    var sauce: Bool
    var cheese: Bool
    var extras: [KidTopping]
    var blurb: String? = nil   // a short "what's on it" line for the tile
    var art: String? = nil     // asset name for the tile illustration
    var custom: Bool = false
}

/// One big step on screen in the cooking flow.
struct KidStep: Identifiable {
    let id = UUID()
    var emoji: String
    var art: String? = nil    // asset name for a big step illustration
    var video: String? = nil  // bundled .mp4 base name for an animated step
    var title: String
    var detail: String
    var chips: [String] = []
    var ingredients: [KidIngredient] = []
    var banner: KidBanner? = nil
    var joke: String? = nil
    var tip: String? = nil
    var grownUp: Bool = false
}

/// A big, friendly callout (clock/timer/temperature) shown on a step.
struct KidBanner {
    var icon: String
    var value: String
    var sub: String
    var warm: Bool = false   // warm = tomato tones (oven), else cool purple (time)
}

// MARK: - Topping & pizza library

enum KidLibrary {
    static let pepperoni  = KidTopping(name: "Pepperoni", emoji: "🍕", kidAmount: "a circle of pepperonis", grownupTip: "thin slices, not too many", video: "kid-topping-pepperoni")
    static let ham        = KidTopping(name: "Ham", emoji: "🍖", kidAmount: "a handful of ham", grownupTip: "pre-cooked ham, torn up", video: "kid-topping-ham")
    static let pineapple  = KidTopping(name: "Pineapple", emoji: "🍍", kidAmount: "little pineapple chunks", grownupTip: "pat the pieces dry first", video: "kid-topping-pineapple")
    static let basil      = KidTopping(name: "Basil", emoji: "🌿", kidAmount: "a few basil leaves", grownupTip: "add after baking", video: "kid-topping-basil")
    static let peppers    = KidTopping(name: "Peppers", emoji: "🫑", kidAmount: "colourful pepper strips", grownupTip: "chop small and thin", veggie: true)
    static let corn       = KidTopping(name: "Sweetcorn", emoji: "🌽", kidAmount: "a sprinkle of corn", grownupTip: "drain it well", veggie: true)
    static let mushroom   = KidTopping(name: "Mushroom", emoji: "🍄", kidAmount: "a few mushroom slices", grownupTip: "slice thin so they cook", veggie: true, video: "kid-topping-mushroom")
    static let olives     = KidTopping(name: "Olives", emoji: "🫒", kidAmount: "a scatter of olives", grownupTip: "halve them — watch for stones", veggie: true)
    static let nutella    = KidTopping(name: "Nutella", emoji: "🍫", kidAmount: "big spoonfuls of Nutella", grownupTip: "spread after baking", veggie: true, video: "kid-topping-nutella")
    static let banana     = KidTopping(name: "Banana", emoji: "🍌", kidAmount: "banana coins", grownupTip: "slice nice and thin", veggie: true)
    static let chicken    = KidTopping(name: "Chicken", emoji: "🍗", kidAmount: "a handful of chicken", grownupTip: "pre-cooked, chopped")
    static let plantPep   = KidTopping(name: "Plant pepperoni", emoji: "🌱", kidAmount: "a circle of plant pepperoni", grownupTip: "check it's pre-cooked", veggie: true)
    static let beans      = KidTopping(name: "Beans", emoji: "🫘", kidAmount: "a sprinkle of beans", grownupTip: "drain and rinse", veggie: true)

    /// The tappable picker tiles.
    static let presets: [KidPizza] = [
        .init(id: "cheese",   name: "Just Cheese",       emoji: "🧀",   sauce: true,  cheese: true,  extras: [],                  blurb: "gooey melty cheese",      art: "kid-cheese"),
        .init(id: "pep",      name: "Pepperoni",         emoji: "🍕",   sauce: true,  cheese: true,  extras: [pepperoni],         blurb: "cheese + spicy pepperoni", art: "kid-pepperoni"),
        .init(id: "hawaii",   name: "Hawaiian",          emoji: "🍍🍖", sauce: true,  cheese: true,  extras: [ham, pineapple],    blurb: "ham + pineapple",         art: "kid-hawaiian"),
        .init(id: "marg",     name: "Margherita",        emoji: "🍅🌿", sauce: true,  cheese: true,  extras: [basil],             blurb: "cheese + basil leaves",   art: "kid-margherita"),
        .init(id: "veggie",   name: "Rainbow Veggie",    emoji: "🌈🫑", sauce: true,  cheese: true,  extras: [peppers, corn],     blurb: "peppers + sweetcorn",     art: "kid-veggie"),
        .init(id: "nutella",  name: "Nutella & Banana",  emoji: "🍫🍌", sauce: false, cheese: false, extras: [nutella, banana],   blurb: "choc + banana (sweet!)",  art: "kid-nutella"),
        .init(id: "dino",     name: "Dino Pepperoni",    emoji: "🦕",   sauce: true,  cheese: true,  extras: [pepperoni],         blurb: "pepperoni — RAWR! 🦖",    art: "kid-dino"),
    ]

    // Builder option groups.
    static let proteins: [KidTopping] = [ham, pepperoni, chicken, plantPep, beans]
    static let veg: [KidTopping]      = [peppers, corn, mushroom, olives]
    static let sweet: [KidTopping]    = [pineapple, banana, nutella]
}

// MARK: - Step generation

enum KidRecipe {
    static let jokes = [
        "Why did the pizza smile? It was feeling saucy!",
        "What's a dough's favourite dance? The knead-le wiggle!",
        "Why did the cheese go to the party? To get melty!",
        "What do you call a sad pizza? A pizza my heart!",
        "Why did the tomato turn red? It saw the pizza dressing!",
    ]

    static func steps(for pizza: KidPizza, dough: KidDough, metric: Bool) -> [KidStep] {
        var s: [KidStep] = []

        s.append(KidStep(emoji: "🥣", art: "kid-step-mix", video: "kid-step-mix", title: "Mix it all up!",
                         detail: "Tip everything into the bowl and mix into a lumpy, shaggy ball!",
                         ingredients: dough.ingredients,
                         tip: "Wash your hands first — go go go!"))

        s.append(KidStep(emoji: "👐", art: "kid-step-knead", video: "kid-step-knead", title: "Knead & squish!",
                         detail: "Push it, fold it, turn it! Squish until it's smooth and bouncy.",
                         banner: KidBanner(icon: "⏲️", value: "2 minutes", sub: "squish until smooth & bouncy!"),
                         joke: jokes[1]))

        if dough == .puffy {
            s.append(KidStep(emoji: "🎈", art: "kid-step-puff", video: "kid-step-puff", title: "Let it puff up!",
                             detail: "Pop it somewhere cosy and let it grow big — like a balloon!",
                             banner: KidBanner(icon: "⏰", value: "About 1 hour", sub: "until it's twice as big!"),
                             tip: "Peek now and then — it's getting bigger!"))
        }

        s.append(KidStep(emoji: "🫓", video: "kid-step-flatten", title: "Press it flat!",
                         detail: "Squish it flat and round like a moon — push from the middle out!",
                         tip: "Messy is OK — that's the fun bit!"))

        if pizza.sauce {
            s.append(KidStep(emoji: "🍅", art: "kid-step-sauce", video: "kid-step-sauce", title: "Splat the sauce!",
                             detail: "Spoon it on and spread it round and round — leave a little edge!",
                             chips: ["🥄 a big spoon of sauce"],
                             tip: "Grown-up tip: passata or a thin pizza sauce"))
        }
        if pizza.cheese {
            s.append(KidStep(emoji: "🧀", art: "kid-step-cheese", video: "kid-step-cheese", title: "Snow the cheese!",
                             detail: "Sprinkle it everywhere like snow!",
                             chips: ["🧀 2 big handfuls"],
                             joke: jokes[2],
                             tip: "Grown-up tip: low-moisture mozzarella, grated"))
        }
        for t in pizza.extras {
            s.append(KidStep(emoji: t.emoji, video: t.video, title: "Add the \(t.name.lowercased())!",
                             detail: "Pop them on top — make a pattern or a funny face!",
                             chips: ["\(t.emoji) \(t.kidAmount)"],
                             tip: "Grown-up tip: \(t.grownupTip)"))
        }

        s.append(KidStep(emoji: "🔥", video: "kid-step-oven", title: "Into the oven!",
                         detail: "Ovens are super HOT — time to grab a grown-up to help!",
                         banner: KidBanner(icon: "🔥", value: "About 10 minutes",
                                           sub: metric ? "at 220°C" : "at 425°F", warm: true),
                         grownUp: true))

        return s
    }

    /// Build a pizza from the make-your-own selections, with a "what's on it" blurb.
    static func custom(sauce: Bool, cheese: Bool, extras: [KidTopping]) -> KidPizza {
        var parts: [String] = []
        if cheese { parts.append("cheese") }
        parts += extras.map { $0.name.lowercased() }
        if parts.isEmpty { parts = [sauce ? "just sauce" : "plain dough"] }
        let blurb = parts.joined(separator: " · ")

        let name: String
        if extras.count >= 2 { name = "\(extras[0].name) & \(extras[1].name) Pizza" }
        else if let only = extras.first { name = "\(only.name) Pizza" }
        else { name = cheese ? "Cheese Pizza" : "Plain Pizza" }

        return KidPizza(id: "custom-\(extras.map(\.id).joined(separator: "-"))",
                        name: name, emoji: "🍕",
                        sauce: sauce, cheese: cheese, extras: extras, blurb: blurb, custom: true)
    }
}

// MARK: - Stores

enum KidModeStore {
    private static let key = "kidMode.v1"
    static var enabled: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

enum KidPizzaStore {
    private static let key = "kidPizzas.v1"
    static func load() -> [KidPizza] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([KidPizza].self, from: data)) ?? []
    }
    static func save(_ list: [KidPizza]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    static func add(_ pizza: KidPizza) {
        var list = load()
        list.removeAll { $0.id == pizza.id }
        list.insert(pizza, at: 0)
        save(Array(list.prefix(12)))
    }
}
