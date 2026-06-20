import SwiftUI

/// A short, friendly swipe-through of the app's handy gestures and features.
/// Works both as a first-run sheet and from Guides & Info.
struct WalkthroughView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private let tips = FeatureTips.all

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Palette.background.ignoresSafeArea()

            VStack(spacing: 16) {
                TabView(selection: $page) {
                    ForEach(Array(tips.enumerated()), id: \.element.id) { idx, tip in
                        card(tip).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                // Dots
                HStack(spacing: 7) {
                    ForEach(tips.indices, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Palette.accent : Palette.textSoft.opacity(0.3))
                            .frame(width: i == page ? 9 : 7, height: i == page ? 9 : 7)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }

                Button {
                    if page < tips.count - 1 {
                        Haptics.tap()
                        withAnimation { page += 1 }
                    } else {
                        Haptics.success()
                        dismiss()
                    }
                } label: {
                    Text(page < tips.count - 1 ? "Next" : "Let's bake!")
                        .font(.rounded(17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(TactileButtonStyle(isProminent: true))
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
            .padding(.top, 24)

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.rounded(15, weight: .bold))
                    .foregroundStyle(Palette.textSoft)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
            .padding(.top, 6)
        }
        .tint(Palette.accent)
    }

    private func card(_ tip: FeatureTip) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)
            ZStack {
                Circle()
                    .fill(Palette.accent.opacity(0.12))
                    .frame(width: 132, height: 132)
                Image(systemName: tip.icon)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(Palette.accent)
            }
            VStack(spacing: 12) {
                Text(tip.title)
                    .font(.rounded(26, weight: .bold))
                    .foregroundStyle(Palette.text)
                    .multilineTextAlignment(.center)
                Text(tip.blurb)
                    .font(.rounded(17))
                    .foregroundStyle(Palette.textSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}
