import SwiftUI

// MARK: - Selection tips

/// One tailored tip for the baker's current selection.
struct SelectionTip: Identifiable {
    let id = UUID()
    let category: String
    let text: String
    let icon: String
    let tint: InfoTint
}

/// Builds a short, tailored set of tips from the whole selection — style,
/// fermentation method, pre-ferment, autolyse, gluten-free and skill level.
enum SelectionTips {
    static func make(for input: DoughInput) -> [SelectionTip] {
        var tips: [SelectionTip] = [styleTip(input.style), fermentTip(input.ferment)]

        if input.prefermentActive { tips.append(prefermentTip(input.preferment)) }

        if input.useAutolyse && !input.glutenFree {
            tips.append(.init(category: "Autolyse",
                              text: "You're resting flour + water first — keep the salt and yeast out until after the rest, or the dough tightens up and fights you.",
                              icon: "timer", tint: .amber))
        }

        if input.yeast.isSourdough {
            tips.append(.init(category: "Sourdough starter",
                              text: "Feed your starter so it's lively and domed before mixing — a sluggish starter means a sluggish rise.",
                              icon: "leaf.fill", tint: .sage))
        }

        if input.glutenFree {
            tips.append(.init(category: "Gluten-free",
                              text: "No gluten means no kneading. Press it out with wet or oiled hands, and par-bake the bare base before topping to dodge a gummy middle.",
                              icon: "allergens", tint: .cool))
            if !input.binderInBlend {
                tips.append(.init(category: "Binder",
                                  text: "Your blend needs a binder. If it already lists xanthan or psyllium, switch 'binder already in my blend' on — doubling up turns the crust slimy.",
                                  icon: "circle.hexagongrid.fill", tint: .amber))
            }
        }

        tips.append(generalTip(simple: input.keepItSimple))
        return tips
    }

    // MARK: Per-selection tips

    private static func styleTip(_ style: PizzaStyle) -> SelectionTip {
        switch style.id {
        case "neapolitan", "neapolitan-contemporary":
            return .init(category: style.name,
                         text: "Bake it screaming hot on a fully preheated stone or steel — a cool home oven gives a pale, bready crust. Stretch by hand and keep that puffy rim.",
                         icon: "flame.fill", tint: .warm)
        case "newyork":
            return .init(category: style.name,
                         text: "Big, foldable slices: low-moisture mozzarella, a light hand with the sauce, and a hot steel near the top of the oven.",
                         icon: "flame.fill", tint: .warm)
        case "detroit":
            return .init(category: style.name,
                         text: "Press into a well-oiled pan right to the corners, push the cheese to the very edges for the crispy frico, then sauce in stripes on top.",
                         icon: "square.grid.3x3.fill", tint: .amber)
        case "sfincione":
            return .init(category: style.name,
                         text: "A thick, fluffy Sicilian base — press into an oiled pan, top generously, and bake until golden underneath.",
                         icon: "square.fill", tint: .amber)
        case "roman":
            return .init(category: style.name,
                         text: "Thin and crisp — roll or press it out and bake hot for that cracker-like snap.",
                         icon: "flame.fill", tint: .warm)
        case "everyday":
            return .init(category: style.name,
                         text: "Forgiving and easy — great on a tray or stone in a home oven. Don't overthink it.",
                         icon: "house.fill", tint: .sage)
        case "focaccia":
            return .init(category: style.name,
                         text: "Dimple it deeply, drizzle with olive oil and flaky salt, and let it puff in the pan before baking for an airy crumb.",
                         icon: "drop.fill", tint: .cool)
        default:
            return .init(category: style.name,
                         text: "Preheat your surface fully and go easy on the toppings — a soggy middle is the #1 home-oven trap.",
                         icon: "flame.fill", tint: .warm)
        }
    }

    private static func fermentTip(_ ferment: FermentStyle) -> SelectionTip {
        switch ferment {
        case .quick:
            return .init(category: "Quick proof",
                         text: "Fast track! Keep it somewhere warm and watch the dough, not the clock — it can over-proof in a blink.",
                         icon: "bolt.fill", tint: .warm)
        case .sameDay:
            return .init(category: "Warm proof",
                         text: "Let it rise at room temperature until puffy and jiggly. Warm kitchen = faster, cool = slower — go by the look.",
                         icon: "house.fill", tint: .amber)
        case .cold:
            return .init(category: "Cold proof",
                         text: "Big flavour from the long fridge rest — just bring the dough back to room temperature (~2 h) before shaping, or it'll tear.",
                         icon: "snowflake", tint: .cool)
        }
    }

    private static func prefermentTip(_ preferment: Preferment) -> SelectionTip {
        switch preferment {
        case .poolish:
            return .init(category: "Poolish",
                         text: "Use it when it's domed and bubbly with the bubbles just starting to fall — not sunken or boozy.",
                         icon: "drop.fill", tint: .cool)
        case .biga:
            return .init(category: "Biga",
                         text: "Ready when it's risen and smells sweet-yeasty — tear the stiff biga into the final mix.",
                         icon: "square.stack.3d.up.fill", tint: .amber)
        }
    }

    private static func generalTip(simple: Bool) -> SelectionTip {
        simple
            ? .init(category: "Tip", text: "Weigh everything on a scale — the yeast amounts are tiny and really do matter.", icon: "scalemass.fill", tint: .accent)
            : .init(category: "Tip", text: "Stretch, don't roll — a rolling pin crushes out the gas you spent hours building.", icon: "hand.draw.fill", tint: .accent)
    }
}

// MARK: - Sheet

/// Tapping the total-dough banner expands this: a recap of the selection plus
/// tailored tips for the chosen style, method and options.
struct SelectionTipsSheet: View {
    let input: DoughInput
    @Environment(\.dismiss) private var dismiss

    private var tips: [SelectionTip] { SelectionTips.make(for: input) }

    private var summaryLine: String {
        var parts = ["\(input.style.originFlag) \(input.style.name)", input.ferment.label]
        if input.prefermentActive { parts.append(input.preferment.name) }
        if input.glutenFree { parts.append("Gluten-free") }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("YOUR PIZZA PLAN")
                            .font(.rounded(11, weight: .bold))
                            .foregroundStyle(Palette.textSoft)
                        Text(summaryLine)
                            .font(.rounded(18, weight: .bold))
                            .foregroundStyle(Palette.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    ForEach(tips) { tip in
                        HStack(alignment: .top, spacing: 11) {
                            Image(systemName: tip.icon)
                                .font(.rounded(15, weight: .bold))
                                .foregroundStyle(tip.tint.color)
                                .frame(width: 24, height: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tip.category)
                                    .font(.rounded(14, weight: .bold))
                                    .foregroundStyle(Palette.text)
                                Text(tip.text)
                                    .font(.rounded(13))
                                    .foregroundStyle(Palette.textSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(tip.tint.color.opacity(0.10)))
                        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(tip.tint.color.opacity(0.30), lineWidth: 1))
                    }
                }
                .padding(20)
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle("Tips for your pizza")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.rounded(16, weight: .semibold))
                        .tint(Palette.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .tint(Palette.accent)
    }
}
