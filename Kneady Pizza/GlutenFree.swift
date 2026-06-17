import Foundation

/// The binder that stands in for gluten in a gluten-free dough. Without a gluten
/// network, a hydrocolloid is needed to give the dough cohesion and gas-holding.
/// Doses are baker's percentages (fraction of the flour-blend weight) drawn from
/// common published gluten-free pizza recipes.
enum BinderType: String, CaseIterable, Identifiable, Codable {
    case xanthan
    case psyllium

    var id: String { rawValue }
    var label: String { self == .xanthan ? "Xanthan gum" : "Psyllium husk" }

    /// Fraction of flour. ~2% xanthan or ~3.5% psyllium are typical starting
    /// points across published GF pizza recipes.
    var pct: Double { self == .xanthan ? 0.02 : 0.035 }

    var blurb: String {
        switch self {
        case .xanthan:
            return "A little goes a long way — about 2% of the flour. Gives quick cohesion and chew."
        case .psyllium:
            return "Used a touch heavier — about 3–4% of the flour. Holds water and adds a breadier structure."
        }
    }
}

/// How faithfully a style survives the switch to gluten-free. Stretch-and-toss
/// styles become pressed approximations; pan-pressed styles convert cleanly.
enum GFViability {
    case clean      // pan-pressed styles translate faithfully
    case moderate   // a decent pressed / rolled crust
    case poor       // loses its defining character (no hand-stretch, no leopard)

    var label: String {
        switch self {
        case .clean:    return "Works well gluten-free"
        case .moderate: return "Good gluten-free, pressed"
        case .poor:     return "Approximate gluten-free"
        }
    }

    /// Shown under the style when gluten-free is on.
    var note: String {
        switch self {
        case .clean:
            return "This pan-pressed style translates cleanly to gluten-free — it's already shaped by pressing, not stretching."
        case .moderate:
            return "A solid gluten-free version — press or roll it out rather than hand-stretching, and par-bake the base before topping."
        case .poor:
            return "Gluten-free can't be hand-stretched or tossed, so this becomes a soft, pressed approximation — tasty, but not the authentic airy, leopard-spotted original."
        }
    }
}
