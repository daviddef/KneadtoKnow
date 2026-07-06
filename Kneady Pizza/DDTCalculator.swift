import SwiftUI

/// How the dough is mixed — each method adds its own friction heat, which the
/// water temperature has to compensate for to land on the same final dough
/// temperature.
enum FrictionMethod: String, CaseIterable, Identifiable {
    case hand, stand, spiral

    var id: String { rawValue }

    var label: String {
        switch self {
        case .hand:   return "By hand"
        case .stand:  return "Stand mixer"
        case .spiral: return "Spiral mixer"
        }
    }

    /// Typical friction factor in °C — how much the mixing itself warms the
    /// dough as it develops. Hands barely warm it; a fast spiral mixer can
    /// add several degrees. These are reasonable starting points, not a
    /// measurement of your specific machine.
    var frictionFactorC: Double {
        switch self {
        case .hand:   return 1
        case .stand:  return 3
        case .spiral: return 4
        }
    }
}

/// The desired-dough-temperature calculation: work out what water temperature
/// gets you to a target dough temperature, given how warm your flour, your
/// kitchen, and your mixing method already are.
enum DDTCalculator {
    /// Water Temp = (3 × DDT) − (Flour Temp + Room Temp + Friction Factor).
    static func waterTemperature(ddt: Double, flourTemp: Double, roomTemp: Double, friction: Double) -> Double {
        (3 * ddt) - (flourTemp + roomTemp + friction)
    }
}

/// A standalone tool: dial in a target dough temperature and get the water
/// temperature to mix with. Reachable from Guides & Info — it doesn't touch
/// the main recipe, since flour/room temperature at mixing time often isn't
/// the same as the fermentation temperature set elsewhere in the app.
struct DDTCalculatorView: View {
    @State private var ddt: Double = 24
    @State private var flourTemp: Double = 20
    @State private var roomTemp: Double = 20
    @State private var method: FrictionMethod = .hand

    private var waterTemp: Double {
        DDTCalculator.waterTemperature(ddt: ddt, flourTemp: flourTemp, roomTemp: roomTemp, friction: method.frictionFactorC)
    }

    private var resultNote: (text: String, color: Color)? {
        if waterTemp < 1 {
            return ("Below fridge-cold — use ice water, and expect it to take a minute to fully dissolve in.", Palette.danger)
        }
        if waterTemp > 45 {
            return ("Very warm — stay under ~50 °C, or it risks killing the yeast outright.", Palette.amber)
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Every ingredient's own temperature — the flour, the room, even the friction of mixing — ends up in the final dough. This works out the one thing you actually control: the water.")
                        .font(.rounded(13))
                        .foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 18) {
                    TactileSlider(
                        title: "Target dough temperature",
                        value: $ddt, range: 18...28, step: 0.5,
                        valueText: String(format: "%.1f °C", ddt),
                        caption: "24–26 °C is the usual room-temperature-proof target."
                    )
                    TactileSlider(
                        title: "Flour temperature",
                        value: $flourTemp, range: 4...30, step: 0.5,
                        valueText: String(format: "%.1f °C", flourTemp),
                        caption: "Straight from a cool pantry or the fridge? Use that, not the room's."
                    )
                    TactileSlider(
                        title: "Room temperature",
                        value: $roomTemp, range: 4...35, step: 0.5,
                        valueText: String(format: "%.1f °C", roomTemp)
                    )
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MIXING METHOD")
                            .font(.rounded(11, weight: .bold))
                            .foregroundStyle(Palette.textSoft)
                        TactileSegmented(options: FrictionMethod.allCases, selection: $method) { $0.label }
                        Text("Friction factor ≈ \(String(format: "%.0f", method.frictionFactorC)) °C — a rough industry rule of thumb, not a measurement of your machine.")
                            .font(.rounded(11))
                            .foregroundStyle(Palette.textSoft)
                    }
                }
                .padding(18)
                .softCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("USE WATER AT")
                        .font(.rounded(11, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    Text(String(format: "%.1f °C", waterTemp))
                        .font(.rounded(40, weight: .heavy))
                        .foregroundStyle(Palette.accent)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: waterTemp)
                    if let note = resultNote {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(note.text)
                        }
                        .font(.rounded(12, weight: .medium))
                        .foregroundStyle(note.color)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .softCard()

                Text("The dough's own fermentation temperature (set on the main screen) is a separate thing — this is only about what to mix with, so the dough starts life at the temperature you meant it to.")
                    .font(.rounded(11))
                    .foregroundStyle(Palette.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Water Temperature")
        .navigationBarTitleDisplayMode(.inline)
    }
}
