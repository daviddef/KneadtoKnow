import SwiftUI

// MARK: - Dynamic colour helper

extension Color {
    /// Creates a colour that adapts to light / dark mode.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Theme

/// The app's two looks: calm "Classic" (flour & terracotta) and a high-energy
/// "Vibrant Pizzeria".
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case classic, fun
    var id: String { rawValue }
    var label: String { self == .classic ? "Classic" : "Vibrant" }
}

/// Global appearance preference, persisted. Views that observe it re-render
/// (and so re-read `Palette`) when the theme changes.
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    private let key = "appTheme.v1"
    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: key) }
    }
    private init() {
        theme = AppTheme(rawValue: UserDefaults.standard.string(forKey: key) ?? "") ?? .classic
    }
}

// MARK: - Palette
//
// Two colour sets, chosen by the current theme. "Classic" is a calm flour &
// terracotta palette; "Vibrant Pizzeria" is bold tomato / basil / mozzarella.

private struct PaletteSet {
    let background, surface, well, text, textSoft, accent, sage, amber, danger, warm, cool, shadowDark, shadowLight: Color
}

enum Palette {
    private static let classic = PaletteSet(
        background:  Color(light: Color(red: 0.95, green: 0.92, blue: 0.86), dark: Color(red: 0.11, green: 0.10, blue: 0.09)),
        surface:     Color(light: Color(red: 0.98, green: 0.96, blue: 0.91), dark: Color(red: 0.16, green: 0.15, blue: 0.13)),
        well:        Color(light: Color(red: 0.92, green: 0.88, blue: 0.81), dark: Color(red: 0.09, green: 0.08, blue: 0.07)),
        text:        Color(light: Color(red: 0.24, green: 0.20, blue: 0.16), dark: Color(red: 0.92, green: 0.88, blue: 0.82)),
        textSoft:    Color(light: Color(red: 0.48, green: 0.42, blue: 0.36), dark: Color(red: 0.66, green: 0.61, blue: 0.55)),
        accent:      Color(light: Color(red: 0.78, green: 0.48, blue: 0.32), dark: Color(red: 0.85, green: 0.55, blue: 0.39)),
        sage:        Color(light: Color(red: 0.54, green: 0.64, blue: 0.48), dark: Color(red: 0.58, green: 0.68, blue: 0.52)),
        amber:       Color(light: Color(red: 0.83, green: 0.58, blue: 0.18), dark: Color(red: 0.90, green: 0.66, blue: 0.27)),
        danger:      Color(light: Color(red: 0.78, green: 0.32, blue: 0.26), dark: Color(red: 0.86, green: 0.42, blue: 0.36)),
        warm:        Color(light: Color(red: 0.80, green: 0.38, blue: 0.28), dark: Color(red: 0.90, green: 0.48, blue: 0.38)),
        cool:        Color(light: Color(red: 0.28, green: 0.52, blue: 0.74), dark: Color(red: 0.46, green: 0.66, blue: 0.86)),
        shadowDark:  Color(light: Color(red: 0.74, green: 0.68, blue: 0.59).opacity(0.55), dark: Color.black.opacity(0.55)),
        shadowLight: Color(light: Color.white.opacity(0.85), dark: Color.white.opacity(0.05))
    )

    // Vibrant Pizzeria: tomato red, basil green, mozzarella cream, sunny yellow.
    private static let fun = PaletteSet(
        background:  Color(light: Color(red: 1.00, green: 0.97, blue: 0.90), dark: Color(red: 0.12, green: 0.10, blue: 0.10)),
        surface:     Color(light: Color(red: 1.00, green: 0.99, blue: 0.95), dark: Color(red: 0.18, green: 0.15, blue: 0.15)),
        well:        Color(light: Color(red: 0.97, green: 0.93, blue: 0.84), dark: Color(red: 0.10, green: 0.09, blue: 0.09)),
        text:        Color(light: Color(red: 0.18, green: 0.14, blue: 0.12), dark: Color(red: 0.97, green: 0.94, blue: 0.88)),
        textSoft:    Color(light: Color(red: 0.45, green: 0.39, blue: 0.35), dark: Color(red: 0.72, green: 0.66, blue: 0.60)),
        accent:      Color(light: Color(red: 0.87, green: 0.24, blue: 0.20), dark: Color(red: 0.95, green: 0.34, blue: 0.30)),  // tomato
        sage:        Color(light: Color(red: 0.28, green: 0.66, blue: 0.34), dark: Color(red: 0.36, green: 0.78, blue: 0.44)),  // basil
        amber:       Color(light: Color(red: 0.95, green: 0.68, blue: 0.12), dark: Color(red: 1.00, green: 0.78, blue: 0.24)),  // sunny
        danger:      Color(light: Color(red: 0.80, green: 0.18, blue: 0.15), dark: Color(red: 0.92, green: 0.30, blue: 0.26)),
        warm:        Color(light: Color(red: 0.92, green: 0.36, blue: 0.24), dark: Color(red: 0.97, green: 0.46, blue: 0.34)),
        cool:        Color(light: Color(red: 0.16, green: 0.56, blue: 0.86), dark: Color(red: 0.38, green: 0.70, blue: 0.96)),
        shadowDark:  Color(light: Color(red: 0.86, green: 0.66, blue: 0.50).opacity(0.55), dark: Color.black.opacity(0.55)),
        shadowLight: Color(light: Color.white.opacity(0.90), dark: Color.white.opacity(0.06))
    )

    private static var c: PaletteSet { ThemeManager.shared.theme == .fun ? fun : classic }

    static var background: Color  { c.background }
    static var surface: Color     { c.surface }
    static var well: Color        { c.well }
    static var text: Color        { c.text }
    static var textSoft: Color    { c.textSoft }
    static var accent: Color      { c.accent }
    static var sage: Color        { c.sage }
    static var amber: Color       { c.amber }
    static var danger: Color      { c.danger }
    static var warm: Color        { c.warm }
    static var cool: Color        { c.cool }
    static var shadowDark: Color  { c.shadowDark }
    static var shadowLight: Color { c.shadowLight }

    /// True when the high-energy "Vibrant Pizzeria" look is active. Used to gate
    /// playful flourishes so the calm "Classic" look stays understated.
    static var isVibrant: Bool { ThemeManager.shared.theme == .fun }

    /// Fill for prominent buttons and selected pills: a warm tomato→sunny gradient
    /// in Vibrant, a flat accent in Classic.
    static var accentFill: AnyShapeStyle {
        isVibrant
            ? AnyShapeStyle(LinearGradient(colors: [c.accent, c.amber],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing))
            : AnyShapeStyle(c.accent)
    }
}

// MARK: - Soft / tactile surfaces

/// A raised, pillow-soft card with dual neumorphic shadows.
struct SoftCard: ViewModifier {
    var cornerRadius: CGFloat = 24
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Palette.surface)
            )
            .shadow(color: Palette.shadowDark, radius: 10, x: 8, y: 8)
            .shadow(color: Palette.shadowLight, radius: 10, x: -8, y: -8)
    }
}

/// A recessed well, for input tracks and toggles.
struct SoftWell: ViewModifier {
    var cornerRadius: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Palette.well)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Palette.shadowDark.opacity(0.4), lineWidth: 1)
                            .blur(radius: 1)
                            .offset(x: 1, y: 1)
                            .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
            )
    }
}

extension View {
    func softCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(SoftCard(cornerRadius: cornerRadius))
    }
    func softWell(cornerRadius: CGFloat = 18) -> some View {
        modifier(SoftWell(cornerRadius: cornerRadius))
    }
}

// MARK: - Tactile button style

/// A pressable, pillow-like button that "sinks" when touched.
struct TactileButtonStyle: ButtonStyle {
    var isProminent: Bool = false
    var cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .foregroundStyle(isProminent ? Color.white : Palette.text)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isProminent ? Palette.accentFill : AnyShapeStyle(Palette.surface))
            )
            .shadow(color: Palette.shadowDark,
                    radius: pressed ? 3 : 9,
                    x: pressed ? 2 : 6,
                    y: pressed ? 2 : 6)
            .shadow(color: Palette.shadowLight,
                    radius: pressed ? 3 : 9,
                    x: pressed ? -2 : -6,
                    y: pressed ? -2 : -6)
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressed)
    }
}

// MARK: - Haptics

enum Haptics {
    static func tap() {
        let g = UIImpactFeedbackGenerator(style: .soft)
        g.impactOccurred(intensity: 0.6)
    }
    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Rounded fonts

extension Font {
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
