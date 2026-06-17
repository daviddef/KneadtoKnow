import SwiftUI

// MARK: - Section heading

struct SectionLabel: View {
    let index: Int
    let title: String
    var body: some View {
        HStack(spacing: 10) {
            Text("\(index)")
                .font(.rounded(13, weight: .bold))
                .foregroundStyle(Palette.accent)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Palette.accent.opacity(0.14)))
            Text(title)
                .font(.rounded(15, weight: .semibold))
                .foregroundStyle(Palette.textSoft)
            Spacer()
        }
    }
}

/// A titled card wrapper used for each input group, with an optional info button.
struct InputCard<Content: View>: View {
    let index: Int
    let title: String
    var info: InfoTopic? = nil
    var onInfo: ((InfoTopic) -> Void)? = nil
    var accessoryIcon: String? = nil
    var onAccessory: (() -> Void)? = nil
    var summary: String = ""
    var collapsed: Bool = false
    var onToggleCollapse: (() -> Void)? = nil
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Text("\(index)")
                    .font(.rounded(13, weight: .bold))
                    .foregroundStyle(Palette.accent)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Palette.accent.opacity(0.14)))
                // Collapsed: a clean one-line summary stands in for the title.
                if collapsed && !summary.isEmpty {
                    Text(summary)
                        .font(.rounded(15, weight: .semibold))
                        .foregroundStyle(Palette.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .truncationMode(.tail)
                } else {
                    Text(title)
                        .font(.rounded(15, weight: .semibold))
                        .foregroundStyle(Palette.textSoft)
                }
                Spacer(minLength: 6)
                if let accessoryIcon {
                    Button { onAccessory?(); Haptics.tap() } label: {
                        Image(systemName: accessoryIcon)
                            .font(.rounded(16, weight: .medium))
                            .foregroundStyle(Palette.accent)
                            .frame(width: 34, height: 34)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if let info {
                    Button { onInfo?(info); Haptics.tap() } label: {
                        Image(systemName: "info.circle")
                            .font(.rounded(16, weight: .medium))
                            .foregroundStyle(Palette.accent)
                            .frame(width: 34, height: 34)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if onToggleCollapse != nil {
                    Image(systemName: "chevron.down")
                        .font(.rounded(13, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                        .rotationEffect(.degrees(collapsed ? -90 : 0))
                        .frame(width: 28, height: 34)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard let onToggleCollapse else { return }
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) { onToggleCollapse() }
            }
            if !collapsed { content }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard()
    }
}

// MARK: - Tactile segmented picker

struct TactileSegmented<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String
    /// Spring-animate the selection pill. Turn OFF when the selection also
    /// drives a full theme re-skin (an animated identity swap races the rebuild
    /// and leaves some controls on the old palette).
    var animateSelection: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { option in
                let isOn = option == selection
                Button {
                    if animateSelection {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selection = option
                        }
                    } else {
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) { selection = option }
                    }
                    Haptics.select()
                } label: {
                    Text(label(option))
                        .font(.rounded(14, weight: isOn ? .semibold : .regular))
                        .foregroundStyle(isOn ? Color.white : Palette.textSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(isOn ? Palette.accentFill : AnyShapeStyle(Color.clear))
                                .shadow(color: isOn ? Palette.accent.opacity(0.35) : .clear,
                                        radius: 6, y: 3)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .softWell(cornerRadius: 18)
    }
}

// MARK: - Tactile stepper

struct TactileStepper: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...24

    var body: some View {
        HStack {
            Text(title)
                .font(.rounded(16))
                .foregroundStyle(Palette.text)
            Spacer()
            HStack(spacing: 14) {
                circleButton("minus") {
                    if value > range.lowerBound { value -= 1; Haptics.tap() }
                }
                Text("\(value)")
                    .font(.rounded(22, weight: .semibold))
                    .foregroundStyle(Palette.accent)
                    .frame(minWidth: 34)
                    .contentTransition(.numericText())
                circleButton("plus") {
                    if value < range.upperBound { value += 1; Haptics.tap() }
                }
            }
        }
    }

    private func circleButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.rounded(15, weight: .bold))
                .frame(width: 42, height: 42)
        }
        .buttonStyle(TactileButtonStyle(cornerRadius: 21))
    }
}

// MARK: - Tactile toggle

struct TactileToggle: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isOn.toggle() }
            Haptics.select()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.rounded(16, weight: .medium))
                        .foregroundStyle(Palette.text)
                    if let subtitle {
                        Text(subtitle)
                            .font(.rounded(12))
                            .foregroundStyle(Palette.textSoft)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                ZStack {
                    Capsule()
                        .fill(isOn ? Palette.accent : Palette.well)
                        .frame(width: 52, height: 31)
                    Circle()
                        .fill(Palette.surface)
                        .frame(width: 25, height: 25)
                        .shadow(color: Palette.shadowDark, radius: 2, x: 1, y: 1)
                        .offset(x: isOn ? 10 : -10)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Labelled slider in a well

struct TactileSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    let valueText: String
    /// Accent for the track and value — override to signal a warning band.
    var tint: Color = Palette.accent
    /// Optional caption shown under the slider (e.g. weight guidance).
    var caption: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.rounded(16))
                    .foregroundStyle(Palette.text)
                Spacer()
                Text(valueText)
                    .font(.rounded(17, weight: .semibold))
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
            }
            Slider(value: $value, in: range, step: step) { editing in
                if editing { Haptics.tap() }
            }
            .tint(tint)
            .animation(.easeInOut(duration: 0.25), value: tint)
            if let caption {
                Text(caption)
                    .font(.rounded(11))
                    .foregroundStyle(Palette.textSoft)
            }
        }
    }
}
