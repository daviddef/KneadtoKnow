import SwiftUI

/// The in-app guide, authored in Markdown and rendered by `MarkdownView`.
let howItWorksMarkdown = """
# How it works

Knead to Know turns *how much pizza you want* into *exactly what to weigh out* — and *when to start* so it's ready when you are. Everything is built on **baker's percentages**, the language professional bakers use.

## 1. Pick a style

Each style (Neapolitan, New York, Roman, Detroit, Everyday) carries its own recipe profile — hydration, salt, oil, honey — and the yeasts that suit it. Choosing a style seeds sensible defaults you can then tweak.

## 2. Size becomes dough weight

You set how many pizzas and how big. From the size we work out the weight of one ball, then the total.

- **By size (round):** `area = π × (diameter ÷ 2)²`, then `ball = area × thickness factor`.
- **By size (pan):** `area = length × width`, then `dough = area × thickness factor`.
- **By weight:** you set the ball weight directly.

`total dough = number of pizzas × weight each`

A 30 cm Neapolitan works out near 250–280 g — the industry sweet spot for a 12″ pizza.

## 3. Baker's percentages

Flour is always **100%**. Every other ingredient is a percentage of the flour weight. So once we know the total dough and the percentages, we solve for flour:

`flour = total dough ÷ (1 + hydration + salt + oil + honey + yeast)`

Then each ingredient is simply:

`ingredient = flour × its percentage`

That's why the proportion sliders are in **%** — they scale to any number of pizzas automatically.

## 4. Yeast, time & temperature

You don't pick a yeast amount — we work it out from how long the dough has and how warm the room is. Less yeast for a long, warm rise; more for a short, cool one:

`dose = reference × (8 h ÷ your hours) × 2 ^ ((20°C − temp) ÷ 10)`

The `2 ^ (…)` part means fermentation roughly **doubles in speed for every +10 °C** — a baker's rule of thumb (Q10 ≈ 2).

Different yeasts are then converted by weight:

- **Instant dry (IDY)** — the baseline, ×1
- **Active dry (ADY)** — ×1.25
- **Fresh / cake (CY)** — ×3
- **Sourdough** — dosed as a % of flour instead, and its flour & water are counted in the totals

## 5. Pre-ferments: poolish & biga

A pre-ferment is a portion of the flour, water and a little yeast mixed ahead for deeper flavour.

- **Poolish** — loose, **100% hydration** (equal flour & water), ~12 h, about **30% of the flour**.
- **Biga** — stiff, **~50% hydration**, ~16 h, about **50% of the flour**.

We carve the pre-ferment's flour and water out of the totals, so the overall hydration you set stays honest. Salt, oil and honey always go into the final dough.

## 6. The schedule

A dough needs a roughly fixed amount of fermentation, set by temperature and method. We add up its stages and count **backwards** from your serve time:

`start = serve − (pre-ferment rest + bulk ferment + final proof)`

So instead of "ferment for X hours", the app tells you *when to begin*. Pick a later serve time and everything simply shifts; pick one too soon and the plan is flagged as rushed.

# The maths — a worked example

Say: **6 × 270 g** Neapolitan balls, **60%** hydration, **2.8%** salt, IDY, **18 h at 20 °C**.

- `total dough = 6 × 270 = 1620 g`
- `flour = 1620 ÷ (1 + 0.60 + 0.028 + 0.0005) ≈ 995 g`
- `water = 995 × 0.60 ≈ 597 g`
- `salt = 995 × 0.028 ≈ 28 g`
- `yeast = 995 × 0.05% ≈ 0.5 g`

Add them up: 995 + 597 + 28 + 0.5 ≈ **1620 g** — back to where we started. The parts always reconcile to the total.

*Yeast amounts and timings are well-grounded estimates, not laws. Trust your dough and adjust to taste.*

# More about Ingredients

Great pizza is a few good ingredients, handled well.

## Flour
- **Type 00** — finely milled, the classic for Neapolitan. Low-to-medium protein (~11–12.5%) for a soft, extensible dough that bakes fast and hot.
- **Bread / strong flour** — higher protein (~12.5–14%) for New York and pan styles; more gluten means more chew and the strength to hold high hydration and long ferments.
- **Semola rimacinata (fine semolina)** — golden durum wheat, used in Sicilian doughs and, crucially, for dusting (below).

A weak, low-protein flour can't hold high hydration — the dough turns slack and tears.

## Water
Plain tap water is fine; temperature matters most — cool for long ferments, warm (~40 °C) only for a quick rise. Very hard or heavily chlorinated water can slow fermentation.

## Salt
Fine sea salt seasons, tightens the gluten and reins in the yeast. Keep it ~2–3% of flour; over ~4% stalls the yeast.

## Yeast
Instant dry is the reliable everyday choice; fresh yeast is traditional for Neapolitan; a sourdough starter brings the most complex flavour. Whatever you use, make sure it's **fresh and in date**.

## Olive oil & honey
A little extra-virgin olive oil softens the crumb and crisps the base (New York, Roman, Detroit — not classic Neapolitan). A touch of honey feeds the yeast and helps browning, especially in a cooler oven or a quick dough.

## For shaping & baking
- **Fine semolina for dusting** — dust the bench and peel with semolina, not flour. It acts like tiny ball-bearings so the pizza slides off cleanly, and it won't burn or get absorbed the way raw flour does.
- A **baking steel or stone**, preheated as hot as the oven goes, gives the bottom heat a good crust needs.

## Toppings
Less is more. Use a good tinned San Marzano-style tomato (crushed, not over-cooked), drain fresh mozzarella so it doesn't flood the base, and add delicate things — basil, prosciutto, rocket — after baking. Tap the basket icon by "Pizzas & size" to plan toppings and get a shopping list.

# How to get the shape right

Shaping is where most home pizzas go wrong. A few habits fix it:

## Let it relax
If the dough springs back and won't stay stretched, it's tense — walk away for 10–15 minutes and try again. Cold dough must come fully back to room temperature (~2 h) first.

## Press, don't roll
Flatten the ball with your fingertips, leaving a 1–2 cm border untouched for the cornicione (the puffy rim). Never use a rolling pin on Neapolitan — it crushes out the air you spent hours building.

## Stretch from the centre out
Lift the disc and let gravity help: drape it over your knuckles and rotate, easing it wider. Or stretch on the bench, pushing from the middle towards the edge, turning as you go. Keep it even — thin middle, airy rim.

## Dust with semolina
Work on a bench dusted with fine semolina, not flour. It stops sticking and lets the pizza slide off the peel cleanly. Give the peel a shake before you launch — if it doesn't move freely, lift an edge and add a little more semolina.

## Don't overwork or overstretch
Too much handling tightens the gluten; stretch too thin and it tears or burns through. If you get a hole, pinch it closed and patch with a scrap.

## Pan styles
For Detroit, Sicilian and focaccia, don't stretch in the air — press the dough gently to the corners of a well-oiled pan. If it resists, let it rest and come back; for focaccia, dimple all over with oiled fingers.

# Pizza styles, and what suits them

Choosing a style sets sensible defaults, including the pre-ferment that suits it. As a rule of thumb: **biga** (stiff) builds strong gluten for high-hydration, fluffy, structured crusts; **poolish** (loose) gives crispier, lighter, more delicate ones. An **autolyse** helps both.

## Neapolitan Classic
~60% hydration, **poolish**, blistering bake (430–480 °C, 60–90 s). Tender, foldable, lightly charred. No oil or sugar.

## Neapolitan Contemporary (Contemporanea)
Higher hydration (~70%) on a **biga**, for a tall, cloud-like cornicione and an open crumb. A little honey and oil help it colour in a slightly cooler oven.

## New York
~65% hydration, **poolish**, with oil and a touch of honey. Big, foldable slices baked cooler and longer.

## Roman (tonda)
Thin and crisp, rolled flat, **biga** for structure. Shatteringly light.

## Detroit / Pan
Thick, airy, baked in an oiled steel pan. Cheese to the very edges (frico), sauce in stripes on top.

## Sicilian Sfincione
A deep, spongy focaccia-style base on a **biga**, topped with onion, anchovy, caciocavallo and breadcrumbs (no fresh mozzarella).

## Focaccia
Very wet (~80%) **biga** dough, dimpled in an oiled pan and baked at a moderate ~220 °C — pillowy within, crisp underneath.

## Everyday Home
The simplest route — no pre-ferment needed. Reliable in a domestic oven with a stone or steel.
"""

/// The kit that makes pizza easier.
let toolsMarkdown = """
# Tools & equipment

None of this is strictly essential, but each piece earns its place.

## The essentials
- **Digital scale (0.1 g)** — baking is by weight, not cups. The fine resolution matters for the tiny yeast amounts.
- **Large mixing bowl** with a lid or cover so the dough doesn't dry out.
- **Bench scraper / dough knife** — to cut, lift and turn sticky dough without tearing it.

## Shaping & launching
- **Fine semolina** for dusting the bench and peel — it won't burn or get absorbed like flour.
- **Pizza peel** — a thin one to launch; a small **turning peel** to spin the pizza in a hot oven.
- **Proofing boxes** (or a tray with a lid) to hold the balls without a skin forming.

## Baking
- **Baking steel or stone** — preheated fully, it delivers the fierce bottom heat a crust needs. Steel heats harder and faster than stone.
- **Oven thermometer** — home-oven dials often lie; check the real temperature.
- **Infrared thermometer** — to read the stone/steel surface before launching (aim for 250 °C+).
- **A dedicated pizza oven** (Ooni, Gozney…) — gas or wood, hitting 400–500 °C for true Neapolitan in 60–90 seconds.

## Nice to have
- A **plastic scraper** for the bowl and a **metal bench knife** for the counter.
- A **pizza cutter** or a rocking blade (mezzaluna).
- A **cooling rack** so the base stays crisp instead of steaming on a plate.
"""

/// A field guide to the usual pizza disasters.
let gotchasMarkdown = """
# Things that may get-ya

The usual pizza disasters — and how to dodge them.

## Dead or tired yeast
Old yeast won't rise. Check the date and proof a pinch in warm water with sugar — it should foam in ~10 minutes. Water over ~50 °C kills it outright.

## Weak flour
Low-protein flour can't hold high hydration or a long ferment — the dough goes slack and tears. Use 00 or bread flour with enough protein for your style.

## Too much salt
Over ~4% of flour, salt slows or stops the yeast. Measure it; don't eyeball.

## Too much water
High hydration gives airy crust but sticky, hard-to-handle balls. Wet your hands rather than flouring them, and build hydration up gradually.

## Dusting with flour
Raw flour on the bench gets absorbed, makes the dough stick, then burns on the stone. Use **fine semolina** instead.

## Over-proofing
Left too long or somewhere too warm, dough balloons then collapses — dense and boozy. Watch the dough, not just the clock.

## Dough that tears or breaks when you shape it
The usual culprits: under-developed gluten (knead more, or give it longer to ferment and strengthen); dough that's too cold (let fridge dough warm ~2 h); or it's over-proofed and weak. If it keeps snapping back, let the ball relax 10–15 minutes, then stretch gently from the centre outwards with your fingertips — never roll a Neapolitan with a pin. Very wet dough also tears more easily, so wet your hands instead of flouring them.

## Cold dough, straight to shaping
Fridge dough must come back to room temperature (~2 h) before stretching, or it fights back and tears.

## A not-hot-enough oven
Most home ovens can't hit Neapolitan temperatures. Preheat a steel or stone fully, or pick a style suited to your oven.

## Soggy middle
Too much sauce or wet mozzarella floods the centre. Go light, drain the cheese, don't overload.
"""

// MARK: - Markdown rendering

/// A small Markdown renderer: headings, bullets, paragraphs and `code` lines.
struct MarkdownView: View {
    let markdown: String

    private enum Block {
        case h1(String), h2(String), h3(String)
        case bullet(String), paragraph(String), code(String), space
    }

    private var blocks: [Block] {
        var out: [Block] = []
        var inCode = false
        for rawLine in markdown.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("```") { inCode.toggle(); continue }
            if inCode { out.append(.code(rawLine)); continue }
            if line.isEmpty { out.append(.space) }
            else if line.hasPrefix("### ") { out.append(.h3(String(line.dropFirst(4)))) }
            else if line.hasPrefix("## ")  { out.append(.h2(String(line.dropFirst(3)))) }
            else if line.hasPrefix("# ")   { out.append(.h1(String(line.dropFirst(2)))) }
            else if line.hasPrefix("- ")   { out.append(.bullet(String(line.dropFirst(2)))) }
            else { out.append(.paragraph(line)) }
        }
        return out
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .h1(let t):
                    inline(t).font(.rounded(26, weight: .bold)).foregroundStyle(Palette.text)
                        .padding(.top, 12)
                case .h2(let t):
                    inline(t).font(.rounded(19, weight: .bold)).foregroundStyle(Palette.accent)
                        .padding(.top, 10)
                case .h3(let t):
                    inline(t).font(.rounded(15, weight: .semibold)).foregroundStyle(Palette.text)
                        .padding(.top, 4)
                case .bullet(let t):
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•").foregroundStyle(Palette.accent)
                        inline(t).foregroundStyle(Palette.text)
                    }
                    .font(.rounded(14))
                case .paragraph(let t):
                    inline(t).font(.rounded(14)).foregroundStyle(Palette.text)
                        .fixedSize(horizontal: false, vertical: true)
                case .code(let t):
                    Text(t)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.accent)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Palette.well))
                case .space:
                    Spacer().frame(height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inline(_ s: String) -> Text {
        if let attr = try? AttributedString(
            markdown: s,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attr)
        }
        return Text(s)
    }
}

/// The full-screen guide presented from the options menu.
struct HowItWorksView: View {
    var body: some View {
        ScrollView {
            MarkdownView(markdown: howItWorksMarkdown)
                .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("How it works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The tools & equipment guide.
struct ToolsView: View {
    var body: some View {
        ScrollView {
            MarkdownView(markdown: toolsMarkdown)
                .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Tools")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The "things that may get-ya" guide.
struct GotchasView: View {
    var body: some View {
        ScrollView {
            MarkdownView(markdown: gotchasMarkdown)
                .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Get-ya guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}
