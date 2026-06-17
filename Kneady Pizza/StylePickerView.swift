import SwiftUI

/// A roomy style picker — each option on its own row with a one-line spec.
struct StylePickerView: View {
    @ObservedObject var vm: DoughViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Difficulty runs Villager (easiest) → Sunday Pizzaiolo → Roman Soldier (hardest). The time is a rough warm-proof estimate.")
                        .font(.rounded(11))
                        .foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 2)

                    if vm.hasFavourite {
                        favouriteRow
                    }
                    ForEach(PizzaStyle.all) { style in
                        styleRow(style)
                    }
                }
                .padding(20)
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle("Pizza style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.rounded(16, weight: .semibold))
                        .tint(Palette.accent)
                }
            }
        }
        .tint(Palette.accent)
    }

    private var favouriteRow: some View {
        Button {
            vm.applyFavourite()
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "star.fill").foregroundStyle(Palette.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("My Favourite")
                        .font(.rounded(17, weight: .semibold))
                        .foregroundStyle(Palette.text)
                    Text(vm.favouriteSpec ?? "Your saved setup")
                        .font(.rounded(12))
                        .foregroundStyle(Palette.textSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func complexityColor(_ c: Complexity) -> Color {
        switch c {
        case .beginner:     return Palette.sage
        case .intermediate: return Palette.amber
        case .advanced:     return Palette.danger
        }
    }

    private func complexityBadge(_ c: Complexity) -> some View {
        Text(c.label)
            .font(.rounded(10, weight: .bold))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(Capsule().fill(complexityColor(c).opacity(0.16)))
            .foregroundStyle(complexityColor(c))
    }

    private func styleRow(_ style: PizzaStyle) -> some View {
        let isOn = style.id == vm.input.style.id
        return Button {
            vm.select(style: style)
            dismiss()
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(style.originFlag)
                            .font(.system(size: 18))
                        Text(style.name)
                            .font(.rounded(17, weight: .semibold))
                            .foregroundStyle(Palette.text)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Text(style.shape.label)
                            .font(.rounded(10, weight: .bold))
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Capsule().fill(Palette.accent.opacity(0.14)))
                            .foregroundStyle(Palette.accent)
                    }
                    HStack(spacing: 6) {
                        complexityBadge(style.complexity)
                        Text("≈ \(Int(style.indicativeHours.rounded())) h")
                            .font(.rounded(11, weight: .medium))
                            .foregroundStyle(Palette.textSoft)
                    }
                    Text(style.specLine)
                        .font(.rounded(12))
                        .foregroundStyle(Palette.textSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                Spacer(minLength: 8)
                if isOn {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Palette.accent)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}
