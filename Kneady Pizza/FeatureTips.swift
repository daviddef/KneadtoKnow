import Foundation

/// A single "here's a neat thing you can do" hint for the walkthrough and the
/// contextual "did you know?" pop-up. `section` ties it to a part of the screen
/// so the nudge can appear when the baker scrolls near it (nil = walkthrough-only).
struct FeatureTip: Identifiable {
    let id: String
    let icon: String      // SF Symbol
    let title: String
    let blurb: String
    var section: String? = nil
    /// A short one-liner for the floating nudge (falls back to the blurb).
    var nudge: String? = nil
}

enum FeatureTips {
    /// The friendly walkthrough — one simple, unintimidating card at a time.
    static let all: [FeatureTip] = [
        .init(id: "welcome", icon: "hand.wave.fill",
              title: "A few handy tricks",
              blurb: "Quick tour of the little things that make Kneady nicer to use. Swipe through — it's short, promise."),
        .init(id: "chips", icon: "rectangle.3.group.fill",
              title: "Jump around fast",
              blurb: "Tap a recap chip near the top to leap straight to that part of the setup.",
              section: "setup",
              nudge: "Tap a recap chip up top to jump straight to that part of the setup."),
        .init(id: "favourite", icon: "star.fill",
              title: "Save your favourite",
              blurb: "Tap the star up top to remember your whole setup — style, size, timings and the pizzas you planned.",
              section: "summary",
              nudge: "Tap the ⭐ up top to save this whole setup as your favourite."),
        .init(id: "plan", icon: "basket.fill",
              title: "Plan pizzas & shopping",
              blurb: "The basket builds a scaled shopping list — dough and toppings — for exactly how many pizzas you're making.",
              section: "summary",
              nudge: "Tap the 🧺 basket to plan pizzas and a scaled shopping list."),
        .init(id: "tap-zoom", icon: "hand.point.up.left",
              title: "Tap a step to zoom in",
              blurb: "In the Cooking Directions, a single tap blows a step up big and clear — easy to read with floury hands.",
              section: "directions",
              nudge: "Single-tap a step here to read it nice and big."),
        .init(id: "double-done", icon: "checkmark.circle.fill",
              title: "Double-tap to tick it off",
              blurb: "Finished a step? Double-tap it to cross it out. Double-tap again to undo. The round dot works too.",
              section: "directions",
              nudge: "Double-tap a step to tick it off — double-tap again to undo."),
        .init(id: "start", icon: "play.fill",
              title: "Start baking now",
              blurb: "Hit it when you actually begin and your times lock in — they won't drift when you reopen the app.",
              section: "directions",
              nudge: "Tap “Start baking now” to lock these times so they don't reset."),
        .init(id: "info", icon: "info.circle",
              title: "What's this step?",
              blurb: "Tap the ⓘ beside any step for what it means in plain English, plus the kit that helps.",
              section: "directions",
              nudge: "Tap the ⓘ on any step to learn what it is and what tools help."),
        .init(id: "banner", icon: "flame.fill",
              title: "Pick up where you left off",
              blurb: "The yellow Currently Cooking banner jumps you straight to the step you're on. Tap ✕ when you're done."),
    ]

    /// The next unseen contextual tip for a section, if any.
    static func contextual(for section: String, excluding shown: Set<String>) -> FeatureTip? {
        all.first { $0.section == section && !shown.contains($0.id) }
    }
}

/// Remembers whether the user has seen the feature walkthrough.
enum WalkthroughStore {
    private static let key = "featureWalkthroughSeen.v1"
    static var seen: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
