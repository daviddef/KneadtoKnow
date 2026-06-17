import Foundation

/// Formats weights and lengths for the metric / imperial toggle.
/// `metric` is true when the user's length unit is centimetres.
enum Units {
    static func isMetric(_ lengthUnit: LengthUnit) -> Bool { lengthUnit == .cm }

    /// A weight, in grams, formatted for the chosen system.
    static func weight(_ grams: Double, metric: Bool) -> String {
        if metric {
            if grams >= 1000 { return String(format: "%.2f kg", grams / 1000) }
            if grams >= 100  { return "\(Int(grams.rounded())) g" }
            return String(format: "%.1f g", (grams * 10).rounded() / 10)
        } else {
            let oz = grams * 0.0352739619
            if oz >= 16 {
                let lb = oz / 16
                return String(format: "%.2f lb", lb)
            }
            return String(format: "%.1f oz", oz)
        }
    }

    /// A length, given in the active `unit`, formatted with its suffix.
    static func length(_ value: Double, unit: LengthUnit) -> String {
        unit == .cm ? String(format: "%.0f cm", value) : String(format: "%.1f in", value)
    }
}
