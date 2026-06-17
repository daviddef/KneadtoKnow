import Foundation

/// Single-sentence coaching tips drawn from the app's own guidance — equipment,
/// definitions, gotchas and the maths. Pitched to the user's level: beginners
/// (simple mode) get practical, equipment-led advice; advanced bakers get the
/// gotchas and the maths.
enum Tips {

    /// Practical, equipment-led, encouraging — for newcomers.
    static let beginner = [
        "Weigh everything on a 0.1 g scale — baking is by weight, and the yeast amounts are tiny.",
        "Dust the bench and peel with fine semolina, not flour — it won't burn or get absorbed.",
        "Drain fresh mozzarella on kitchen paper so it doesn't flood the base.",
        "Preheat your stone or steel fully — a cold surface gives a pale, bready crust.",
        "Let cold dough come back to room temperature before shaping, or it'll tear.",
        "Go light on toppings — too much sauce or cheese makes a soggy middle.",
        "Check your yeast is in date; old yeast simply won't rise.",
        "Keep the dough covered while it rests so it doesn't dry out and form a skin.",
        "Press the dough out from the centre, leaving a 1–2 cm rim for the puffy edge.",
        "A bench scraper makes lifting and turning sticky dough far easier.",
        "Give the peel a little shake before launching — if it sticks, add more semolina.",
        "No pizza oven? A steel near the top of a hot domestic oven is the next best thing.",
        "Warm spot, faster rise; cool spot, slower — let how puffy it looks be your guide.",
        "Add delicate things — basil, rocket, prosciutto — after baking, not before.",
    ]

    /// Technique and the why behind it — for the improving baker.
    static let intermediate = [
        "Stretch, don't roll — a rolling pin crushes out the air you spent hours building.",
        "Higher hydration gives an airier crumb but a stickier dough — wet your hands instead of flouring them.",
        "If the dough springs back, let it relax 10–15 minutes, then stretch again.",
        "Salt much above ~4% of the flour starts to slow the yeast down.",
        "A little honey or sugar helps the crust brown in a cooler oven.",
        "Ball the dough tight and smooth so it holds its shape rather than spreading.",
        "For pan styles, press to the corners and dimple — don't try to stretch it in the air.",
        "Build hydration up gradually as your handling improves; don't jump straight to 80%.",
        "Knead until smooth and stretchy — under-worked dough can't hold its gas.",
    ]

    /// Maths and gotchas — for the confident baker.
    static let advanced = [
        "Fermentation roughly doubles in speed per +10 °C (Q10 ≈ 2), so warm rooms need far less yeast.",
        "flour = total dough ÷ (1 + hydration + salt + oil + honey + yeast) — everything else scales off that.",
        "A poolish is 100% hydration, a biga ~50% — both are carved from your totals so overall hydration stays honest.",
        "Over-ferment a poolish and it collapses and smells sharply of alcohol — use it domed and bubbly.",
        "Yeast conversion: instant ×1, active dry ×1.25, fresh ×3; sourdough is dosed as a % of flour.",
        "Hold the salt back until after the autolyse — added early it tightens the gluten and slows hydration.",
        "Cold-proofed dough is more digestible and complex, but must warm ~2 h before shaping.",
        "Weak, low-protein flour can't hold high hydration or a long ferment — it goes slack and tears.",
        "Water hotter than ~50 °C kills yeast; fridge-cold barely wakes it.",
        "Detroit-style: cheese to the very edges for the crisp frico, then sauce in stripes on top.",
    ]

    // MARK: Non-repeating draw

    private static var bags: [String: [String]] = [:]

    private static func draw(_ pool: [String], _ key: String) -> String {
        guard !pool.isEmpty else { return "" }
        var bag = bags[key] ?? []
        if bag.isEmpty { bag = pool.shuffled() }
        let tip = bag.removeLast()
        bags[key] = bag
        return tip
    }

    /// A level-appropriate tip. Simple mode leans practical; advanced unlocks
    /// the gotchas and the maths.
    static func random(simpleMode: Bool) -> String {
        simpleMode ? draw(beginner + intermediate, "simple")
                   : draw(intermediate + advanced, "advanced")
    }
}
