import Foundation

/// A yeasted pre-ferment mixed ahead of the final dough. Values reflect common
/// industry practice (see Ooni / ChainBaker / The Fresh Loaf).
enum Preferment: String, CaseIterable, Identifiable, Codable {
    case poolish
    case biga

    var id: String { rawValue }
    var name: String { self == .poolish ? "Poolish" : "Biga" }

    /// Hydration of the pre-ferment itself (fraction of its own flour weight).
    /// Poolish is a loose 100% batter; biga is a stiff ~50% dough.
    var hydration: Double { self == .poolish ? 1.00 : 0.50 }

    /// Reference yeast as a fraction of the pre-ferment's flour, at its rest
    /// conditions. Both use a tiny amount; biga a touch more (stiffer, slower).
    var referenceYeast: Double { self == .poolish ? 0.0015 : 0.0020 }

    /// Industry-typical share of the *total flour* that is pre-fermented.
    var defaultPct: Double { self == .poolish ? 0.30 : 0.50 }

    /// Typical rest at 20 °C, in hours. Biga is usually left a little longer.
    var restBaseHours: Double { self == .poolish ? 12 : 16 }

    var blurb: String {
        switch self {
        case .poolish:
            return "Loose 100%-hydration pre-ferment. Mild and nutty; adds extensibility. ~12 h rest, ~30% of the flour."
        case .biga:
            return "Stiff ~50%-hydration pre-ferment. Stronger, more aromatic and complex. ~16 h rest, ~50% of the flour."
        }
    }

    /// What to write on the timeline when making it.
    var mixDetail: String {
        switch self {
        case .poolish:
            return "Whisk flour, water and yeast into a loose batter. Cover and rest at room temperature."
        case .biga:
            return "Rub flour, water and yeast into a stiff, shaggy dough. Cover and rest at room temperature."
        }
    }
}

/// The three-way choice shown in the UI: none, poolish, or biga.
enum PrefermentChoice: String, CaseIterable, Identifiable {
    case none, poolish, biga
    var id: String { rawValue }
    var label: String {
        switch self {
        case .none: return "None"
        case .poolish: return "Poolish"
        case .biga: return "Biga"
        }
    }
}
