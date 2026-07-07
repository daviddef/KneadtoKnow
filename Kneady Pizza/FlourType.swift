import Foundation

/// A named flour preset — the protein numbers bakers actually shop by, plus
/// how much each nudges hydration versus this app's baseline assumption
/// (roughly a standard 00 / bread flour). Picking a stronger, thirstier
/// flour nudges hydration up a touch; nothing here touches the schedule's
/// own timing — see `fermentNote` for that guidance instead.
enum FlourType: String, CaseIterable, Identifiable, Codable {
    case genericAP
    case caputoPizzeria
    case chefsFlour
    case americana00
    case kingArthurBread
    case centralMilling
    case allTrumps

    var id: String { rawValue }

    var name: String {
        switch self {
        case .genericAP:       return "Generic / all-purpose"
        case .caputoPizzeria:  return "Caputo Pizzeria (00)"
        case .chefsFlour:      return "Caputo Chef's / Cuoco (00)"
        case .americana00:     return "00 Americana"
        case .kingArthurBread: return "King Arthur Bread Flour"
        case .centralMilling:  return "Central Milling Artisan Bakers Craft"
        case .allTrumps:       return "All Trumps (high-gluten)"
        }
    }

    /// Protein range as printed on the bag — the number bakers actually shop by.
    var proteinPct: String {
        switch self {
        case .genericAP:       return "10–11.5%"
        case .caputoPizzeria:  return "~12.5%"
        case .chefsFlour:      return "~13%"
        case .americana00:     return "~14%"
        case .kingArthurBread: return "~12.7%"
        case .centralMilling:  return "~11.5–13%"
        case .allTrumps:       return "~14.2%"
        }
    }

    /// Shift from this app's baseline hydration assumption. 0 means "no
    /// nudge, this is the baseline the other defaults already assume."
    var hydrationNudge: Double {
        switch self {
        case .genericAP:       return 0
        case .caputoPizzeria:  return 0.02
        case .chefsFlour:      return 0.03
        case .americana00:     return 0.05
        case .kingArthurBread: return 0.02
        case .centralMilling:  return 0.02
        case .allTrumps:       return 0.05
        }
    }

    /// How the flour behaves over a longer ferment — education, not a
    /// silent change to the schedule's own timing.
    var fermentNote: String {
        switch self {
        case .genericAP:
            return "A safe middle-of-the-road flour — the app's defaults are tuned for something like this."
        case .caputoPizzeria:
            return "The standard Neapolitan 00 — great for same-day or overnight rises; can slacken if pushed much past 24h cold."
        case .chefsFlour:
            return "A step stronger than Pizzeria-grade 00 — handles a longer cold ferment (24–48h) comfortably."
        case .americana00:
            return "High-protein and thirsty — bred for long cold ferments (48–72h) without the dough breaking down."
        case .kingArthurBread:
            return "A strong, widely-available bread flour — handles longer ferments better than a generic all-purpose."
        case .centralMilling:
            return "A workhorse artisan-bakery flour — strong enough for extended cold ferments."
        case .allTrumps:
            return "A classic NY-style high-gluten flour — very strong, tolerates a long retard well."
        }
    }
}
