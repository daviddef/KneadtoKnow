import Foundation

/// The leavening agents the calculator supports — the four common in pizza
/// making. Each style surfaces only the appropriate ones (see `PizzaStyle`).
enum YeastType: String, CaseIterable, Identifiable {
    case IDY  // Instant dry yeast
    case ADY  // Active dry yeast
    case CY   // Compressed (fresh / cake) yeast
    case SD   // Sourdough starter

    var id: String { rawValue }

    var fullName: String {
        switch self {
        case .IDY: return "Instant dry"
        case .ADY: return "Active dry"
        case .CY:  return "Fresh yeast"
        case .SD:  return "Sourdough"
        }
    }

    var isSourdough: Bool { self == .SD }

    /// Weight multiplier relative to instant dry yeast (IDY = 1.0).
    /// Only meaningful for commercial yeasts.
    var idyMultiplier: Double {
        switch self {
        case .IDY: return 1.0
        case .ADY: return 1.25   // active dry is a little less potent than instant
        case .CY:  return 3.0    // fresh yeast is ~⅓ the strength by weight
        case .SD:  return 1.0
        }
    }

    /// Hydration of the starter itself (fraction of flour weight). Sourdough only.
    /// Liquid (100%) is the most common for pizza.
    var starterHydration: Double { self == .SD ? 1.0 : 0.0 }

    /// Reference starter quantity (fraction of flour) at reference conditions.
    var referenceStarter: Double { self == .SD ? 0.18 : 0.0 }
}
