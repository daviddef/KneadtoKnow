import Foundation

/// The oven you'll bake in — sets the temperature and time advice.
enum OvenType: String, CaseIterable, Identifiable, Codable {
    case home      // conventional kitchen oven
    case gas       // gas-fired pizza oven (Ooni/Gozney etc.)
    case wood      // wood-fired

    var id: String { rawValue }

    var label: String {
        switch self {
        case .home: return "Home oven"
        case .gas:  return "Gas pizza"
        case .wood: return "Wood-fired"
        }
    }

    var blurb: String {
        switch self {
        case .home: return "A standard kitchen oven reaches ~250 °C. Use a preheated stone or steel and bake longer."
        case .gas:  return "A gas pizza oven (Ooni, Gozney…) hits 400–500 °C for fast, even bakes with easy control."
        case .wood: return "Wood-fired ovens give intense radiant heat (450–500 °C) and a smoky char — the Neapolitan classic."
        }
    }

    /// Bake temperature and time guidance for a style in this oven.
    func bakeAdvice(for style: PizzaStyle) -> String {
        // Focaccia and deep pan bakes are moderate-heat, regardless of oven.
        if style.id == "focaccia" {
            return "Bake at ~220 °C for 20–25 minutes, until deep golden and crisp underneath."
        }
        if style.shape == .rectangular {
            switch self {
            case .home: return "Bake at ~250 °C (max) on the lower shelf for 12–18 minutes, until the base is crisp and the edges caramelised."
            case .gas, .wood: return "Pan styles want moderate heat — aim for ~280–320 °C for 10–15 minutes so the inside cooks before the top burns."
            }
        }
        switch self {
        case .home: return "Bake at your oven's max (~250 °C) on a preheated stone or steel for 8–12 minutes."
        case .gas:  return "Bake at ~430 °C for about 90 seconds, turning once or twice."
        case .wood: return "Bake at ~470 °C for 60–90 seconds, turning, for a leopard-spotted crust."
        }
    }
}
