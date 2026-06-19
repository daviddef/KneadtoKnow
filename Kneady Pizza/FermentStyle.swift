import Foundation

/// How the main dough ferment is run — which sets timing, temperature and
/// (for quick) an accelerated, enriched recipe.
enum FermentStyle: String, CaseIterable, Identifiable, Codable {
    case quick      // warm, lots of yeast + honey, ~1–24 h
    case cold       // fridge, 24–72 h
    case sameDay    // room temperature, ~12–20 h

    var id: String { rawValue }

    var label: String {
        switch self {
        case .quick:   return "Quick"
        case .sameDay: return "Warm Proof"
        case .cold:    return "Cold Proof"
        }
    }

    var blurb: String {
        switch self {
        case .quick:
            return "In a hurry. Warm water (~40 °C), extra yeast and a little honey force a fast rise in a warm spot — ready in as little as an hour (slide up for longer)."
        case .sameDay:
            return "A room-temperature rise over several hours (often overnight). Simple and reliable."
        case .cold:
            return "The slow magic: 24–72 h in the fridge. Less yeasty, deeper flavour and a more digestible crust."
        }
    }
}

/// Where a rest happens — drives the timeline wording (fridge vs room).
enum StepLocation {
    case room, fridge, warm

    var phrase: String {
        switch self {
        case .room:   return "at room temperature"
        case .fridge: return "in the fridge"
        case .warm:   return "somewhere warm"
        }
    }

    var icon: String {
        switch self {
        case .room:   return "house"
        case .fridge: return "snowflake"
        case .warm:   return "thermometer.sun.fill"
        }
    }
}
