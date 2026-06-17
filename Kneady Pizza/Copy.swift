import Foundation

/// Section headings get a cheeky rewrite in the Vibrant look; the calm Classic
/// look keeps the plain, descriptive words.
enum SectionCopy {
    private static let playful: [String: String] = [
        "Pizza style":         "What are we making?",
        "Pizzas & size":       "How Hungry are you?",
        "Yeast or starter":    "The rise stuff",
        "Recipe proportions":  "The mix",
        "When will you serve?": "When's dinner?",
        "Directions":          "Let's get cooking",
    ]

    /// The playful heading in Vibrant, the plain one in Classic.
    static func title(_ classic: String) -> String {
        Palette.isVibrant ? (playful[classic] ?? classic) : classic
    }
}
