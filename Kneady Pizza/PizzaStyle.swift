import Foundation

/// Round pies vs. rectangular pan bakes — drives both the sizing UI and wording.
enum PizzaShape: Hashable {
    case round
    case rectangular

    var noun: String { self == .round ? "ball" : "pan" }
    var nounPlural: String { self == .round ? "balls" : "pans" }
    var label: String { self == .round ? "Round" : "Square" }
}

/// How tricky a style is to pull off well — shown in the picker so beginners
/// know where to start.
enum Complexity: Int {
    case beginner = 0, intermediate, advanced

    var label: String {
        switch self {
        case .beginner:     return "Villager"
        case .intermediate: return "Sunday Pizzaiolo"
        case .advanced:     return "Roman Soldier"
        }
    }
}

/// A pizza style expressed as a set of baker's percentages plus shaping data.
///
/// Adding a new style later is as simple as defining another `PizzaStyle`
/// constant and appending it to `all` — no other code needs to change.
///
/// Percentages are derived from a reference ratio table (grams per ~100 g of
/// finished dough), converted to baker's percentages (fraction of flour weight).
struct PizzaStyle: Identifiable, Hashable {
    let id: String
    let name: String
    let blurb: String
    /// Longer description explaining the style and how it differs from others.
    let details: String
    let shape: PizzaShape

    // Baker's percentages, expressed as fractions of flour weight (1.0 == 100%).
    var hydration: Double          // water
    var salt: Double
    var oil: Double
    var honey: Double

    /// Sensible adjustable range for hydration, used by the UI slider.
    var hydrationRange: ClosedRange<Double>

    /// Grams of dough per cm² of pizza surface. Sets the "thickness" of the base.
    var thicknessFactor: Double

    /// A typical piece weight (g) — the default when sizing by weight.
    var defaultBallWeight: Double

    /// Reference instant-dry-yeast percentage at the calculator's reference
    /// conditions (see `DoughCalculator`). Styles can be more or less yeasted.
    var referenceIDY: Double

    /// The leavening agents appropriate for this style (first = recommended).
    var yeasts: [YeastType]
    var recommendedYeast: YeastType { yeasts.first ?? .IDY }

    /// How hard the style is to get right (forgiving pan/home bakes are easy;
    /// authentic Neapolitan, with its wet dough and blazing bake, is hardest).
    var complexity: Complexity {
        switch id {
        case "everyday", "focaccia":                  return .beginner
        case "neapolitan", "neapolitan-contemporary": return .advanced
        default:                                      return .intermediate
        }
    }

    /// An indicative total time (hours) for a typical warm proof with this
    /// style's defaults — a rough "how long will this take?" for the picker.
    var indicativeHours: Double {
        let pref: Double
        switch defaultPreferment {
        case .poolish: pref = 12
        case .biga:    pref = 16
        case .none:    pref = 0
        }
        let auto = defaultAutolyse ? 0.5 : 0
        return pref + auto + 18   // ~14 h bulk + ~4 h proof at room temperature
    }

    /// Bundled hero image filename (a transparent PNG) shown below the
    /// directions. Drop `hero-<id>.png` into the app folder to supply it.
    var heroImageName: String { "hero-\(id)" }

    /// A flag (or home) emoji for the style's place of origin.
    var originFlag: String {
        switch id {
        case "newyork", "detroit": return "🇺🇸"
        case "everyday":           return "🏠"
        default:                   return "🇮🇹"
        }
    }

    /// A one-line spec for the style picker (hydration · pre-ferment · extras).
    var specLine: String {
        var parts = ["\(Int((hydration * 100).rounded()))% hydration"]
        switch defaultPreferment {
        case .poolish: parts.append("poolish")
        case .biga:    parts.append("biga")
        case .none:    parts.append("direct")
        }
        if honey > 0 { parts.append("a little honey") }
        else if oil > 0 { parts.append("a little oil") }
        return parts.joined(separator: " · ")
    }

    /// How toppings are typically layered — shown in the bake step.
    var assembly: String

    /// The pre-ferment that suits this style, applied when it's selected.
    var defaultPreferment: PrefermentChoice
    /// Whether an autolyse is recommended for this style by default.
    var defaultAutolyse: Bool

    // MARK: Styles (values from the ratio table)

    static let neapolitan = PizzaStyle(
        id: "neapolitan",
        name: "Neapolitan Classic",
        blurb: "Soft, airy, blistered. A short, hot bake.",
        details: "Round, ~12″. Naples' original: a wet, soft dough baked blisteringly hot (430–480 °C) for 60–90 seconds. Puffy, charred cornicione with a tender, foldable centre. No oil, no sugar — just flour, water, salt and time. A poolish keeps it light and crisp; an autolyse makes it easier to stretch.",
        shape: .round,
        hydration: 0.60,
        salt: 0.028,         // 1.6 / 56.5
        oil: 0.0,
        honey: 0.0,
        hydrationRange: 0.55...0.70,
        thicknessFactor: 0.382,     // ≈ 270 g for a 30 cm base (matches default ball)
        defaultBallWeight: 270,
        referenceIDY: 0.0011,       // 0.06 / 56.5
        yeasts: [.CY, .IDY, .SD],   // fresh = authentic; instant; sourdough
        assembly: "Sauce, then torn fior di latte; add basil after baking.",
        defaultPreferment: .poolish,
        defaultAutolyse: true
    )

    static let neapolitanContemporary = PizzaStyle(
        id: "neapolitan-contemporary",
        name: "Neapolitan Contemporary",
        blurb: "Modern 'contemporanea': a tall, cloud-like cornicione.",
        details: "Round, ~12″, but with a dramatically puffed, airy rim. Higher hydration than the classic and built on a stiff biga for strength and a light, structured crumb. A pinch of honey and a little oil help it colour in a slightly cooler oven. Autolyse first for extensibility.",
        shape: .round,
        hydration: 0.70,
        salt: 0.028,
        oil: 0.005,          // ~0.5 ml per 100 g flour
        honey: 0.005,        // ~0.5 g per 100 g flour
        hydrationRange: 0.62...0.78,
        thicknessFactor: 0.40,
        defaultBallWeight: 280,
        referenceIDY: 0.0015,
        yeasts: [.IDY, .CY, .SD],
        assembly: "Light sauce, torn fior di latte; add basil and a drizzle of oil after baking.",
        defaultPreferment: .biga,
        defaultAutolyse: true
    )

    static let newYork = PizzaStyle(
        id: "newyork",
        name: "New York",
        blurb: "Foldable slices. A little oil, a touch of honey.",
        details: "Round and large (16–18″). A descendant of Neapolitan with added oil and a little honey, baked cooler and longer for a crisp-yet-pliable slice. Sturdy enough to fold in half and eat on the move.",
        shape: .round,
        hydration: 0.65,
        salt: 0.020,         // 1.1 / 54.3
        oil: 0.029,          // 1.6 / 54.3
        honey: 0.009,        // 0.5 / 54.3
        hydrationRange: 0.58...0.70,
        thicknessFactor: 0.38,
        defaultBallWeight: 280,
        referenceIDY: 0.0055,       // 0.30 / 54.3
        yeasts: [.IDY, .ADY],
        assembly: "Sauce, then grated low-moisture mozzarella, then toppings.",
        defaultPreferment: .poolish,
        defaultAutolyse: true
    )

    static let roman = PizzaStyle(
        id: "roman",
        name: "Roman",
        blurb: "Thin and crisp. Cracker-light, oil-rich.",
        details: "Round and cracker-thin (pizza tonda). Rolled flat rather than hand-stretched, and enriched with oil for a shatteringly crisp, low-rise base that stays light and crunchy edge to edge.",
        shape: .round,
        hydration: 0.60,
        salt: 0.020,         // 1.1 / 55.6
        oil: 0.040,          // 2.2 / 55.6
        honey: 0.0,
        hydrationRange: 0.55...0.68,
        thicknessFactor: 0.32,
        defaultBallWeight: 250,
        referenceIDY: 0.0054,       // 0.30 / 55.6
        yeasts: [.IDY, .ADY],
        assembly: "A thin, even layer of sauce and cheese — keep it light.",
        defaultPreferment: .biga,
        defaultAutolyse: true
    )

    static let detroit = PizzaStyle(
        id: "detroit",
        name: "Detroit / Pan",
        blurb: "Thick, airy, pan-baked. Square slices.",
        details: "Rectangular, baked in an oiled steel pan. High hydration gives a thick, airy, focaccia-like crumb, while cheese pushed to the edges caramelises into a crisp, lacy 'frico' border. Cut into squares. Sized by pan, not by ball.",
        shape: .rectangular,
        hydration: 0.75,
        salt: 0.020,         // 1.0 / 50.0
        oil: 0.050,          // 2.5 / 50.0
        honey: 0.010,        // 0.5 / 50.0
        hydrationRange: 0.65...0.85,
        thicknessFactor: 0.62,      // pan dough is thick
        defaultBallWeight: 520,
        referenceIDY: 0.0100,       // 0.50 / 50.0
        yeasts: [.IDY, .ADY],
        assembly: "Cheese right to the edges first, then sauce in stripes ON TOP.",
        defaultPreferment: .poolish,
        defaultAutolyse: true
    )

    static let sfincione = PizzaStyle(
        id: "sfincione",
        name: "Sicilian Sfincione",
        blurb: "Thick, spongy focaccia-style. Onion, anchovy, breadcrumbs.",
        details: "Rectangular and deep — 'sfincione' means little sponge. A high-hydration dough is proofed in an oiled pan, dimpled, and topped with an onion-tomato-anchovy sauce, caciocavallo and toasted breadcrumbs (no fresh mozzarella). Baked until the base is golden and crisp underneath.",
        shape: .rectangular,
        hydration: 0.78,
        salt: 0.022,
        oil: 0.05,
        honey: 0.0,
        hydrationRange: 0.70...0.85,
        thicknessFactor: 0.75,      // thick and spongy
        defaultBallWeight: 600,
        referenceIDY: 0.0080,
        yeasts: [.IDY, .ADY],
        assembly: "Onion-tomato-anchovy sauce, then caciocavallo, finish with breadcrumbs and oregano.",
        defaultPreferment: .biga,
        defaultAutolyse: true
    )

    static let everyday = PizzaStyle(
        id: "everyday",
        name: "Simple Home Classic",
        blurb: "Forgiving all-rounder for the home oven.",
        details: "Round and forgiving. Tuned for a domestic oven (~250 °C) with a stone or steel — a balanced, easy-to-handle dough that's reliably good without special equipment or a wood fire.",
        shape: .round,
        hydration: 0.65,
        salt: 0.020,         // 1.1 / 55.0
        oil: 0.031,          // 1.7 / 55.0
        honey: 0.011,        // 0.6 / 55.0
        hydrationRange: 0.58...0.72,
        thicknessFactor: 0.40,
        defaultBallWeight: 260,
        referenceIDY: 0.0055,       // 0.30 / 55.0
        yeasts: [.IDY, .ADY, .SD],
        assembly: "Sauce, then cheese, then your toppings.",
        defaultPreferment: .none,
        defaultAutolyse: false
    )

    static let focaccia = PizzaStyle(
        id: "focaccia",
        name: "Focaccia",
        blurb: "Pillowy, oil-rich pan bread. Dimpled and golden.",
        details: "Rectangular and deep — a very wet (~80%) dough proofed in a generously oiled pan, then dimpled with oiled fingers and bathed in an olive-oil brine. Baked at a moderate ~220 °C (not a pizza-oven blast) for 20–25 minutes until golden and crisp underneath, airy and soft within. Classic toppings are just rosemary and flaky salt; cherry tomatoes or olives are lovely too.",
        shape: .rectangular,
        hydration: 0.80,
        salt: 0.022,
        oil: 0.05,
        honey: 0.0,
        hydrationRange: 0.72...0.90,
        thicknessFactor: 0.80,      // thick and pillowy
        defaultBallWeight: 650,
        referenceIDY: 0.0090,
        yeasts: [.IDY, .ADY, .SD],
        assembly: "Dimple with oiled fingers, drizzle an oil-water-salt brine into the dips, then scatter rosemary and flaky salt.",
        defaultPreferment: .biga,
        defaultAutolyse: true
    )

    /// Every style the app knows about, in display order (My Favourite is shown
    /// above this list by the picker). Neapolitan remains the app's default.
    static let all: [PizzaStyle] = [.everyday, .neapolitan, .neapolitanContemporary, .roman, .focaccia, .sfincione, .newYork, .detroit]
}
