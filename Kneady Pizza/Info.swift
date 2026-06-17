import SwiftUI

/// A short, tappable explanation of one control — what it is, how it
/// mathematically affects the dough, and a "typical gotcha" to avoid.
struct InfoTopic: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    let gotcha: String

    static let style = InfoTopic(id: "style", title: "Pizza style",
        body: "Each style sets a recipe profile — hydration, salt, oil, honey — plus its thickness and the yeasts that suit it.\n\nMaths: these become the baker's percentages every other number is built from.",
        gotcha: "Picking a style won't fix the wrong flour or oven. A Neapolitan needs a screaming-hot bake; in a home oven it'll be pale and bready.")

    static let count = InfoTopic(id: "count", title: "How many pizzas",
        body: "The number of balls (or pans) you want.\n\nMaths: total dough = count × weight each. Every ingredient scales straight off the total, so doubling the count doubles everything.",
        gotcha: "Don't forget toppings scale too — tap the basket icon to plan them, or you'll be one ball of mozzarella short.")

    static let size = InfoTopic(id: "size", title: "Pizzas & size",
        body: "How many pizzas, and how big each one is (or how heavy each ball should be).\n\nMaths: total dough = count × weight each, so everything scales straight off this. From a diameter, area = π × (d ÷ 2)², then ball = area × a thickness factor (~0.38 for Neapolitan). ~250–280 g suits a 12″ pizza. Tap the basket to plan toppings.",
        gotcha: "Too-heavy balls bake thick and doughy in the middle; too-light ones tear when you stretch them.")

    static let yeast = InfoTopic(id: "yeast", title: "Yeast or starter",
        body: "The leavening. You don't set the amount — it's worked out from time and temperature, then converted by type.\n\nMaths: instant (IDY) ×1, active dry ×1.25, fresh ×3. Sourdough is dosed as a % of flour instead, and its flour & water count toward the totals.\n\nCheck your yeast is in date and fresh — old or stale yeast simply won't rise. If unsure, proof a pinch in warm water with a little sugar; it should foam in 10 minutes.",
        gotcha: "Dead yeast is the #1 cause of flat dough. Water hotter than ~50 °C kills it; fridge-cold water barely wakes it.")

    static let preferment = InfoTopic(id: "preferment", title: "Pre-ferment",
        body: "A poolish or biga ferments part of the flour ahead for deeper flavour and strength.\n\nMaths: we carve the pre-ferment's flour and water out of the totals, so your overall hydration stays exactly what you set. Poolish is 100% hydration (~30% of flour); biga ~50% hydration (~50% of flour).",
        gotcha: "Over-ferment the poolish and it collapses and smells sharply of alcohol — use it when domed and bubbly, not sunken.")

    static let temperature = InfoTopic(id: "temperature", title: "Room temperature",
        body: "How warm the room is, used to time the rise and dose the yeast.\n\nMaths: fermentation roughly doubles in speed per +10 °C (Q10 ≈ 2), so yeast = reference × (8 h ÷ hours) × 2^((20 − temp) ÷ 10). Warmer → less yeast and a faster rise.",
        gotcha: "A reading that's way off throws the whole plan out — a dough left somewhere warmer than you told the app will over-proof and deflate.")

    static let ferment = InfoTopic(id: "ferment", title: "Fermentation method",
        body: "Quick: warm water (~40 °C), extra yeast and a little honey force a rise in about 3 hours (serve time jumps to now + 3 h).\nWarm: a room-temperature rise over several hours.\nCold: 24–72 h in the fridge (~4 °C) for deeper flavour.\n\nMaths: each sets the time and temperature behind the yeast dose. Cold uses fridge temperature, so far less yeast; quick triples the dose for speed.",
        gotcha: "Cold dough must come back to room temperature before shaping — straight from the fridge it's tight and tears.")

    static let autolyse = InfoTopic(id: "autolyse", title: "Autolyse",
        body: "An autolyse mixes just the flour and water first, then rests 20–60 minutes before the salt and yeast (and any pre-ferment) go in.\n\nWhy: the flour hydrates fully and develops natural extensibility, so the dough stretches easily without springing back. It pairs well with both poolish and biga.\n\nMaths: it changes no quantities — it's purely a process step, adding a short rest to your timeline.",
        gotcha: "Hold the salt back until after the rest — added early it tightens the gluten and slows hydration, defeating the point.")

    static let recipe = InfoTopic(id: "recipe", title: "Recipe proportions",
        body: "Baker's percentages — each ingredient as a percentage of the flour weight (flour is always 100%).\n\nMaths: flour = total ÷ (1 + hydration + salt + oil + honey + yeast); each ingredient = flour × its %. Hydration is water ÷ flour — higher is wetter, airier and stickier. Colours flag values outside the safe range.",
        gotcha: "Too much water makes the balls sticky and unworkable; too much salt (over ~4%) slows or kills the yeast. Weak, low-protein flour can't hold high hydration.")

    static let schedule = InfoTopic(id: "schedule", title: "When will you serve?",
        body: "Pick when you want to eat; the whole plan is worked backward from there. Set the serve time (or, for Quick, how soon) and the app tells you when to start.\n\nMaths: a dough needs a set amount of fermentation (from temperature + method), so start = serve − (pre-ferment + bulk + proof).\n\nNot enough time? Rather than just rushing, the app first nudges the plan to fit — it warms the proof and raises the yeast so the dough still rises properly in the window you have. You'll see an \"auto-adjusted\" note when it does this. If it still can't fit even warm, it flags the plan and offers a Quick dough.",
        gotcha: "Leave a buffer — stretching, topping and baking each pizza takes longer than you think, especially one oven at a time.")
}

/// The sheet that shows a single topic, including its gotcha.
struct InfoSheet: View {
    let topic: InfoTopic
    var humourEnabled: Bool = true
    @Environment(\.dismiss) private var dismiss
    @State private var joke = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(topic.body)
                        .font(.rounded(15))
                        .foregroundStyle(Palette.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Typical gotcha")
                        }
                        .font(.rounded(13, weight: .bold))
                        .foregroundStyle(Palette.amber)
                        Text(topic.gotcha)
                            .font(.rounded(14))
                            .foregroundStyle(Palette.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.amber.opacity(0.12)))

                    if humourEnabled {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "face.smiling.inverse")
                                Text("While the yeast works…")
                            }
                            .font(.rounded(13, weight: .bold))
                            .foregroundStyle(Palette.sage)
                            Text(joke)
                                .font(.rounded(14))
                                .italic()
                                .foregroundStyle(Palette.text)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.sage.opacity(0.12)))
                    }
                }
                .padding(20)
            }
            .onAppear {
                if humourEnabled && joke.isEmpty { joke = Jokes.forTopic(id: topic.id, title: topic.title) }
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle(topic.title)
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
