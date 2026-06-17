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

// MARK: - Palette
//
// A calm "flour & terracotta" palette. Warm, low-contrast, restful — the
// colours of a quiet kitchen at dawn.

enum Palette {
    /// The page background — soft, warm flour.
    static let background = Color(
        light: Color(red: 0.95, green: 0.92, blue: 0.86),
        dark:  Color(red: 0.11, green: 0.10, blue: 0.09)
    )

    /// Raised surfaces (cards, buttons) sit just above the background.
    static let surface = Color(
        light: Color(red: 0.98, green: 0.96, blue: 0.91),
        dark:  Color(red: 0.16, green: 0.15, blue: 0.13)
    )

    /// Recessed wells (input tracks).
    static let well = Color(
        light: Color(red: 0.92, green: 0.88, blue: 0.81),
        dark:  Color(red: 0.09, green: 0.08, blue: 0.07)
    )

    /// Primary text — soft espresso, never pure black.
    static let text = Color(
        light: Color(red: 0.24, green: 0.20, blue: 0.16),
        dark:  Color(red: 0.92, green: 0.88, blue: 0.82)
    )

    /// Secondary / supporting text.
    static let textSoft = Color(
        light: Color(red: 0.48, green: 0.42, blue: 0.36),
        dark:  Color(red: 0.66, green: 0.61, blue: 0.55)
    )

    /// Warm terracotta accent.
    static let accent = Color(
        light: Color(red: 0.78, green: 0.48, blue: 0.32),
        dark:  Color(red: 0.85, green: 0.55, blue: 0.39)
    )

    /// Sage / basil secondary accent.
    static let sage = Color(
        light: Color(red: 0.54, green: 0.64, blue: 0.48),
        dark:  Color(red: 0.58, green: 0.68, blue: 0.52)
    )

    /// Warm amber — gentle "outside the sweet spot" warning.
    static let amber = Color(
        light: Color(red: 0.83, green: 0.58, blue: 0.18),
        dark:  Color(red: 0.90, green: 0.66, blue: 0.27)
    )

    /// Muted clay-red — stronger "well outside range" warning.
    static let danger = Color(
        light: Color(red: 0.78, green: 0.32, blue: 0.26),
        dark:  Color(red: 0.86, green: 0.42, blue: 0.36)
    )

    /// Warm red — "keep it somewhere warm" rests.
    static let warm = Color(
        light: Color(red: 0.80, green: 0.38, blue: 0.28),
        dark:  Color(red: 0.90, green: 0.48, blue: 0.38)
    )

    /// Cool blue — "in the fridge" rests.
    static let cool = Color(
        light: Color(red: 0.28, green: 0.52, blue: 0.74),
        dark:  Color(red: 0.46, green: 0.66, blue: 0.86)
    )

    // Soft neumorphic shadows.
    static let shadowDark = Color(
        light: Color(red: 0.74, green: 0.68, blue: 0.59).opacity(0.55),
        dark:  Color.black.opacity(0.55)
    )
    static let shadowLight = Color(
        light: Color.white.opacity(0.85),
        dark:  Color.white.opacity(0.05)
    )
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
                    .fill(isProminent ? Palette.accent : Palette.surface)
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
