import SwiftUI

// MARK: - Definition callout tint

/// A theme-aware tint for a definition callout. Stored as a role (not a Color)
/// so it follows the active theme.
enum InfoTint {
    case accent, sage, amber, cool, warm, danger
    var color: Color {
        switch self {
        case .accent: return Palette.accent
        case .sage:   return Palette.sage
        case .amber:  return Palette.amber
        case .cool:   return Palette.cool
        case .warm:   return Palette.warm
        case .danger: return Palette.danger
        }
    }
}

/// One named item in a topic — shown as a neat, colour-coded callout instead of
/// being buried in a paragraph.
struct InfoDefinition: Identifiable, Equatable {
    var id: String { term }
    let term: String
    let detail: String
    let icon: String
    let tint: InfoTint

    /// The three fermentation methods — reused by the Fermentation and Serve sheets.
    static let fermentMethods: [InfoDefinition] = [
        .init(term: "Quick", detail: "Warm water (~40 °C), extra yeast and a touch of honey force a fast rise — ready in as little as an hour.", icon: "bolt.fill", tint: .warm),
        .init(term: "Warm Proof", detail: "A room-temperature rise over several hours (often overnight). Simple and reliable.", icon: "house.fill", tint: .amber),
        .init(term: "Cold Proof", detail: "24–72 h in the fridge — less yeasty, deeper flavour, more digestible. Let it warm up before shaping.", icon: "snowflake", tint: .cool)
    ]
}

/// A short, tappable explanation of one control — what it is, how it
/// mathematically affects the dough, named items as colour callouts, and the
/// things that'll drive you crazy if you ignore them.
struct InfoTopic: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    /// Optional heading shown above the definition callouts (e.g. "The methods").
    var definitionsTitle: String = ""
    /// Named items rendered as colour-coded callouts.
    var definitions: [InfoDefinition] = []
    /// One or more "things that will drive you crazy" — shown as bullet points.
    let gotcha: [String]

    static let style = InfoTopic(id: "style", title: "Pizza style",
        body: "Each style sets a recipe profile — hydration, salt, oil, honey — plus its thickness and the yeasts that suit it.\n\nMaths: these become the baker's percentages every other number is built from.",
        gotcha: [
            "A fancy style won't rescue weak flour or a sleepy oven — that part's on you, chef.",
            "Neapolitan wants a screaming-hot bake; in a timid home oven it comes out pale and bready, like sad toast."
        ])

    static let count = InfoTopic(id: "count", title: "How many pizzas",
        body: "The number of balls (or pans) you want.\n\nMaths: total dough = count × weight each. Every ingredient scales straight off the total, so doubling the count doubles everything.",
        gotcha: [
            "Toppings scale too! Tap the basket to plan them, or you'll be one tragic ball short of mozzarella."
        ])

    static let size = InfoTopic(id: "size", title: "Pizzas & size",
        body: "How many pizzas, and how big each one is (or how heavy each ball should be).\n\nMaths: total dough = count × weight each, so everything scales straight off this. From a diameter, area = π × (d ÷ 2)², then ball = area × a thickness factor (~0.38 for Neapolitan). ~250–280 g suits a 12″ pizza. Tap the basket to plan toppings.",
        gotcha: [
            "Too-heavy balls bake thick and gluey in the middle — a doughy hug nobody asked for.",
            "Too-light balls tear like wet tissue the second you start stretching."
        ])

    static let yeast = InfoTopic(id: "yeast", title: "Yeast or starter",
        body: "The leavening. You don't set the amount — it's worked out from time and temperature, then converted by type.\n\nCheck your yeast is in date and fresh — old yeast simply won't rise. If unsure, proof a pinch in warm water with a little sugar; it should foam in 10 minutes.",
        definitionsTitle: "The types",
        definitions: [
            .init(term: "Instant (IDY)", detail: "Mix straight into the flour. The baseline dose (×1).", icon: "bolt.fill", tint: .accent),
            .init(term: "Active dry", detail: "About ×1.25 — best bloomed in warm water first.", icon: "drop.fill", tint: .cool),
            .init(term: "Fresh", detail: "About ×3 — crumble it in. Perishable; keep it refrigerated.", icon: "cube.fill", tint: .amber),
            .init(term: "Sourdough", detail: "A natural starter, dosed as a % of flour; its flour & water count toward the totals.", icon: "leaf.fill", tint: .sage)
        ],
        gotcha: [
            "Dead yeast is the #1 villain behind flat, sad dough. RIP.",
            "Water hotter than ~50 °C murders it; fridge-cold water just makes it hit snooze."
        ])

    static let preferment = InfoTopic(id: "preferment", title: "Pre-ferment",
        body: "A poolish or biga ferments part of the flour ahead for deeper flavour and strength.\n\nMaths: we carve the pre-ferment's flour and water out of the totals, so your overall hydration stays exactly what you set.",
        definitionsTitle: "The types",
        definitions: [
            .init(term: "Poolish", detail: "100% hydration (~30% of the flour). Loose and bubbly — boosts extensibility and flavour.", icon: "drop.fill", tint: .cool),
            .init(term: "Biga", detail: "~50% hydration (~50% of the flour). Stiff — adds strength and a deeper aroma.", icon: "square.stack.3d.up.fill", tint: .amber)
        ],
        gotcha: [
            "Over-ferment the poolish and it collapses with a boozy whiff — use it domed and bubbly, not sunken and sulking."
        ])

    static let temperature = InfoTopic(id: "temperature", title: "Room temperature",
        body: "How warm the room is, used to time the rise and dose the yeast.\n\nMaths: fermentation roughly doubles in speed per +10 °C (Q10 ≈ 2), so yeast = reference × (8 h ÷ hours) × 2^((20 − temp) ÷ 10). Warmer → less yeast and a faster rise.",
        gotcha: [
            "Fib about the room temp and the whole plan sulks — dough left somewhere warmer than you claimed will over-proof and deflate like a dramatic soufflé."
        ])

    static let ferment = InfoTopic(id: "ferment", title: "Fermentation method",
        body: "How the main rise is run — it sets the time and temperature behind the yeast dose (and, for Quick, an accelerated, enriched recipe).\n\nMaths: cold uses fridge temperature, so far less yeast; quick triples the dose for speed.",
        definitionsTitle: "The methods",
        definitions: InfoDefinition.fermentMethods,
        gotcha: [
            "Cold dough needs to warm up before shaping — straight from the fridge it's tight, grumpy, and tears at the first stretch."
        ])

    static let autolyse = InfoTopic(id: "autolyse", title: "Autolyse",
        body: "An autolyse mixes just the flour and water first, then rests 20–60 minutes before the salt and yeast (and any pre-ferment) go in.\n\nWhy: the flour hydrates fully and develops natural extensibility, so the dough stretches easily without springing back. It pairs well with both poolish and biga.\n\nMaths: it changes no quantities — it's purely a process step, adding a short rest to your timeline.",
        gotcha: [
            "Hold the salt until after the rest — sneak it in early and it tightens the gluten and slows hydration, quietly defeating the whole point."
        ])

    static let recipe = InfoTopic(id: "recipe", title: "Recipe proportions",
        body: "Baker's percentages — each ingredient as a percentage of the flour weight (flour is always 100%).\n\nMaths: flour = total ÷ (1 + hydration + salt + oil + honey + yeast); each ingredient = flour × its %. Hydration is water ÷ flour — higher is wetter, airier and stickier. Colours flag values outside the safe range.",
        gotcha: [
            "Too much water = sticky goo that glues itself to everything you own.",
            "Too much salt (over ~4%) and the yeast clocks off early.",
            "Weak, low-protein flour can't hold high hydration — it just gives up."
        ])

    static let schedule = InfoTopic(id: "schedule", title: "When will you serve?",
        body: "Pick when you want to eat; the whole plan is worked backward from there. Set the serve time (or, for Quick, how soon) and the app tells you when to start.\n\nMaths: a dough needs a set amount of fermentation, so start = serve − (pre-ferment + bulk + proof). The fermentation method you pick sets how long that is:",
        definitionsTitle: "How each method shifts your start time",
        definitions: InfoDefinition.fermentMethods,
        gotcha: [
            "Leave a buffer! Stretching, topping and baking each pizza always takes longer than your optimistic brain thinks — especially one oven at a time.",
            "Tight on time? The app first warms the proof and nudges the yeast to fit your window (you'll see an \"auto-adjusted\" note) before it ever suggests a Quick dough."
        ])

    static let glutenFree = InfoTopic(id: "gluten-free", title: "Gluten free",
        body: "Gluten-free swaps the wheat flour for a blend (rice, tapioca, sorghum and so on) and adds a binder to do gluten's job of holding the dough together.\n\nWhat changes: with no gluten network, the dough needs much more water — we raise hydration to a per-style target (around 75–80% for pan styles, higher for thin/Neapolitan). Salt stays about the same (~2%). There's no kneading, and no biga or poolish — a long cold rest still helps flavour.\n\nHandling: press or roll the dough out with oiled hands rather than stretching, and par-bake the base before adding toppings.",
        gotcha: [
            "Don't double up on binder if your blend already lists xanthan or psyllium — it's the #1 cause of a gummy, gluey GF crust. Flip on 'binder already in my blend' and relax."
        ])

    static let binder = InfoTopic(id: "binder", title: "Binder (gluten substitute)",
        body: "A hydrocolloid binder replaces the stretch and gas-holding that gluten normally provides.\n\nMaths: the binder is dosed as a baker's percentage of the gluten-free flour blend, just like salt or oil.",
        definitionsTitle: "The options",
        definitions: [
            .init(term: "Xanthan gum", detail: "A little does a lot — about 2% of the flour. Quick cohesion and chew.", icon: "circle.hexagongrid.fill", tint: .sage),
            .init(term: "Psyllium husk", detail: "A touch heavier — about 3–4%. Breadier and flexible; holds water well.", icon: "leaf.fill", tint: .cool)
        ],
        gotcha: [
            "Loads of shop-bought GF flours already pack a binder. Add more and the crust turns slimy and gummy — read the label, then switch the added binder off if it's already in there."
        ])
}

/// The sheet that shows a single topic: blurb, colour-coded definitions, and the
/// things that'll drive you crazy.
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

                    if !topic.definitions.isEmpty {
                        definitionsSection
                    }

                    if !topic.gotcha.isEmpty {
                        gotchaSection
                    }

                    if humourEnabled {
                        jokeSection
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

    // MARK: Sections

    private var definitionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !topic.definitionsTitle.isEmpty {
                Text(topic.definitionsTitle.uppercased())
                    .font(.rounded(11, weight: .bold))
                    .foregroundStyle(Palette.textSoft)
            }
            ForEach(topic.definitions) { def in
                HStack(alignment: .top, spacing: 11) {
                    Image(systemName: def.icon)
                        .font(.rounded(15, weight: .bold))
                        .foregroundStyle(def.tint.color)
                        .frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(def.term)
                            .font(.rounded(14, weight: .bold))
                            .foregroundStyle(Palette.text)
                        Text(def.detail)
                            .font(.rounded(13))
                            .foregroundStyle(Palette.textSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(def.tint.color.opacity(0.10)))
                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(def.tint.color.opacity(0.30), lineWidth: 1))
            }
        }
    }

    private var gotchaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "hand.raised.fingers.spread.fill")
                Text("Things that will drive you crazy")
            }
            .font(.rounded(13, weight: .bold))
            .foregroundStyle(Palette.amber)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(topic.gotcha, id: \.self) { point in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                            .font(.rounded(15, weight: .bold))
                            .foregroundStyle(Palette.amber)
                        Text(point)
                            .font(.rounded(14))
                            .foregroundStyle(Palette.text)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.surface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Palette.amber.opacity(0.30), lineWidth: 1))
    }

    private var jokeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "party.popper.fill")
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
